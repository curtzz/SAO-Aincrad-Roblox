-- PlayerLifecycle.server.lua
-- Script: manages player join/leave, spawning, and DataStore lifecycle

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStats = require(ReplicatedStorage.Modules.PlayerStats)

local SPAWN_POSITION = Vector3.new(0, 5, 0)

local function onCharacterAdded(player, character)
	task.wait(0.1)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(SPAWN_POSITION)
	end

	-- Sync profile HP to character humanoid
	local profile = PlayerStats.Get(player)
	if profile then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.MaxHealth = profile.MaxHP
			humanoid.Health    = math.min(profile.CurrentHP, profile.MaxHP)
		end
	end
end

local function onPlayerAdded(player)
	PlayerStats.Load(player)

	if player.Character then
		onCharacterAdded(player, player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

local function onPlayerRemoving(player)
	PlayerStats.Unload(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already connected (e.g. when script loads late in Studio)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		PlayerStats.Save(player)
	end
end)

print("[PlayerLifecycle] Ready")
