-- GateController.client.lua
-- LocalScript: listens to OpenGateMenu and shows floor teleport UI

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local ZoneRegistry = require(ReplicatedStorage.Modules.ZoneRegistry)

local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "GateMenu"
screenGui.ResetOnSpawn  = false
screenGui.Enabled       = false
screenGui.Parent        = player.PlayerGui

-- Overlay
local overlay = Instance.new("Frame")
overlay.Size                  = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3      = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.65
overlay.BorderSizePixel       = 0
overlay.Parent                = screenGui

-- Panel
local panel = Instance.new("Frame")
panel.AnchorPoint       = Vector2.new(0.5, 0.5)
panel.Position          = UDim2.new(0.5, 0, 0.5, 0)
panel.Size              = UDim2.new(0, 380, 0, 400)
panel.BackgroundColor3  = Color3.fromRGB(15, 20, 40)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel   = 0
panel.Parent            = screenGui

-- Title
local titleLbl = Instance.new("TextLabel")
titleLbl.Size    = UDim2.new(1, -50, 0, 44)
titleLbl.Position = UDim2.new(0, 10, 0, 5)
titleLbl.BackgroundTransparency = 1
titleLbl.Text    = "Teleport Gate"
titleLbl.Font    = Enum.Font.GothamBold
titleLbl.TextSize = 22
titleLbl.TextColor3 = Color3.fromRGB(100, 220, 255)
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Parent  = panel

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size   = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -42, 0, 4)
closeBtn.Text   = "×"
closeBtn.TextSize = 24
closeBtn.Font   = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = panel

-- Floor list
local floorList = Instance.new("ScrollingFrame")
floorList.Position         = UDim2.new(0, 8, 0, 54)
floorList.Size             = UDim2.new(1, -16, 1, -64)
floorList.BackgroundTransparency = 1
floorList.ScrollBarThickness = 6
floorList.Parent           = panel

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding   = UDim.new(0, 6)
listLayout.Parent    = floorList

local requestTeleportRemote, openGateMenuRemote

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end
	requestTeleportRemote = remotes:WaitForChild("RequestTeleport", 30)
	openGateMenuRemote    = remotes:WaitForChild("OpenGateMenu",    30)

	openGateMenuRemote.OnClientEvent:Connect(function(data)
		local unlockedFloors = data.unlockedFloors or {}
		local currentFloor   = data.currentFloor   or ""

		-- Clear list
		for _, child in ipairs(floorList:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end

		local rowIndex = 0
		for floorKey, floorData in pairs(ZoneRegistry.Floors) do
			if unlockedFloors[floorKey] then
				rowIndex = rowIndex + 1
				local isCurrent = (floorKey == currentFloor)

				local row = Instance.new("Frame")
				row.Size             = UDim2.new(1, -4, 0, 56)
				row.BackgroundColor3 = Color3.fromRGB(30, 40, 70)
				row.BorderSizePixel  = 0
				row.LayoutOrder      = rowIndex
				row.Parent           = floorList

				local floorName = Instance.new("TextLabel")
				floorName.Size   = UDim2.new(0.65, 0, 1, 0)
				floorName.Position = UDim2.new(0, 10, 0, 0)
				floorName.BackgroundTransparency = 1
				floorName.Text   = floorData.Name or floorKey
				floorName.Font   = Enum.Font.Gotham
				floorName.TextSize = 14
				floorName.TextColor3 = Color3.new(1, 1, 1)
				floorName.TextXAlignment = Enum.TextXAlignment.Left
				floorName.TextWrapped = true
				floorName.Parent = row

				if isCurrent then
					local hereLbl = Instance.new("TextLabel")
					hereLbl.Size   = UDim2.new(0.32, 0, 0.6, 0)
					hereLbl.Position = UDim2.new(0.66, 0, 0.2, 0)
					hereLbl.BackgroundTransparency = 1
					hereLbl.Text   = "(here)"
					hereLbl.Font   = Enum.Font.Gotham
					hereLbl.TextSize = 13
					hereLbl.TextColor3 = Color3.fromRGB(150, 220, 150)
					hereLbl.Parent = row
				else
					local teleBtn = Instance.new("TextButton")
					teleBtn.Size   = UDim2.new(0, 110, 0, 34)
					teleBtn.Position = UDim2.new(1, -118, 0.5, -17)
					teleBtn.Text   = "TELEPORT →"
					teleBtn.Font   = Enum.Font.GothamBold
					teleBtn.TextSize = 12
					teleBtn.TextColor3 = Color3.new(1, 1, 1)
					teleBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
					teleBtn.BorderSizePixel  = 0
					teleBtn.Parent = row

					local capturedKey = floorKey
					teleBtn.MouseButton1Click:Connect(function()
						if requestTeleportRemote then
							requestTeleportRemote:FireServer(capturedKey)
						end
						screenGui.Enabled = false
					end)
				end
			end
		end

		floorList.CanvasSize = UDim2.new(0, 0, 0, rowIndex * 62 + 10)
		screenGui.Enabled = true
	end)
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)
