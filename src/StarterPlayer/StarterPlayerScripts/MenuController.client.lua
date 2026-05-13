-- MenuController.client.lua
-- LocalScript: "M" key toggles the main SAO-style menu

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local discardRemote
task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if remotes then
		discardRemote = remotes:WaitForChild("DiscardItem", 30)
	end
end)

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "MainMenu"
screenGui.ResetOnSpawn  = false
screenGui.Enabled       = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent        = player.PlayerGui

-- Dark overlay
local overlay = Instance.new("Frame")
overlay.Name                 = "Overlay"
overlay.Size                 = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3     = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.7
overlay.BorderSizePixel      = 0
overlay.Parent               = screenGui

-- Main panel (white, centered)
local panel = Instance.new("Frame")
panel.Name                  = "Panel"
panel.AnchorPoint           = Vector2.new(0.5, 0.5)
panel.Position              = UDim2.new(0.5, 0, 0.5, 0)
panel.Size                  = UDim2.new(0, 600, 0, 450)
panel.BackgroundColor3      = Color3.new(1, 1, 1)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel       = 0
panel.Parent                = screenGui

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name               = "CloseBtn"
closeBtn.Size               = UDim2.new(0, 36, 0, 36)
closeBtn.Position           = UDim2.new(1, -40, 0, 4)
closeBtn.Text               = "×"
closeBtn.TextSize           = 24
closeBtn.Font               = Enum.Font.GothamBold
closeBtn.TextColor3         = Color3.fromRGB(80, 80, 80)
closeBtn.BackgroundTransparency = 1
closeBtn.Parent             = panel

-- Left sidebar
local sidebar = Instance.new("Frame")
sidebar.Name              = "Sidebar"
sidebar.Size              = UDim2.new(0, 80, 1, 0)
sidebar.BackgroundColor3  = Color3.fromRGB(240, 240, 250)
sidebar.BackgroundTransparency = 0.2
sidebar.BorderSizePixel   = 0
sidebar.Parent            = panel

-- Character ring (player name label)
local charRing = Instance.new("TextLabel")
charRing.Name             = "CharRing"
charRing.Size             = UDim2.new(0, 70, 0, 70)
charRing.Position         = UDim2.new(0, 5, 0, 10)
charRing.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
charRing.BorderSizePixel  = 0
charRing.Text             = player.Name:sub(1, 2):upper()
charRing.TextColor3       = Color3.new(1, 1, 1)
charRing.Font             = Enum.Font.GothamBold
charRing.TextSize         = 20
charRing.Parent           = sidebar

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(1, 0)
sidebarCorner.Parent       = charRing

-- Tab buttons
local tabNames = { "Profile", "Items", "Friends", "Map", "Settings" }
local tabButtons = {}
local activeTab = "Profile"

for i, tabName in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Name     = tabName .. "Tab"
	btn.Size     = UDim2.new(0, 60, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, 90 + (i - 1) * 50)
	btn.Text     = tabName:sub(1, 4)
	btn.TextSize = 11
	btn.Font     = Enum.Font.Gotham
	btn.TextColor3 = Color3.fromRGB(50, 50, 50)
	btn.BackgroundColor3 = Color3.fromRGB(200, 210, 240)
	btn.BackgroundTransparency = 0.3
	btn.BorderSizePixel = 0
	btn.Parent   = sidebar
	tabButtons[tabName] = btn
end

-- Col display (top right)
local colLabel = Instance.new("TextLabel")
colLabel.Name    = "ColLabel"
colLabel.Size    = UDim2.new(0, 150, 0, 28)
colLabel.Position = UDim2.new(1, -160, 0, 8)
colLabel.BackgroundTransparency = 1
colLabel.Text    = "Col: 0"
colLabel.TextColor3 = Color3.fromRGB(220, 180, 0)
colLabel.Font    = Enum.Font.GothamBold
colLabel.TextSize = 16
colLabel.TextXAlignment = Enum.TextXAlignment.Right
colLabel.Parent  = panel

-- Content area
local contentArea = Instance.new("Frame")
contentArea.Name             = "Content"
contentArea.Position         = UDim2.new(0, 90, 0, 50)
contentArea.Size             = UDim2.new(1, -100, 1, -60)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel  = 0
contentArea.Parent           = panel

