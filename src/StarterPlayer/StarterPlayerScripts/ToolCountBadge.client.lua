-- ToolCountBadge.client.lua
-- LocalScript: shows a badge in the top-right counting backpack items

local Players = game:GetService("Players")
local player  = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "ToolCountBadge"
screenGui.ResetOnSpawn  = false
screenGui.Parent        = player.PlayerGui

local badgeFrame = Instance.new("Frame")
badgeFrame.Name             = "BadgeFrame"
badgeFrame.AnchorPoint      = Vector2.new(1, 0)
badgeFrame.Position         = UDim2.new(1, -10, 0, 10)
badgeFrame.Size             = UDim2.new(0, 90, 0, 36)
badgeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
badgeFrame.BackgroundTransparency = 0.35
badgeFrame.BorderSizePixel  = 0
badgeFrame.Parent           = screenGui

local countLabel = Instance.new("TextLabel")
countLabel.Name              = "CountLabel"
countLabel.Size              = UDim2.new(1, 0, 1, 0)
countLabel.BackgroundTransparency = 1
countLabel.Text              = "Items: 0"
countLabel.TextColor3        = Color3.new(1, 1, 1)
countLabel.Font              = Enum.Font.Gotham
countLabel.TextSize          = 14
countLabel.Parent            = badgeFrame

local function updateCount()
	local count = 0
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				count = count + 1
			end
		end
	end
	-- Also count equipped tool
	local char = player.Character
	if char then
		for _, item in ipairs(char:GetChildren()) do
			if item:IsA("Tool") then
				count = count + 1
			end
		end
	end
	countLabel.Text = "Items: " .. count
end

local function watchBackpack(backpack)
	updateCount()
	backpack.ChildAdded:Connect(updateCount)
	backpack.ChildRemoved:Connect(updateCount)
end

-- Watch current backpack
local bp = player:FindFirstChildOfClass("Backpack")
if bp then watchBackpack(bp) end

player.ChildAdded:Connect(function(child)
	if child:IsA("Backpack") then
		watchBackpack(child)
	end
end)

player.CharacterAdded:Connect(function(char)
	updateCount()
	char.ChildAdded:Connect(updateCount)
	char.ChildRemoved:Connect(updateCount)
end)

if player.Character then
	player.Character.ChildAdded:Connect(updateCount)
	player.Character.ChildRemoved:Connect(updateCount)
end

updateCount()
