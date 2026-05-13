-- LevelHandler.server.lua
-- Script: handles XP gain, level-ups, HP curve, and player respawn

local Players           = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStats = require(ReplicatedStorage.Modules.PlayerStats)

local MAX_LEVEL = 100

local function xpForNextLevel(level)
	-- Level 1->2 needs 100 XP; each level costs 100*level more
	return level * 100
end

local function hpForLevel(level)
	return 100 + (level - 1) * 15
end

-- BindableEvent for other scripts to give XP
local giveXPEvent = Instance.new("BindableEvent")
giveXPEvent.Name   = "GiveXPEvent"
giveXPEvent.Parent = ServerScriptService

local LevelUpRemote

local function waitForRemote()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if remotes then
		LevelUpRemote = remotes:WaitForChild("LevelUp", 30)
	end
end
task.spawn(waitForRemote)

local function processXP(player, amount)
	local profile = PlayerStats.Get(player)
	if not profile then return end
	if profile.Level >= MAX_LEVEL then return end

	profile.XP = profile.XP + amount
	PlayerStats.SetXP(player, profile.XP)

	-- Check for level-up(s)
	local leveled = false
	while profile.Level < MAX_LEVEL do
		local needed = xpForNextLevel(profile.Level)
		if profile.XP >= needed then
			profile.XP = profile.XP - needed
			profile.Level = profile.Level + 1
			local newMaxHP = hpForLevel(profile.Level)
			profile.MaxHP = newMaxHP
			profile.CurrentHP = newMaxHP
			PlayerStats.SetLevel(player, profile.Level)
			PlayerStats.SetXP(player, profile.XP)
			leveled = true

			-- Update character HP
			local char = player.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then
					hum.MaxHealth = newMaxHP
					hum.Health    = newMaxHP
				end
			end

			-- Fire LevelUp remote to client
			if LevelUpRemote then
				LevelUpRemote:FireClient(player, profile.Level)
			end
		else
			break
		end
	end

	if leveled then
		profile._dirty = true
	end
end

giveXPEvent.Event:Connect(function(player, amount)
	if not player or not player.Parent then return end
	processXP(player, amount)
end)

-- Respawn handler
local function setupCharacterDied(player, character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then return end

	humanoid.Died:Connect(function()
		local profile = PlayerStats.Get(player)
		if profile then
			profile.CurrentHP = 0
			profile._dirty = true
		end

		task.delay(5, function()
			if player and player.Parent then
				player:LoadCharacter()
			end
		end)
	end)
end

Players.PlayerAdded:Connect(function(player)
	if player.Character then
		setupCharacterDied(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		setupCharacterDied(player, character)

		-- Sync MaxHP from profile once character loads
		local profile = PlayerStats.Get(player)
		if profile then
			local humanoid = character:WaitForChild("Humanoid", 10)
			if humanoid then
				humanoid.MaxHealth = profile.MaxHP
				humanoid.Health    = profile.CurrentHP
			end
		end
	end)
end)

-- Handle players already in game
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		setupCharacterDied(player, player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		setupCharacterDied(player, character)
		local profile = PlayerStats.Get(player)
		if profile then
			local humanoid = character:WaitForChild("Humanoid", 10)
			if humanoid then
				humanoid.MaxHealth = profile.MaxHP
				humanoid.Health    = profile.CurrentHP
			end
		end
	end)
end

print("[LevelHandler] Ready")