-- Profile tab content
local profileFrame = Instance.new("Frame")
profileFrame.Name   = "ProfileFrame"
profileFrame.Size   = UDim2.new(1, 0, 1, 0)
profileFrame.BackgroundTransparency = 1
profileFrame.Visible = true
profileFrame.Parent = contentArea

local statsFields = { "Level", "XP", "HP", "Col" }
local statsLabels = {}

for i, field in ipairs(statsFields) do
	local lbl = Instance.new("TextLabel")
	lbl.Name     = field .. "Label"
	lbl.Size     = UDim2.new(1, 0, 0, 32)
	lbl.Position = UDim2.new(0, 0, 0, (i - 1) * 38)
	lbl.BackgroundTransparency = 1
	lbl.Text     = field .. ": --"
	lbl.TextColor3 = Color3.fromRGB(30, 30, 30)
	lbl.Font     = Enum.Font.Gotham
	lbl.TextSize = 18
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent   = profileFrame
	statsLabels[field] = lbl
end

-- Items tab content
local itemsFrame = Instance.new("ScrollingFrame")
itemsFrame.Name         = "ItemsFrame"
itemsFrame.Size         = UDim2.new(1, 0, 1, 0)
itemsFrame.BackgroundTransparency = 1
itemsFrame.ScrollBarThickness = 6
itemsFrame.Visible      = false
itemsFrame.Parent       = contentArea

local itemListLayout = Instance.new("UIListLayout")
itemListLayout.SortOrder   = Enum.SortOrder.LayoutOrder
itemListLayout.Padding     = UDim.new(0, 4)
itemListLayout.Parent      = itemsFrame

-- Confirm modal for delete
local confirmModal = Instance.new("Frame")
confirmModal.Name               = "ConfirmModal"
confirmModal.AnchorPoint        = Vector2.new(0.5, 0.5)
confirmModal.Position           = UDim2.new(0.5, 0, 0.5, 0)
confirmModal.Size               = UDim2.new(0, 280, 0, 130)
confirmModal.BackgroundColor3   = Color3.fromRGB(240, 240, 250)
confirmModal.BorderSizePixel    = 0
confirmModal.Visible            = false
confirmModal.ZIndex             = 10
confirmModal.Parent             = screenGui

local modalMsg = Instance.new("TextLabel")
modalMsg.Size  = UDim2.new(1, -10, 0, 40)
modalMsg.Position = UDim2.new(0, 5, 0, 10)
modalMsg.BackgroundTransparency = 1
modalMsg.Text  = "Discard this item?"
modalMsg.Font  = Enum.Font.Gotham
modalMsg.TextSize = 16
modalMsg.TextColor3 = Color3.fromRGB(40, 40, 40)
modalMsg.Parent = confirmModal

local modalConfirmBtn = Instance.new("TextButton")
modalConfirmBtn.Size     = UDim2.new(0, 100, 0, 36)
modalConfirmBtn.Position = UDim2.new(0, 20, 0, 75)
modalConfirmBtn.Text     = "Confirm"
modalConfirmBtn.Font     = Enum.Font.GothamBold
modalConfirmBtn.TextSize = 15
modalConfirmBtn.TextColor3 = Color3.new(1, 1, 1)
modalConfirmBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
modalConfirmBtn.ZIndex   = 11
modalConfirmBtn.Parent   = confirmModal

local modalCancelBtn = Instance.new("TextButton")
modalCancelBtn.Size     = UDim2.new(0, 100, 0, 36)
modalCancelBtn.Position = UDim2.new(0, 155, 0, 75)
modalCancelBtn.Text     = "× Close"
modalCancelBtn.Font     = Enum.Font.GothamBold
modalCancelBtn.TextSize = 15
modalCancelBtn.TextColor3 = Color3.fromRGB(40, 40, 40)
modalCancelBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
modalCancelBtn.ZIndex   = 11
modalCancelBtn.Parent   = confirmModal

local pendingDiscardId = nil

local function closeModal()
	confirmModal.Visible = false
	pendingDiscardId = nil
end

modalCancelBtn.MouseButton1Click:Connect(closeModal)

-- Click outside modal closes it
overlay.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if confirmModal.Visible then
			closeModal()
		end
	end
end)

modalConfirmBtn.MouseButton1Click:Connect(function()
	if pendingDiscardId and discardRemote then
		discardRemote:FireServer(pendingDiscardId)
	end
	closeModal()
	-- Refresh will happen on next poll
end)

