-- HPGUI.client.lua
-- LocalScript: SAO-style HP bar in the bottom-left corner

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local StarterGui    = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- Disable the default Roblox health bar
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
end)

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "HPGUI"
screenGui.ResetOnSpawn  = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent        = player.PlayerGui

-- Outer dark frame (bottom-left)
local frame = Instance.new("Frame")
frame.Name              = "HPFrame"
frame.AnchorPoint       = Vector2.new(0, 1)
frame.Position          = UDim2.new(0, 10, 1, -60)
frame.Size              = UDim2.new(0, 300, 0, 40)
frame.BackgroundColor3  = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel   = 0
frame.Parent            = screenGui

-- HP bar fill (bright red)
local hpFill = Instance.new("Frame")
hpFill.Name              = "HPFill"
hpFill.AnchorPoint       = Vector2.new(0, 0)
hpFill.Position          = UDim2.new(0, 2, 0, 2)
hpFill.Size              = UDim2.new(1, -4, 1, -4)
hpFill.BackgroundColor3  = Color3.fromRGB(220, 30, 30)
hpFill.BorderSizePixel   = 0
hpFill.Parent            = frame

-- HP text label
local hpText = Instance.new("TextLabel")
hpText.Name                 = "HPText"
hpText.Size                 = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.Text                 = "HP: 100 / 100"
hpText.TextColor3           = Color3.new(1, 1, 1)
hpText.TextStrokeTransparency = 0.5
hpText.Font                 = Enum.Font.GothamBold
hpText.TextSize             = 16
hpText.ZIndex               = 3
hpText.Parent               = frame

-- Update every heartbeat
RunService.Heartbeat:Connect(function()
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local hp    = math.max(0, humanoid.Health)
	local maxHp = math.max(1, humanoid.MaxHealth)
	local ratio = hp / maxHp

	hpFill.Size = UDim2.new(ratio, -4 * ratio, 1, -4)
	hpText.Text = string.format("HP: %d / %d", math.ceil(hp), math.ceil(maxHp))

	-- Color shift: green → yellow → red
	if ratio > 0.5 then
		hpFill.BackgroundColor3 = Color3.fromRGB(220, 30, 30)
	elseif ratio > 0.25 then
		hpFill.BackgroundColor3 = Color3.fromRGB(220, 140, 30)
	else
		hpFill.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
	end
end)
