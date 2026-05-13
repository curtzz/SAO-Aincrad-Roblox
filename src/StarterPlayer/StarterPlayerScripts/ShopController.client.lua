-- ShopController.client.lua
-- LocalScript: listens to OpenShop event and shows the shop UI modal

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "ShopUI"
screenGui.ResetOnSpawn  = false
screenGui.Enabled       = false
screenGui.Parent        = player.PlayerGui

-- Dark overlay
local overlay = Instance.new("Frame")
overlay.Size                 = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3     = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.6
overlay.BorderSizePixel      = 0
overlay.Parent               = screenGui

-- Shop panel
local shopPanel = Instance.new("Frame")
shopPanel.AnchorPoint       = Vector2.new(0.5, 0.5)
shopPanel.Position          = UDim2.new(0.5, 0, 0.5, 0)
shopPanel.Size              = UDim2.new(0, 420, 0, 480)
shopPanel.BackgroundColor3  = Color3.fromRGB(25, 25, 35)
shopPanel.BackgroundTransparency = 0.1
shopPanel.BorderSizePixel   = 0
shopPanel.Parent            = screenGui

-- Shop name
local shopTitle = Instance.new("TextLabel")
shopTitle.Name    = "ShopTitle"
shopTitle.Size    = UDim2.new(1, -50, 0, 44)
shopTitle.Position = UDim2.new(0, 10, 0, 6)
shopTitle.BackgroundTransparency = 1
shopTitle.Text    = "Shop"
shopTitle.Font    = Enum.Font.GothamBold
shopTitle.TextSize = 22
shopTitle.TextColor3 = Color3.new(1, 1, 1)
shopTitle.TextXAlignment = Enum.TextXAlignment.Left
shopTitle.Parent  = shopPanel

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size   = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -42, 0, 4)
closeBtn.Text   = "×"
closeBtn.TextSize = 24
closeBtn.Font   = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = shopPanel

-- Result label
local resultLabel = Instance.new("TextLabel")
resultLabel.Size   = UDim2.new(1, -10, 0, 28)
resultLabel.Position = UDim2.new(0, 5, 0, 50)
resultLabel.BackgroundTransparency = 1
resultLabel.Text   = ""
resultLabel.Font   = Enum.Font.Gotham
resultLabel.TextSize = 14
resultLabel.TextColor3 = Color3.fromRGB(120, 240, 120)
resultLabel.Parent = shopPanel

-- Scrolling item list
local itemList = Instance.new("ScrollingFrame")
itemList.Position         = UDim2.new(0, 8, 0, 82)
itemList.Size             = UDim2.new(1, -16, 1, -96)
itemList.BackgroundTransparency = 1
itemList.ScrollBarThickness = 6
itemList.Parent           = shopPanel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding   = UDim.new(0, 6)
listLayout.Parent    = itemList

local buyRemote, buyResultRemote, openShopRemote
task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end
	buyRemote      = remotes:WaitForChild("BuyItem",   30)
	buyResultRemote = remotes:WaitForChild("BuyResult", 30)
	openShopRemote  = remotes:WaitForChild("OpenShop",  30)

	openShopRemote.OnClientEvent:Connect(function(shopData)
		-- shopData is the shop table: { Name, Items } or just shopId string
		local shopName, items
		if type(shopData) == "table" then
			shopName = shopData.Name or "Shop"
			items    = shopData.Items or {}
		else
			-- Server may send a shop table or just a name; handle both
			shopName = tostring(shopData)
			items    = {}
		end

		-- Clear previous items
		for _, child in ipairs(itemList:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		shopTitle.Text   = shopName
		resultLabel.Text = ""

		for i, item in ipairs(items) do
			local row = Instance.new("Frame")
			row.Size             = UDim2.new(1, -4, 0, 64)
			row.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
			row.BorderSizePixel  = 0
			row.LayoutOrder      = i
			row.Parent           = itemList

			local nameLbl = Instance.new("TextLabel")
			nameLbl.Size   = UDim2.new(0.55, 0, 0.5, 0)
			nameLbl.BackgroundTransparency = 1
			nameLbl.Text   = item.Name or item.Id
			nameLbl.Font   = Enum.Font.GothamBold
			nameLbl.TextSize = 14
			nameLbl.TextColor3 = Color3.new(1, 1, 1)
			nameLbl.TextXAlignment = Enum.TextXAlignment.Left
			nameLbl.Position = UDim2.new(0, 8, 0, 0)
			nameLbl.Parent   = row

			local descLbl = Instance.new("TextLabel")
			descLbl.Size   = UDim2.new(0.7, 0, 0.5, 0)
			descLbl.Position = UDim2.new(0, 8, 0.5, 0)
			descLbl.BackgroundTransparency = 1
			descLbl.Text   = item.Description or ""
			descLbl.Font   = Enum.Font.Gotham
			descLbl.TextSize = 11
			descLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
			descLbl.TextXAlignment = Enum.TextXAlignment.Left
			descLbl.Parent = row

			local priceLbl = Instance.new("TextLabel")
			priceLbl.Size   = UDim2.new(0, 80, 0.5, 0)
			priceLbl.Position = UDim2.new(1, -160, 0, 5)
			priceLbl.BackgroundTransparency = 1
			priceLbl.Text   = tostring(item.Price) .. " Col"
			priceLbl.Font   = Enum.Font.Gotham
			priceLbl.TextSize = 13
			priceLbl.TextColor3 = Color3.fromRGB(220, 180, 0)
			priceLbl.Parent = row

			local buyBtn = Instance.new("TextButton")
			buyBtn.Size   = UDim2.new(0, 70, 0, 32)
			buyBtn.Position = UDim2.new(1, -78, 0.5, -16)
			buyBtn.Text   = "BUY"
			buyBtn.Font   = Enum.Font.GothamBold
			buyBtn.TextSize = 14
			buyBtn.TextColor3 = Color3.new(1, 1, 1)
			buyBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 60)
			buyBtn.BorderSizePixel  = 0
			buyBtn.Parent = row

			local capturedItem   = item
			local capturedShopId = shopData.ShopId or shopName
			buyBtn.MouseButton1Click:Connect(function()
				if buyRemote then
					buyRemote:FireServer(capturedShopId, capturedItem.Id)
				end
			end)
		end

		itemList.CanvasSize = UDim2.new(0, 0, 0, #items * 70 + 10)
		screenGui.Enabled = true
	end)

	buyResultRemote.OnClientEvent:Connect(function(success, message)
		resultLabel.Text      = message or ""
		resultLabel.TextColor3 = success
			and Color3.fromRGB(100, 240, 100)
			or  Color3.fromRGB(240, 80, 80)
	end)
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)
