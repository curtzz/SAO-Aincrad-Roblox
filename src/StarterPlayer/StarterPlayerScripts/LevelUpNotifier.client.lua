-- LevelUpNotifier.client.lua
-- LocalScript: shows a "LEVEL UP!" notification when LevelUp RemoteEvent fires

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- Build ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name          = "LevelUpNotifier"
screenGui.ResetOnSpawn  = false
screenGui.Parent        = player.PlayerGui

local notifLabel = Instance.new("TextLabel")
notifLabel.Name              = "NotifLabel"
notifLabel.AnchorPoint       = Vector2.new(0.5, 0.5)
notifLabel.Position          = UDim2.new(0.5, 0, 0.4, 0)
notifLabel.Size              = UDim2.new(0, 400, 0, 80)
notifLabel.BackgroundTransparency = 1
notifLabel.Text              = ""
notifLabel.TextColor3        = Color3.new(1, 1, 1)
notifLabel.TextStrokeTransparency = 0.3
notifLabel.Font              = Enum.Font.GothamBold
notifLabel.TextSize          = 40
notifLabel.TextXAlignment     = Enum.TextXAlignment.Center
notifLabel.Visible           = false
notifLabel.Parent            = screenGui

local function showLevelUp(newLevel)
	notifLabel.Text        = "LEVEL UP!  →  Level " .. tostring(newLevel)
	notifLabel.TextTransparency = 0
	notifLabel.Visible     = true

	task.delay(3, function()
		-- Fade out over 0.5s
		local tween = TweenService:Create(notifLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 1 })
		tween:Play()
		tween.Completed:Connect(function()
			notifLabel.Visible = false
		end)
	end)
end

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end
	local levelUpRemote = remotes:WaitForChild("LevelUp", 30)
	if levelUpRemote then
		levelUpRemote.OnClientEvent:Connect(function(newLevel)
			showLevelUp(newLevel)
		end)
	end
end)
