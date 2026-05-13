-- BossHealthBar.server.lua
-- BillboardGui showing HP bar, phase indicator, and boss announcements

local TweenService = game:GetService("TweenService")

local boss     = script.Parent
local humanoid = boss:WaitForChild("Humanoid")
local hrp      = boss:WaitForChild("HumanoidRootPart")

local BOSS_NAME = "Illfang the Kobold Lord"

-- ================================================================
-- BUILD BILLBOARD
-- ================================================================
local billboard = Instance.new("BillboardGui")
billboard.Name                  = "BossHPBar"
billboard.Adornee               = hrp
billboard.Size                  = UDim2.new(0, 340, 0, 92)
billboard.StudsOffsetWorldSpace = Vector3.new(0, 9, 0)
billboard.AlwaysOnTop           = true
billboard.LightInfluence        = 0
billboard.MaxDistance           = 300
billboard.Parent                = hrp

-- Title row: "Floor 1 Boss" + phase tag
local titleRow = Instance.new("Frame")
titleRow.Size                   = UDim2.new(1, 0, 0, 18)
titleRow.Position               = UDim2.new(0, 0, 0, 0)
titleRow.BackgroundTransparency = 1
titleRow.Parent                 = billboard

local titleLbl = Instance.new("TextLabel")
titleLbl.Size                   = UDim2.new(0.65, 0, 1, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text                   = "Floor 1 Boss"
titleLbl.Font                   = Enum.Font.GothamBold
titleLbl.TextColor3             = Color3.fromRGB(255, 200, 80)
titleLbl.TextSize               = 13
titleLbl.TextXAlignment         = Enum.TextXAlignment.Left
titleLbl.TextStrokeColor3       = Color3.new(0, 0, 0)
titleLbl.TextStrokeTransparency = 0
titleLbl.Parent                 = titleRow

local phaseLbl = Instance.new("TextLabel")
phaseLbl.Name                   = "PhaseLabel"
phaseLbl.Size                   = UDim2.new(0.35, 0, 1, 0)
phaseLbl.Position               = UDim2.new(0.65, 0, 0, 0)
phaseLbl.BackgroundTransparency = 1
phaseLbl.Text                   = "Phase I"
phaseLbl.Font                   = Enum.Font.GothamBold
phaseLbl.TextColor3             = Color3.fromRGB(180, 200, 255)
phaseLbl.TextSize               = 12
phaseLbl.TextXAlignment         = Enum.TextXAlignment.Right
phaseLbl.TextStrokeColor3       = Color3.new(0, 0, 0)
phaseLbl.TextStrokeTransparency = 0
phaseLbl.Parent                 = titleRow

-- Boss name
local nameLbl = Instance.new("TextLabel")
nameLbl.Size                   = UDim2.new(1, 0, 0, 22)
nameLbl.Position               = UDim2.new(0, 0, 0, 18)
nameLbl.BackgroundTransparency = 1
nameLbl.Text                   = BOSS_NAME
nameLbl.Font                   = Enum.Font.GothamBlack
nameLbl.TextColor3             = Color3.new(1, 1, 1)
nameLbl.TextSize               = 18
nameLbl.TextStrokeColor3       = Color3.new(0, 0, 0)
nameLbl.TextStrokeTransparency = 0
nameLbl.Parent                 = billboard

-- HP bar track
local track = Instance.new("Frame")
track.Size              = UDim2.new(1, -16, 0, 16)
track.Position          = UDim2.new(0, 8, 0, 42)
track.BackgroundColor3  = Color3.fromRGB(25, 25, 25)
track.BorderSizePixel   = 0
track.Parent            = billboard

local trackStroke = Instance.new("UIStroke", track)
trackStroke.Color     = Color3.fromRGB(200, 200, 200)
trackStroke.Thickness = 1

local fill = Instance.new("Frame")
fill.Size             = UDim2.new(1, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
fill.BorderSizePixel  = 0
fill.Parent           = track

local fillGrad = Instance.new("UIGradient", fill)
fillGrad.Rotation = 90
fillGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 110, 110)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 50,  50)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(130, 15,  15)),
})

