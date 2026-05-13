-- BossAI.server.lua
-- Comprehensive two-phase AI for Illfang the Kobold Lord

local RunService          = game:GetService("RunService")
local Players             = game:GetService("Players")
local TweenService        = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local boss = script.Parent
local hum  = boss:WaitForChild("Humanoid")
local hrp  = boss:WaitForChild("HumanoidRootPart")

-- Wait for MapBuilder to finish before positioning
task.wait(2)
boss:PivotTo(CFrame.new(0, 6, 800))

-- ================================================================
-- TUNING
-- ================================================================
local SPAWN_CF      = CFrame.new(0, 6, 800)
local MAX_HP        = 2000
local PHASE2_THRESH = MAX_HP * 0.25   -- 500 HP triggers phase 2
local AGGRO_RANGE   = 70
local LEASH_RANGE   = 110             -- leash: reset if all players flee past this

local P1 = {
	walkSpeed   = 14,
	strikeRange = 8,   strikeDmg  = 30,  strikeCD  = 1.8,
	chargeSpeed = 55,  chargeDmg  = 25,  chargeCD  = 10,  chargeDist = 35,
	slamDmg     = 45,  slamRadius = 15,  slamCD    = 16,
}
local P2 = {
	walkSpeed   = 22,
	strikeRange = 12,  strikeDmg  = 55,  strikeCD  = 1.1,
	chargeSpeed = 75,  chargeDmg  = 40,  chargeCD  = 8,   chargeDist = 45,
	slamDmg     = 70,  slamRadius = 22,  slamCD    = 12,
	cleaveRange = 20,  cleaveDmg  = 45,  cleaveCD  = 6,
	berserkDmg  = 40,  berserkCD  = 22,
}

-- ================================================================
-- STATE
-- ================================================================
local STATE = { IDLE=1, AGGRO=2, BUSY=3, TRANSITION=4, DEAD=5 }
local state     = STATE.IDLE
local phase     = 1
local stats     = P1
local target    = nil  -- Player instance (not character)

local cd = { strike=0, charge=0, slam=0, cleave=0, berserk=0 }

-- ================================================================
-- INIT
-- ================================================================
hum.MaxHealth = MAX_HP
hum.Health    = MAX_HP
hum.WalkSpeed = P1.walkSpeed

boss:SetAttribute("Phase", 1)
boss:SetAttribute("BossMessage", "")

-- ================================================================
-- UTILITY
-- ================================================================
local function say(msg)
	boss:SetAttribute("BossMessage", msg)
	print("[BOSS] " .. msg)
	task.delay(3, function()
		if boss:GetAttribute("BossMessage") == msg then
			boss:SetAttribute("BossMessage", "")
		end
	end)
end

local function getNearestPlayer()
	local best, bestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		if c then
			local h  = c:FindFirstChild("HumanoidRootPart")
			local hm = c:FindFirstChildOfClass("Humanoid")
			if h and hm and hm.Health > 0 then
				local d = (hrp.Position - h.Position).Magnitude
				if d < bestDist then best, bestDist = p, d end
			end
		end
	end
	return best, bestDist
end

local function getCharsInRadius(center, radius)
	local result = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		if c then
			local h  = c:FindFirstChild("HumanoidRootPart")
			local hm = c:FindFirstChildOfClass("Humanoid")
			if h and hm and hm.Health > 0 and (center - h.Position).Magnitude <= radius then
				table.insert(result, c)
			end
		end
	end
	return result
end

local function knockback(targetHRP, direction, force)
	local bv = Instance.new("BodyVelocity")
	bv.Velocity  = direction.Unit * force + Vector3.new(0, 18, 0)
	bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
	bv.P         = 1e4
	bv.Parent    = targetHRP
	task.delay(0.35, function()
		if bv and bv.Parent then bv:Destroy() end
	end)
end

