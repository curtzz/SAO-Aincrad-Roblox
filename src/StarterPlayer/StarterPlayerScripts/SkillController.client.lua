-- SkillController.client.lua
-- LocalScript: skill bar (Q/E/R/F) shown during sword combat

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local SwordSkills = require(ReplicatedStorage.Modules.SwordSkills)

local SKILL_KEYBINDS = {
	{ key = Enum.KeyCode.Q, skillKey = "Linear"       },
	{ key = Enum.KeyCode.E, skillKey = "Horizontal"    },
	{ key = Enum.KeyCode.R, skillKey = "SonicLeap"     },
	{ key = Enum.KeyCode.F, skillKey = "VorpalStrike"  },
}

local activateRemote
local function getRemote()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if remotes then
		activateRemote = remotes:WaitForChild("ActivateSkill", 30)
	end
end
task.spawn(getRemote)

-- Build ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "SkillBar"
screenGui.ResetOnSpawn  = false
screenGui.Enabled       = false
screenGui.Parent        = player.PlayerGui

local barFrame = Instance.new("Frame")
barFrame.Name             = "Bar"
barFrame.AnchorPoint      = Vector2.new(0.5, 1)
barFrame.Position         = UDim2.new(0.5, 0, 1, -70)
barFrame.Size             = UDim2.new(0, 280, 0, 60)
barFrame.BackgroundTransparency = 1
barFrame.Parent           = screenGui

local slotButtons = {}
local slotCooldowns = {}  -- [skillKey] = lastUsedTime

local keyLabels = { "Q", "E", "R", "F" }
local skillKeys = { "Linear", "Horizontal", "SonicLeap", "VorpalStrike" }

for i, sk in ipairs(skillKeys) do
	local slot = Instance.new("Frame")
	slot.Name             = sk
	slot.Size             = UDim2.new(0, 60, 0, 60)
	slot.Position         = UDim2.new(0, (i - 1) * 65, 0, 0)
	slot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	slot.BackgroundTransparency = 0.3
	slot.BorderSizePixel  = 1
	slot.Parent           = barFrame

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size  = UDim2.new(1, 0, 0.6, 0)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text  = SwordSkills[sk].Name
	nameLbl.TextColor3 = Color3.new(1, 1, 1)
	nameLbl.Font  = Enum.Font.Gotham
	nameLbl.TextSize = 10
	nameLbl.TextWrapped = true
	nameLbl.Parent = slot

	local keyLbl = Instance.new("TextLabel")
	keyLbl.Size   = UDim2.new(1, 0, 0.4, 0)
	keyLbl.Position = UDim2.new(0, 0, 0.6, 0)
	keyLbl.BackgroundTransparency = 1
	keyLbl.Text   = "[" .. keyLabels[i] .. "]"
	keyLbl.TextColor3 = Color3.fromRGB(180, 180, 255)
	keyLbl.Font   = Enum.Font.GothamBold
	keyLbl.TextSize = 12
	keyLbl.Parent  = slot

	slotButtons[sk] = slot
end

local function isOnCooldown(skillKey)
	local skill = SwordSkills[skillKey]
	local last  = slotCooldowns[skillKey]
	if not last then return false end
	return (tick() - last) < skill.Cooldown
end

local function setCooldown(skillKey)
	slotCooldowns[skillKey] = tick()
	-- Gray out slot briefly
	local slot = slotButtons[skillKey]
	if slot then
		slot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		local skill = SwordSkills[skillKey]
		task.delay(skill.Cooldown, function()
			slot.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		end)
	end
end

-- Show/hide bar based on sword equip
local function checkEquippedTool()
	local char = player.Character
	if not char then
		screenGui.Enabled = false
		return
	end
	for _, item in ipairs(char:GetChildren()) do
		if item:IsA("Tool") and (item.Name:lower():find("sword") or item.Name:lower():find("blade") or item.Name:lower():find("rapier")) then
			screenGui.Enabled = true
			return
		end
	end
	screenGui.Enabled = false
end

player.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(checkEquippedTool)
	char.ChildRemoved:Connect(checkEquippedTool)
end)

if player.Character then
	player.Character.ChildAdded:Connect(checkEquippedTool)
	player.Character.ChildRemoved:Connect(checkEquippedTool)
end

-- Key input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not screenGui.Enabled then return end

	for _, bind in ipairs(SKILL_KEYBINDS) do
		if input.KeyCode == bind.key then
			if isOnCooldown(bind.skillKey) then return end
			setCooldown(bind.skillKey)

			if activateRemote then
				local char = player.Character
				local targetPos = char and char:FindFirstChild("HumanoidRootPart")
					and char.HumanoidRootPart.Position + char.HumanoidRootPart.CFrame.LookVector * 10
					or Vector3.new(0, 0, 0)
				activateRemote:FireServer(bind.skillKey, targetPos)
			end
		end
	end
end)
