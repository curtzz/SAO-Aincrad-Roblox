-- MobSpawner.server.lua
-- Script: spawns Frenzy Boar mobs at SpawnMarker parts in Field zone

local Players        = game:GetService("Players")
local Workspace      = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStats = require(ReplicatedStorage.Modules.PlayerStats)

local BOAR_MAX_HP   = 40
local BOAR_DAMAGE   = 8
local BOAR_SPEED    = 12
local BOAR_RANGE    = 40
local BOAR_XP       = 25
local BOAR_COL      = 15
local RESPAWN_DELAY = 30
local DAMAGE_COOLDOWN = 1

-- Wait for Field folder
local fieldFolder = Workspace:WaitForChild("Floor1Map", 60):WaitForChild("Field", 60)

local function getCharacterOwner(hitPart)
	local model = hitPart:FindFirstAncestorOfClass("Model")
	if not model then return nil end
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character == model then
			return p
		end
	end
	return nil
end

local function getNearestPlayer(position)
	local nearest, nearestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		local char = p.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local dist = (hrp.Position - position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearest = p
				end
			end
		end
	end
	return nearest, nearestDist
end

local function createBoar(markerPosition)
	local model = Instance.new("Model")
	model.Name  = "FrenzyBoar"

	local hrp = Instance.new("Part")
	hrp.Name      = "HumanoidRootPart"
	hrp.Size      = Vector3.new(4, 4, 4)
	hrp.BrickColor = BrickColor.new("Dusty Rose")
	hrp.Anchored  = false
	hrp.CanCollide = true
	hrp.CFrame    = CFrame.new(markerPosition + Vector3.new(0, 2, 0))
	hrp.Parent    = model

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth   = BOAR_MAX_HP
	humanoid.Health      = BOAR_MAX_HP
	humanoid.WalkSpeed   = BOAR_SPEED
	humanoid.Parent      = model

	model.PrimaryPart = hrp

	-- Nametag
	local bb  = Instance.new("BillboardGui")
	bb.Size   = UDim2.new(0, 140, 0, 30)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = false
	local lbl = Instance.new("TextLabel")
	lbl.Size  = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text  = "Frenzy Boar"
	lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
	lbl.Font  = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Parent = bb
	bb.Parent  = hrp

	model.Parent = Workspace

	-- Touch damage with cooldown per-player
	local damageCooldowns = {}
	hrp.Touched:Connect(function(hit)
		local owner = getCharacterOwner(hit)
		if not owner then return end
		local now = tick()
		if damageCooldowns[owner.UserId] and now - damageCooldowns[owner.UserId] < DAMAGE_COOLDOWN then return end
		damageCooldowns[owner.UserId] = now
		local char = owner.Character
		if not char then return end
		local h = char:FindFirstChildOfClass("Humanoid")
		if h and h.Health > 0 then
			h:TakeDamage(BOAR_DAMAGE)
		end
	end)

	-- AI loop
	local aiActive = true
	task.spawn(function()
		while aiActive and humanoid.Health > 0 do
			task.wait(0.3)
			local nearPlayer, dist = getNearestPlayer(hrp.Position)
			if nearPlayer and dist < BOAR_RANGE then
				local char = nearPlayer.Character
				if char then
					local targetHRP = char:FindFirstChild("HumanoidRootPart")
					if targetHRP then
						humanoid:MoveTo(targetHRP.Position)
					end
				end
			end
		end
	end)

	-- Death handler
	humanoid.Died:Connect(function()
		aiActive = false

		-- Reward the nearest player
		local killerPlayer, _ = getNearestPlayer(hrp.Position)
		if killerPlayer then
			task.spawn(function()
				-- Give XP via BindableEvent in ServerScriptService
				local sse = game:GetService("ServerScriptService")
				local giveXPEvent = sse:FindFirstChild("GiveXPEvent")
				if giveXPEvent then
					giveXPEvent:Fire(killerPlayer, BOAR_XP)
				end
				PlayerStats.AddCol(killerPlayer, BOAR_COL)
			end)
		end

		task.delay(RESPAWN_DELAY, function()
			if model and model.Parent then
				model:Destroy()
			end
			createBoar(markerPosition)
		end)

		task.delay(2, function()
			if model and model.Parent then
				model:Destroy()
			end
		end)
	end)

	return model
end

-- Spawn boars at all SpawnMarkers
for _, part in ipairs(fieldFolder:GetChildren()) do
	if part:IsA("BasePart") and part.Name == "SpawnMarker" then
		local pos = part.Position
		task.spawn(function()
			createBoar(pos)
		end)
	end
end

print("[MobSpawner] Frenzy Boars spawned")