local function showAOE(center, radius, duration)
	local p = Instance.new("Part")
	p.Shape        = Enum.PartType.Cylinder
	p.Size         = Vector3.new(0.4, radius * 2, radius * 2)
	p.CFrame       = CFrame.new(center + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, 0, math.pi / 2)
	p.Anchored     = true
	p.CanCollide   = false
	p.BrickColor   = BrickColor.new("Bright red")
	p.Material     = Enum.Material.Neon
	p.Transparency = 0.45
	p.Parent       = workspace
	-- Fade out
	TweenService:Create(p, TweenInfo.new(duration), { Transparency = 1 }):Play()
	task.delay(duration, function()
		if p and p.Parent then p:Destroy() end
	end)
end

local function tintBoss(color, duration)
	local weapon = boss:FindFirstChild("Weapon")
	if not weapon then return end
	local orig = weapon.BrickColor
	weapon.BrickColor = BrickColor.new(color)
	task.delay(duration, function()
		if weapon and weapon.Parent then
			weapon.BrickColor = BrickColor.new(phase == 2 and "Dark orange" or orig.Name)
		end
	end)
end

-- ================================================================
-- ATTACKS
-- ================================================================

-- Basic melee strike
local function doStrike()
	if state ~= STATE.AGGRO then return end
	if cd.strike > 0 then return end
	local tChar = target and target.Character
	if not tChar then return end
	local tHRP = tChar:FindFirstChild("HumanoidRootPart")
	local tHum = tChar:FindFirstChildOfClass("Humanoid")
	if not tHRP or not tHum then return end
	if (hrp.Position - tHRP.Position).Magnitude > stats.strikeRange then return end

	tHum:TakeDamage(stats.strikeDmg)
	cd.strike = stats.strikeCD
	tintBoss("Bright red", 0.12)

	-- Phase 2: splash damage on nearby players
	if phase == 2 then
		for _, c in ipairs(getCharsInRadius(hrp.Position, stats.strikeRange * 1.4)) do
			if c ~= tChar then
				local h = c:FindFirstChildOfClass("Humanoid")
				if h then h:TakeDamage(math.floor(stats.strikeDmg * 0.35)) end
			end
		end
	end
end

-- Charge rush at target
local function doCharge()
	if state ~= STATE.AGGRO then return end
	if cd.charge > 0 then return end
	local tChar = target and target.Character
	if not tChar then return end
	local tHRP = tChar:FindFirstChild("HumanoidRootPart")
	if not tHRP then return end

	state = STATE.BUSY
	cd.charge = stats.chargeCD
	hum.WalkSpeed = 0

	say("Illfang charges!")
	tintBoss("Bright orange", 0.5)
	task.wait(0.6)  -- wind-up
	if state == STATE.DEAD then return end

	local dir = (tHRP.Position - hrp.Position)
	dir = Vector3.new(dir.X, 0, dir.Z).Unit
	local endPos = hrp.Position + dir * stats.chargeDist

	hum.WalkSpeed = stats.chargeSpeed
	hum:MoveTo(endPos)

	local hit = {}
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if state == STATE.DEAD then conn:Disconnect() return end
		for _, c in ipairs(getCharsInRadius(hrp.Position, 5.5)) do
			local p = Players:GetPlayerFromCharacter(c)
			if p and not hit[p.UserId] then
				hit[p.UserId] = true
				local h   = c:FindFirstChildOfClass("Humanoid")
				local cHRP = c:FindFirstChild("HumanoidRootPart")
				if h and cHRP then
					h:TakeDamage(stats.chargeDmg)
					knockback(cHRP, dir, 65)
				end
			end
		end
	end)

	task.delay(0.65, function()
		conn:Disconnect()
		if state ~= STATE.DEAD then
			hum.WalkSpeed = stats.walkSpeed
			state = STATE.AGGRO
		end
	end)
end

