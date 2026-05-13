-- GateBuilder.server.lua
-- Script: builds teleport gates for each floor defined in ZoneRegistry

local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZoneRegistry = require(ReplicatedStorage.Modules.ZoneRegistry)

local function addBillboard(part, text)
	local bb = Instance.new("BillboardGui")
	bb.Size        = UDim2.new(0, 220, 0, 45)
	bb.StudsOffset = Vector3.new(0, 2, 0)
	bb.AlwaysOnTop = false
	local lbl = Instance.new("TextLabel")
	lbl.Size                  = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text                  = text
	lbl.TextColor3            = Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency = 0
	lbl.TextStrokeColor3      = Color3.new(0, 0, 0)
	lbl.Font                  = Enum.Font.GothamBold
	lbl.TextScaled            = true
	lbl.Parent                = bb
	bb.Parent                 = part
end

local function makePart(name, size, cframe, color, anchored, canCollide, transparency, material)
	local p = Instance.new("Part")
	p.Name         = name
	p.Size         = size
	p.CFrame       = cframe
	p.BrickColor   = BrickColor.new(color or "Dark stone grey")
	p.Anchored     = anchored ~= false
	p.CanCollide   = canCollide ~= false
	p.Transparency = transparency or 0
	if material then
		pcall(function() p.Material = Enum.Material[material] end)
	end
	return p
end

-- Ensure Gates folder
local gatesFolder = Workspace:FindFirstChild("Gates")
if not gatesFolder then
	gatesFolder = Instance.new("Folder")
	gatesFolder.Name   = "Gates"
	gatesFolder.Parent = Workspace
end

for floorKey, floorData in pairs(ZoneRegistry.Floors) do
	local gateFolder = Instance.new("Folder")
	gateFolder.Name   = floorKey .. "Gate"
	gateFolder.Parent = gatesFolder

	local pos = floorData.GatePosition  -- e.g. Vector3.new(0, 0, -30)

	-- Left pillar
	local leftPillar = makePart("LeftPillar",
		Vector3.new(3, 12, 3),
		CFrame.new(pos + Vector3.new(-4, 6, 0)),
		"Dark stone grey")
	leftPillar.Parent = gateFolder

	-- Right pillar
	local rightPillar = makePart("RightPillar",
		Vector3.new(3, 12, 3),
		CFrame.new(pos + Vector3.new(4, 6, 0)),
		"Dark stone grey")
	rightPillar.Parent = gateFolder

	-- Top arch
	local topArch = makePart("TopArch",
		Vector3.new(11, 3, 3),
		CFrame.new(pos + Vector3.new(0, 12, 0)),
		"Dark stone grey")
	topArch.Parent = gateFolder
	addBillboard(topArch, "Teleport Gate")

	-- Portal (neon cyan, no collision, semi-transparent)
	local portal = makePart("Portal",
		Vector3.new(8, 10, 0.5),
		CFrame.new(pos + Vector3.new(0, 5.5, 0)),
		"Cyan",
		true,
		false,
		0.4,
		"Neon")
	portal.Parent = gateFolder
end

print("[GateBuilder] Gates created")
