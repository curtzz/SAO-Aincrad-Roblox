-- ShopHandler.server.lua
-- Script: handles BuyItem RemoteEvent — validates purchase, updates player data

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStats  = require(ReplicatedStorage.Modules.PlayerStats)
local ShopCatalog  = require(ReplicatedStorage.Modules.ShopCatalog)

local function findItem(shopId, itemId)
	local shop = ShopCatalog[shopId]
	if not shop then return nil end
	for _, item in ipairs(shop.Items) do
		if item.Id == itemId then
			return item
		end
	end
	return nil
end

task.spawn(function()
	local remotes     = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end

	local buyItemRemote   = remotes:WaitForChild("BuyItem", 30)
	local buyResultRemote = remotes:WaitForChild("BuyResult", 30)

	buyItemRemote.OnServerEvent:Connect(function(player, shopId, itemId)
		local item = findItem(shopId, itemId)
		if not item then
			buyResultRemote:FireClient(player, false, "Item not found.")
			return
		end

		local success = PlayerStats.SpendCol(player, item.Price)
		if not success then
			buyResultRemote:FireClient(player, false, "Not enough Col!")
			return
		end

		PlayerStats.AddItem(player, itemId)
		buyResultRemote:FireClient(player, true, "Purchased: " .. item.Name)
	end)
end)

print("[ShopHandler] Ready")
