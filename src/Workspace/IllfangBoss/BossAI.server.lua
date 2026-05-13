-- Workspace/IllfangBoss/BossAI
local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")

local boss    = script.Parent
local hum     = boss:WaitForChild("Humanoid")
local hrp     = boss:WaitForChild("HumanoidRootPart")
print("BossAI loaded. WalkSpeed:", hum.WalkSpeed, "Health:", hum.Health, "RigType:", hum.RigType.Name)

local MAX_HP            = 2000
local PHASE2_HP         = MAX_HP * 0.25
local AGGRO_RANGE       = 60
local LEASH_RANGE       = 90
local TALWAR_DMG        = 30
local TALWAR_RANGE      = 8
local NODACHI_DMG       = 55
local NODACHI_RANGE     = 12

task.wait(1) -- let map build first
boss:PivotTo(CFrame.new(-180, 6, 380))

hum.MaxHealth = MAX_HP
hum.Health    = MAX_HP
hum.WalkSpeed = 14

local States = {IDLE=1, AGGRO=2, ATTACK=3, TRANSITION=4, DEAD=5}
local state         = States.IDLE
local phase         = 1
local attackTimer   = 0
local target        = nil

local function getDamage() return phase == 1 and TALWAR_DMG  or NODACHI_DMG  end
local function getRange()  return phase == 1 and TALWAR_RANGE or NODACHI_RANGE end

local function nearestPlayer()
	local best, bestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		local c = p.Character
		if c then
			local h = c:FindFirstChild("HumanoidRootPart")
			local hm = c:FindFirstChildOfClass("Humanoid")
			if h and hm and hm.Health > 0 then
				local d = (hrp.Position - h.Position).Magnitude
				if d < bestDist then best, bestDist = c, d end
			end
		end
	end
	return best, bestDist
end

local function doAttack(targetChar)
	local tHRP = targetChar:FindFirstChild("HumanoidRootPart")
	local tHum = targetChar:FindFirstChildOfClass("Humanoid")
	if not tHRP or not tHum then return end

	local dist = (hrp.Position - tHRP.Position).Magnitude
	if dist > getRange() then return end

	tHum:TakeDamage(getDamage())

	-- Nodachi cleave: also hit nearby players
	if phase == 2 then
		for _, p in ipairs(Players:GetPlayers()) do
			local c = p.Character
			if c and c ~= targetChar then
				local cHRP = c:FindFirstChild("HumanoidRootPart")
				local cHum = c:FindFirstChildOfClass("Humanoid")
				if cHRP and cHum and (hrp.Position - cHRP.Position).Magnitude <= NODACHI_RANGE * 1.4 then
					cHum:TakeDamage(math.floor(NODACHI_DMG * 0.5))
				end
			end
		end
	end
end

local function enterPhase2()
	state = States.TRANSITION
	hum.WalkSpeed = 0

	local weapon = boss:FindFirstChild("Weapon")
	task.delay(2.5, function()
		if weapon then weapon.BrickColor = BrickColor.new("Dark orange") end
		phase = 2
		hum.WalkSpeed = 22
		state = States.AGGRO
		print("[BOSS] Illfang draws his nodachi — beta data is useless now!")
	end)
end

hum.HealthChanged:Connect(function(hp)
	if hp <= 0 and state ~= States.DEAD then
		state = States.DEAD
		print("[SYSTEM] Illfang the Kobold Lord has been defeated. Floor 1 cleared.")
		hum.WalkSpeed = 0
		return
	end
	if phase == 1 and hp <= PHASE2_HP and state ~= States.TRANSITION then
		enterPhase2()
	end
end)

RunService.Heartbeat:Connect(function(dt)
	if state == States.DEAD or state == States.TRANSITION then return end

	attackTimer = math.max(0, attackTimer - dt)

	if state == States.IDLE then
		local nearest, dist = nearestPlayer()
		if nearest and dist <= AGGRO_RANGE then
			target = nearest
			state  = States.AGGRO
		end

	elseif state == States.AGGRO then
		local nearest, dist = nearestPlayer()
		if not nearest or dist > LEASH_RANGE then
			target = nil
			state  = States.IDLE
			hum:MoveTo(hrp.Position)
			return
		end
		target = nearest
		local tHRP = target:FindFirstChild("HumanoidRootPart")
		if tHRP then hum:MoveTo(tHRP.Position) end

		if dist <= getRange() and attackTimer <= 0 then
			state = States.ATTACK
		end

	elseif state == States.ATTACK then
		if target and attackTimer <= 0 then
			doAttack(target)
			attackTimer = phase == 1 and 1.8 or 1.2
		end
		state = States.AGGRO
	end
end)
