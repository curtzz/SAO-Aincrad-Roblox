-- Workspace/IllfangBoss/BossHealthBar  (Server Script)
local boss     = script.Parent
local humanoid = boss:WaitForChild("Humanoid")
local hrp      = boss:WaitForChild("HumanoidRootPart")

local BOSS_NAME = "Illfang the Kobold Lord"
local TITLE     = "Floor 1 Boss"

local billboard = Instance.new("BillboardGui")
billboard.Name             = "BossHPBar"
billboard.Adornee          = hrp
billboard.Size             = UDim2.new(0, 320, 0, 70)
billboard.StudsOffsetWorldSpace = Vector3.new(0, 8, 0)
billboard.AlwaysOnTop      = true
billboard.LightInfluence   = 0
billboard.MaxDistance      = 250
billboard.Parent           = hrp

local title = Instance.new("TextLabel")
title.Size                   = UDim2.new(1, 0, 0, 16)
title.Position               = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text                   = TITLE
title.Font                   = Enum.Font.GothamBold
title.TextColor3             = Color3.fromRGB(255, 200, 80)
title.TextSize               = 14
title.TextStrokeColor3       = Color3.new(0, 0, 0)
title.TextStrokeTransparency = 0
title.Parent                 = billboard

local name = Instance.new("TextLabel")
name.Size                   = UDim2.new(1, 0, 0, 22)
name.Position               = UDim2.new(0, 0, 0, 16)
name.BackgroundTransparency = 1
name.Text                   = BOSS_NAME
name.Font                   = Enum.Font.GothamBlack
name.TextColor3             = Color3.new(1, 1, 1)
name.TextSize               = 18
name.TextStrokeColor3       = Color3.new(0, 0, 0)
name.TextStrokeTransparency = 0
name.Parent                 = billboard

local track = Instance.new("Frame")
track.Size              = UDim2.new(1, -20, 0, 16)
track.Position          = UDim2.new(0, 10, 1, -22)
track.BackgroundColor3  = Color3.fromRGB(30, 30, 30)
track.BorderSizePixel   = 0
track.Parent            = billboard

local trackStroke = Instance.new("UIStroke", track)
trackStroke.Color     = Color3.fromRGB(220, 220, 220)
trackStroke.Thickness = 1

local fill = Instance.new("Frame")
fill.Size             = UDim2.new(1, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
fill.BorderSizePixel  = 0
fill.Parent           = track

local fillGrad = Instance.new("UIGradient", fill)
fillGrad.Rotation = 90
fillGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 100, 100)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 50, 50)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(140, 20, 20)),
})

local hpText = Instance.new("TextLabel")
hpText.Size                   = UDim2.fromScale(1, 1)
hpText.BackgroundTransparency = 1
hpText.Text                   = ""
hpText.Font                   = Enum.Font.GothamBold
hpText.TextColor3             = Color3.new(1, 1, 1)
hpText.TextSize               = 12
hpText.TextStrokeColor3       = Color3.new(0, 0, 0)
hpText.TextStrokeTransparency = 0
hpText.Parent                 = track

local TweenService = game:GetService("TweenService")

local function refresh()
	local pct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
	TweenService:Create(fill, TweenInfo.new(0.3), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
	hpText.Text = ("%d / %d"):format(math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
end

refresh()
humanoid.HealthChanged:Connect(refresh)

humanoid.Died:Connect(function()
	billboard.Enabled = false
end)