-- Ground slam AOE
local function doSlam()
	if state ~= STATE.AGGRO then return end
	if cd.slam > 0 then return end

	state = STATE.BUSY
	cd.slam = stats.slamCD
	hum.WalkSpeed = 0

	say("Illfang winds up a ground slam!")
	showAOE(hrp.Position, stats.slamRadius, 1.3)
	task.wait(1.3)  -- warning window
	if state == STATE.DEAD then return end

	-- Strike
	local center = hrp.Position
	tintBoss("Really red", 0.3)
	for _, c in ipairs(getCharsInRadius(center, stats.slamRadius)) do
		local h   = c:FindFirstChildOfClass("Humanoid")
		local cHRP = c:FindFirstChild("HumanoidRootPart")
		if h and cHRP then
			h:TakeDamage(stats.slamDmg)
			local dir = Vector3.new(cHRP.Position.X - center.X, 0, cHRP.Position.Z - center.Z)
			if dir.Magnitude > 0 then
				knockback(cHRP, dir, 85)
			end
		end
	end

	hum.WalkSpeed = stats.walkSpeed
	state = STATE.AGGRO
end

-- Phase 2: wide cleave sweep
local function doCleave()
	if phase ~= 2 then return end
	if state ~= STATE.AGGRO then return end
	if cd.cleave > 0 then return end

	state = STATE.BUSY
	cd.cleave = stats.cleaveCD
	hum.WalkSpeed = 0

	say("Illfang sweeps his nodachi — stay back!")
	showAOE(hrp.Position, stats.cleaveRange, 0.9)
	task.wait(0.9)
	if state == STATE.DEAD then return end

	tintBoss("Dark orange", 0.4)
	for _, c in ipairs(getCharsInRadius(hrp.Position, stats.cleaveRange)) do
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then h:TakeDamage(stats.cleaveDmg) end
	end

	hum.WalkSpeed = stats.walkSpeed
	state = STATE.AGGRO
end

-- Phase 2: rapid triple strike
local function doBerserk()
	if phase ~= 2 then return end
	if state ~= STATE.AGGRO then return end
	if cd.berserk > 0 then return end
	local tChar = target and target.Character
	if not tChar then return end
	local tHRP = tChar:FindFirstChild("HumanoidRootPart")
	if not tHRP then return end
	if (hrp.Position - tHRP.Position).Magnitude > stats.strikeRange * 1.3 then return end

	state = STATE.BUSY
	cd.berserk = stats.berserkCD

	say("Illfang goes berserk!")
	for i = 1, 3 do
		if state == STATE.DEAD then return end
		local c  = target and target.Character
		local tH = c and c:FindFirstChild("HumanoidRootPart")
		local hm = c and c:FindFirstChildOfClass("Humanoid")
		if tH and hm and (hrp.Position - tH.Position).Magnitude <= stats.strikeRange * 1.3 then
			hm:TakeDamage(stats.berserkDmg)
			tintBoss("Really red", 0.08)
		end
		task.wait(0.3)
	end

	if state ~= STATE.DEAD then state = STATE.AGGRO end
end

-- ================================================================
-- PHASE TRANSITION
-- ================================================================
local function enterPhase2()
	if state == STATE.DEAD or state == STATE.TRANSITION then return end
	state = STATE.TRANSITION
	hum.WalkSpeed = 0

	say("Illfang draws his nodachi — beta testers' data is USELESS now!")
	task.wait(0.8)

	-- Weapon flash
	local weapon = boss:FindFirstChild("Weapon")
	for i = 1, 8 do
		if state == STATE.DEAD then return end
		if weapon then
			weapon.BrickColor = BrickColor.new(i % 2 == 0 and "Dark orange" or "Really red")
		end
		task.wait(0.2)
	end
	if weapon then weapon.BrickColor = BrickColor.new("Dark orange") end

	-- Body recolor to signal phase 2
	for _, part in ipairs(boss:GetDescendants()) do
		if part:IsA("BasePart") and part ~= weapon then
			part.BrickColor = BrickColor.new("Bright red")
		end
	end

	phase    = 2
	stats    = P2
	hum.WalkSpeed = P2.walkSpeed
	boss:SetAttribute("Phase", 2)

	-- Free all attack cooldowns on transition for immediate aggression
	cd.strike = 0
	cd.charge = 0

	if state ~= STATE.DEAD then state = STATE.AGGRO end
