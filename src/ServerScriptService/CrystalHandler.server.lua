-- CrystalHandler.server.lua
-- Script: handles UseHealingCrystal RemoteEvent — heals player and removes crystal

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerStats = require(ReplicatedStorage.Modules.PlayerStats)

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end

	local healRemote = remotes:WaitForChild("UseHealingCrystal", 30)
	healRemote.OnServerEvent:Connect(function(player)
		local profile = PlayerStats.Get(player)
		if not profile then return end

		-- Check if player has a HealingCrystal
		local hasItem = false
		for _, id in ipairs(profile.Inventory) do
			if id == "HealingCrystal" then
				hasItem = true
				break
			end
		end
		if not hasItem then return end

		-- Check HP isn't already full
		if profile.CurrentHP >= profile.MaxHP then return end

		-- Heal 50% of MaxHP
		local healAmount = math.floor(profile.MaxHP * 0.5)
		profile.CurrentHP = math.min(profile.CurrentHP + healAmount, profile.MaxHP)
		profile._dirty    = true

		-- Apply to character humanoid
		local char = player.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)
			end
		end

		-- Remove the crystal from inventory
		PlayerStats.RemoveItem(player, "HealingCrystal")
	end)
end)

print("[CrystalHandler] Ready")