local function buildItemRow(itemId, index)
	local row = Instance.new("Frame")
	row.Name             = "ItemRow_" .. index
	row.Size             = UDim2.new(1, -10, 0, 44)
	row.BackgroundColor3 = Color3.fromRGB(230, 235, 250)
	row.BackgroundTransparency = 0.2
	row.BorderSizePixel  = 0
	row.LayoutOrder      = index

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size   = UDim2.new(0.55, 0, 1, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text   = itemId
	nameLbl.Font   = Enum.Font.Gotham
	nameLbl.TextSize = 14
	nameLbl.TextColor3 = Color3.fromRGB(30, 30, 30)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Position = UDim2.new(0, 8, 0, 0)
	nameLbl.Parent = row

	local useBtn = Instance.new("TextButton")
	useBtn.Size   = UDim2.new(0, 70, 0, 30)
	useBtn.Position = UDim2.new(0.58, 0, 0.5, -15)
	useBtn.Text   = "○ Use"
	useBtn.Font   = Enum.Font.Gotham
	useBtn.TextSize = 13
	useBtn.TextColor3 = Color3.new(1, 1, 1)
	useBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
	useBtn.BorderSizePixel = 0
	useBtn.Parent = row

	local delBtn = Instance.new("TextButton")
	delBtn.Size   = UDim2.new(0, 70, 0, 30)
	delBtn.Position = UDim2.new(0.58, 78, 0.5, -15)
	delBtn.Text   = "✕ Del"
	delBtn.Font   = Enum.Font.Gotham
	delBtn.TextSize = 13
	delBtn.TextColor3 = Color3.new(1, 1, 1)
	delBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	delBtn.BorderSizePixel = 0
	delBtn.Parent = row

	delBtn.MouseButton1Click:Connect(function()
		pendingDiscardId = itemId
		modalMsg.Text    = 'Discard "' .. itemId .. '"?'
		confirmModal.Visible = true
	end)

	return row
end

local function refreshItemList()
	-- Clear existing rows
	for _, child in ipairs(itemsFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local inventory = player:GetAttribute("Inventory") or ""
	-- Inventory is not an attribute since tables can't be attributes;
	-- we read from backpack tool names as a proxy
	local items = {}
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				table.insert(items, tool.Name)
			end
		end
	end
	-- Also check character equipped tool
	local char = player.Character
	if char then
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") then
				table.insert(items, tool.Name)
			end
		end
	end

	for i, itemId in ipairs(items) do
		local row = buildItemRow(itemId, i)
		row.Parent = itemsFrame
	end

	itemsFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 48 + 10)
end

local function refreshStats()
	local level = player:GetAttribute("Level") or 1
	local xp    = player:GetAttribute("XP") or 0
	local hp    = player:GetAttribute("CurrentHP") or 100
	local maxhp = player:GetAttribute("MaxHP") or 100
	local col   = player:GetAttribute("Col") or 0

	if statsLabels["Level"] then statsLabels["Level"].Text = "Level: " .. level end
	if statsLabels["XP"]    then statsLabels["XP"].Text    = "XP: " .. xp end
	if statsLabels["HP"]    then statsLabels["HP"].Text    = "HP: " .. hp .. " / " .. maxhp end
	if statsLabels["Col"]   then statsLabels["Col"].Text   = "Col: " .. col end
	colLabel.Text = "Col: " .. col
end

local function setTab(tabName)
	activeTab = tabName
	profileFrame.Visible = (tabName == "Profile")
	itemsFrame.Visible   = (tabName == "Items")
	if tabName == "Items" then
		refreshItemList()
	end
end

for tabName, btn in pairs(tabButtons) do
	btn.MouseButton1Click:Connect(function()
		setTab(tabName)
	end)
end

-- Poll stats every 0.5 seconds while menu is open
task.spawn(function()
	while true do
		task.wait(0.5)
		if screenGui.Enabled then
			refreshStats()
			if activeTab == "Items" then
				refreshItemList()
			end
		end
	end
end)

-- Toggle open/close
closeBtn.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.M then
		screenGui.Enabled = not screenGui.Enabled
		if screenGui.Enabled then
			refreshStats()
			setTab("Profile")
		end
	end
end)