end

-- ================================================================
-- LEASH / RESET
-- ================================================================
local function resetBoss()
	state  = STATE.IDLE
	phase  = 1
	stats  = P1
	target = nil

	for k in pairs(cd) do cd[k] = 0 end

	hum.MaxHealth = MAX_HP
	hum.Health    = MAX_HP
	hum.WalkSpeed = P1.walkSpeed

	boss:SetAttribute("Phase", 1)
	say("Illfang resets...")

	-- Restore base colors
	for _, part in ipairs(boss:GetDescendants()) do
		if part:IsA("BasePart") then
			part.BrickColor = BrickColor.new("Medium stone grey")
		end
	end

	boss:PivotTo(SPAWN_CF)
end

-- ================================================================
-- DEATH
-- ================================================================
hum.Died:Connect(function()
	state = STATE.DEAD
	hum.WalkSpeed = 0
	say("Illfang the Kobold Lord has been defeated! Floor 1 cleared!")
	-- BossRoomTrigger handles XP / Col / Floor2 unlock automatically
end)

-- ================================================================
-- PHASE 2 TRIGGER
-- ================================================================
hum.HealthChanged:Connect(function(hp)
	if phase == 1 and hp > 0 and hp <= PHASE2_THRESH
		and state ~= STATE.TRANSITION and state ~= STATE.DEAD then
		task.spawn(enterPhase2)
	end
end)

-- ================================================================
-- MAIN HEARTBEAT LOOP
-- ================================================================
RunService.Heartbeat:Connect(function(dt)
	-- Tick cooldowns
	for k in pairs(cd) do
		cd[k] = math.max(0, cd[k] - dt)
	end

	if state == STATE.DEAD or state == STATE.BUSY or state == STATE.TRANSITION then
		return
	end

	if state == STATE.IDLE then
		local p, dist = getNearestPlayer()
		if p and dist <= AGGRO_RANGE then
			target = p
			state  = STATE.AGGRO
			say("Illfang the Kobold Lord has awoken!")
		end
		return
	end

	-- AGGRO: chase + attack
	if state == STATE.AGGRO then
		local nearest, nearDist = getNearestPlayer()

		-- Leash: all players fled
		if not nearest or nearDist > LEASH_RANGE then
			resetBoss()
			return
		end

		target = nearest
		local tChar = target.Character
		if not tChar then return end
		local tHRP = tChar:FindFirstChild("HumanoidRootPart")
		if not tHRP then return end

		local dist = (hrp.Position - tHRP.Position).Magnitude

		-- Move toward target if not in melee range
		if dist > stats.strikeRange * 0.85 then
			hum:MoveTo(tHRP.Position)
		end

		-- Attack priority (most impactful first)
		if phase == 2 and cd.berserk == 0 and dist <= stats.strikeRange * 1.3 then
			task.spawn(doBerserk)
		elseif cd.slam == 0 and #getCharsInRadius(hrp.Position, stats.slamRadius * 0.7) >= 1 then
			task.spawn(doSlam)
		elseif phase == 2 and cd.cleave == 0 and #getCharsInRadius(hrp.Position, stats.cleaveRange) >= 1 then
			task.spawn(doCleave)
		elseif cd.charge == 0 and dist > stats.strikeRange and dist <= AGGRO_RANGE then
			task.spawn(doCharge)
		elseif cd.strike == 0 then
			doStrike()
		end
	end
end)

print("[BossAI] Illfang the Kobold Lord — ready at arena (0, 6, 800)")