local hpText = Instance.new("TextLabel")
hpText.Size                   = UDim2.fromScale(1, 1)
hpText.BackgroundTransparency = 1
hpText.Text                   = ""
hpText.Font                   = Enum.Font.GothamBold
hpText.TextColor3             = Color3.new(1, 1, 1)
hpText.TextSize               = 11
hpText.TextStrokeColor3       = Color3.new(0, 0, 0)
hpText.TextStrokeTransparency = 0
hpText.Parent                 = track

-- Announcement line below the bar
local announceLbl = Instance.new("TextLabel")
announceLbl.Name                   = "AnnounceLbl"
announceLbl.Size                   = UDim2.new(1, 0, 0, 22)
announceLbl.Position               = UDim2.new(0, 0, 0, 62)
announceLbl.BackgroundTransparency = 1
announceLbl.Text                   = ""
announceLbl.Font                   = Enum.Font.GothamBold
announceLbl.TextColor3             = Color3.fromRGB(255, 230, 100)
announceLbl.TextSize               = 13
announceLbl.TextStrokeColor3       = Color3.new(0, 0, 0)
announceLbl.TextStrokeTransparency = 0
announceLbl.TextTransparency       = 0
announceLbl.Parent                 = billboard

-- ================================================================
-- PHASE COLORS
-- ================================================================
local PHASE_COLORS = {
	[1] = {
		fill = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 110, 110)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 50,  50)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(130, 15,  15)),
		}),
		phaseText  = "Phase I",
		phaseColor = Color3.fromRGB(180, 200, 255),
	},
	[2] = {
		fill = ColorSequence.new({
			ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 180, 80)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 100, 20)),
			ColorSequenceKeypoint.new(1,   Color3.fromRGB(140, 40,  0)),
		}),
		phaseText  = "Phase II  ⚠ ENRAGED",
		phaseColor = Color3.fromRGB(255, 140, 40),
	},
}

-- ================================================================
-- UPDATE HP BAR
-- ================================================================
local function refreshHP()
	local pct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
	TweenService:Create(fill, TweenInfo.new(0.25), { Size = UDim2.new(pct, 0, 1, 0) }):Play()
	hpText.Text = ("%d / %d"):format(math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
end

refreshHP()
humanoid.HealthChanged:Connect(refreshHP)

-- ================================================================
-- PHASE ATTRIBUTE WATCH
-- ================================================================
boss:GetAttributeChangedSignal("Phase"):Connect(function()
	local p = boss:GetAttribute("Phase") or 1
	local cfg = PHASE_COLORS[p]
	if not cfg then return end

	phaseLbl.Text       = cfg.phaseText
	phaseLbl.TextColor3 = cfg.phaseColor
	fillGrad.Color      = cfg.fill

	-- Flash the name red on phase 2
	if p == 2 then
		TweenService:Create(nameLbl, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 3, true),
			{ TextColor3 = Color3.fromRGB(255, 80, 20) }):Play()
	end
end)

-- ================================================================
-- BOSS MESSAGE WATCH
-- ================================================================
local announceTween

boss:GetAttributeChangedSignal("BossMessage"):Connect(function()
	local msg = boss:GetAttribute("BossMessage") or ""
	if announceTween then announceTween:Cancel() end

	if msg == "" then
		announceLbl.Text = ""
		return
	end

	announceLbl.Text             = msg
	announceLbl.TextTransparency = 0

	announceTween = TweenService:Create(
		announceLbl,
		TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 2.5),
		{ TextTransparency = 1 }
	)
	announceTween:Play()
end)

-- ================================================================
-- DEATH
-- ================================================================
humanoid.Died:Connect(function()
	billboard.Enabled = false
end)
