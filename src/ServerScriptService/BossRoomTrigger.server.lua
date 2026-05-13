-- BossRoomTrigger.server.lua
-- Script: manages the Labyrinth→BossArena door and Illfang boss kill rewards

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerStats = require(ReplicatedStorage.Modules.PlayerStats)

local ARENA_CENTER       = Vector3.new(0, 0, 800)
local ARENA_REWARD_RANGE = 200
local BOSS_XP_REWARD     = 500
local BOSS_COL_REWARD    = 300

-- States
local STATE_IDLE   = "IDLE"
local STATE_LOCKED = "LOCKED"
local state        = STATE_IDLE

-- Create trigger part (invisible, no collision)
local triggerPart = Instance.new("Part")
triggerPart.Name        = "BossRoomTrigger"
triggerPart.Size        = Vector3.new(60, 20, 4)
triggerPart.CFrame      = CFrame.new(Vector3.new(0, 5, 750))
triggerPart.Anchored    = true
triggerPart.CanCollide  = false
triggerPart.Transparency = 1
triggerPart.Parent      = Workspace

-- Create boss door (starts open)
local bossDoor = Instance.new("Part")
bossDoor.Name        = "BossDoor"
bossDoor.Size        = Vector3.new(60, 20, 4)
bossDoor.CFrame      = CFrame.new(Vector3.new(0, 5, 750))
bossDoor.Anchored    = true
bossDoor.CanCollide  = false
bossDoor.Transparency = 1
bossDoor.BrickColor  = BrickColor.new("Really black")
bossDoor.Parent      = Workspace

local function lockDoor()
	bossDoor.Transparency = 0
	bossDoor.CanCollide   = true
	state = STATE_LOCKED
end

local function unlockDoor()
	bossDoor.Transparency = 1
	bossDoor.CanCollide   = false
	state = STATE_IDLE
end

local function getPlayersNearArena()
	local nearby = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - ARENA_CENTER).Magnitude <= ARENA_REWARD_RANGE then
				table.insert(nearby, player)
			end
		end
	end
	return nearby
end

local function getGiveXPEvent()
	return ServerScriptService:FindFirstChild("GiveXPEvent")
end

local function onBossDefeated()
	unlockDoor()

	local nearbyPlayers = getPlayersNearArena()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local zoneUnlockedRemote = remotes and remotes:FindFirstChild("ZoneUnlocked")

	local giveXPEvent = getGiveXPEvent()

	for _, player in ipairs(nearbyPlayers) do
		if giveXPEvent then
			giveXPEvent:Fire(player, BOSS_XP_REWARD)
		end
		PlayerStats.AddCol(player, BOSS_COL_REWARD)
		PlayerStats.UnlockFloor(player, "Floor2")
		if zoneUnlockedRemote then
			zoneUnlockedRemote:FireClient(player, "Floor2")
		end
	end

	print(string.format("[BossRoomTrigger] IllfangBoss defeated — Floor 2 unlocked for %d players", #nearbyPlayers))
end

local bossConnected = false

local function tryConnectBoss()
	if bossConnected then return end
	local ok, boss = pcall(function()
		return Workspace:FindFirstChild("IllfangBoss")
	end)
	if ok and boss then
		local humanoid = boss:FindFirstChildOfClass("Humanoid")
		if humanoid then
			bossConnected = true
			humanoid.Died:Connect(function()
				if state == STATE_LOCKED then
					onBossDefeated()
				end
			end)
		end
	end
end

-- Debounce for trigger
local touchDebounce = {}

triggerPart.Touched:Connect(function(hit)
	if state ~= STATE_IDLE then return end

	local model = hit:FindFirstAncestorOfClass("Model")
	if not model then return end
	local player = Players:GetPlayerFromCharacter(model)
	if not player then return end

	local now = tick()
	if touchDebounce[player.UserId] and now - touchDebounce[player.UserId] < 2 then return end
	touchDebounce[player.UserId] = now

	lockDoor()

	-- Try to connect boss died event
	tryConnectBoss()
end)

-- Poll for boss model in case it's spawned later
task.spawn(function()
	while not bossConnected do
		task.wait(3)
		tryConnectBoss()
	end
end)

-- Watch for boss model being added to workspace
Workspace.ChildAdded:Connect(function(child)
	if child.Name == "IllfangBoss" then
		task.wait(0.1)
		tryConnectBoss()
	end
end)

Players.PlayerRemoving:Connect(function(player)
	touchDebounce[player.UserId] = nil
end)

print("[BossRoomTrigger] Ready")
