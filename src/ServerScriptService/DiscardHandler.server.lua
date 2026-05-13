-- DiscardHandler.server.lua
-- Script: listens to DiscardItem RemoteEvent and removes item from inventory

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerStats = require(ReplicatedStorage.Modules.PlayerStats)

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end

	local discardRemote = remotes:WaitForChild("DiscardItem", 30)
	discardRemote.OnServerEvent:Connect(function(player, itemId)
		if type(itemId) ~= "string" then return end
		PlayerStats.RemoveItem(player, itemId)
	end)
end)

print("[DiscardHandler] Ready")
