-- MapBuilder.server.lua
-- Script: builds Floor1Map geometry in Workspace

local Workspace = game:GetService("Workspace")

local function makePart(name, size, position, color, anchored, canCollide, transparency, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = CFrame.new(position)
	p.BrickColor = BrickColor.new(color or "Medium stone grey")
	p.Anchored = anchored ~= false
	p.CanCollide = canCollide ~= false
	p.Transparency = transparency or 0
	if material then
		p.Material = Enum.Material[material] or Enum.Material.SmoothPlastic
	end
	if shape == "Cylinder" then
		p.Shape = Enum.PartType.Cylinder
	end
	return p
end

local function addBillboard(part, text, studOffset, size)
	local bb = Instance.new("BillboardGui")
	bb.Name = "Billboard"
	bb.Adornee = part
	bb.StudsOffset = studOffset or Vector3.new(0, 3, 0)
	bb.Size = size or UDim2.new(0, 200, 0, 50)
	bb.AlwaysOnTop = false
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency = 0
	lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Parent = bb
	bb.Parent = part
end

local mapFolder = Workspace:FindFirstChild("Floor1Map")
if mapFolder then mapFolder:Destroy() end
mapFolder = Instance.new("Folder")
mapFolder.Name = "Floor1Map"
mapFolder.Parent = Workspace

-- =====================
-- TOWN (center ~0,0,0)
-- =====================
local townFolder = Instance.new("Folder")
townFolder.Name = "Town"
townFolder.Parent = mapFolder

-- Ground plate
local townGround = makePart("Ground", Vector3.new(200, 1, 200), Vector3.new(0, 0, 0), "Medium stone grey")
townGround.Parent = townFolder

-- Town wall ring (4 walls, 180x180 perimeter, height 12)
local walls = {
	{ name="WallNorth", size=Vector3.new(180, 12, 2), pos=Vector3.new(0,  6, -90) },
	{ name="WallSouth", size=Vector3.new(180, 12, 2), pos=Vector3.new(0,  6,  90) },
	{ name="WallWest",  size=Vector3.new(2,  12, 180), pos=Vector3.new(-90, 6, 0) },
	{ name="WallEast",  size=Vector3.new(2,  12, 180), pos=Vector3.new( 90, 6, 0) },
}
for _, wdef in ipairs(walls) do
	local w = makePart(wdef.name, wdef.size, wdef.pos, "Medium stone grey")
	w.Parent = townFolder
end

-- Gate archway opening in south wall at (0,6,-90)
-- We cut the north wall by replacing it with two segments flanking an opening
-- Remove WallNorth and add two flanking walls
townFolder:FindFirstChild("WallNorth"):Destroy()
local gateOpeningWidth = 12
local wallHalfLen = (180 - gateOpeningWidth) / 2  -- 84 each side
local wallNorthLeft = makePart("WallNorthLeft",
	Vector3.new(wallHalfLen, 12, 2),
	Vector3.new(-(gateOpeningWidth/2 + wallHalfLen/2), 6, -90),
	"Medium stone grey")
wallNorthLeft.Parent = townFolder
local wallNorthRight = makePart("WallNorthRight",
	Vector3.new(wallHalfLen, 12, 2),
	Vector3.new((gateOpeningWidth/2 + wallHalfLen/2), 6, -90),
	"Medium stone grey")
wallNorthRight.Parent = townFolder
-- Gate archway top beam
local gateArch = makePart("GateArch", Vector3.new(gateOpeningWidth + 2, 3, 2), Vector3.new(0, 13, -90), "Medium stone grey")
gateArch.Parent = townFolder
addBillboard(gateArch, "Town of Beginnings", Vector3.new(0, 4, 0), UDim2.new(0, 260, 0, 50))

-- 4 market stall structures (L-shapes at ±30, 0, ±20)
local stallPositions = {
	Vector3.new( 30, 0,  20),
	Vector3.new(-30, 0,  20),
	Vector3.new( 30, 0, -20),
	Vector3.new(-30, 0, -20),
}
for i, sp in ipairs(stallPositions) do
	-- Back wall
	local back = makePart("StallBack"..i, Vector3.new(8, 5, 1), sp + Vector3.new(0, 2.5, -4), "Reddish brown")
	back.Parent = townFolder
	-- Side wall
	local side = makePart("StallSide"..i, Vector3.new(1, 5, 8), sp + Vector3.new(-3.5, 2.5, 0), "Reddish brown")
	side.Parent = townFolder
	-- Roof
	local roof = makePart("StallRoof"..i, Vector3.new(9, 0.5, 9), sp + Vector3.new(-1, 5.25, -1), "Dark orange")
	roof.Parent = townFolder
	-- Counter
	local counter = makePart("StallCounter"..i, Vector3.new(8, 2, 1), sp + Vector3.new(0, 1, 0), "Light stone grey")
	counter.Parent = townFolder
end

-- Central plaza fountain: cylinder, at (0,1,0), stone gray
local fountain = makePart("Fountain", Vector3.new(10, 3, 10), Vector3.new(0, 1.5, 0), "Light stone grey", true, true, 0, "SmoothPlastic", "Cylinder")
fountain.Parent = townFolder

-- Crystal respawn pillar: bright blue neon at (0,3,5)
local respawnPillar = makePart("RespawnPillar", Vector3.new(2, 6, 2), Vector3.new(0, 3, 5), "Cyan", true, true, 0, "Neon")
respawnPillar.Parent = townFolder

-- =====================
-- FIELD (center ~0,0,200)
-- =====================
local fieldFolder = Instance.new("Folder")
fieldFolder.Name = "Field"
fieldFolder.Parent = mapFolder

-- Ground plate
local fieldGround = makePart("Ground", Vector3.new(300, 1, 200), Vector3.new(0, 0, 200), "Medium stone grey")
fieldGround.BrickColor = BrickColor.new("Sand green")
fieldGround.Parent = fieldFolder

-- SpawnMarkers
local spawnPositions = {
	Vector3.new( 20, 1, 180),
	Vector3.new(-20, 1, 190),
	Vector3.new( 40, 1, 210),
	Vector3.new(-40, 1, 220),
	Vector3.new( 10, 1, 240),
	Vector3.new(-10, 1, 250),
	Vector3.new( 30, 1, 260),
	Vector3.new(-30, 1, 270),
}
for idx, sp in ipairs(spawnPositions) do
	local marker = makePart("SpawnMarker", Vector3.new(2, 0.5, 2), sp, "Bright red", true, false)
	marker.Transparency = 0.8
	marker.Parent = fieldFolder
end

-- Rocky terrain chunks
local rockPositions = {
	Vector3.new( 60, 2, 185),
	Vector3.new(-55, 2, 215),
	Vector3.new( 50, 2, 245),
	Vector3.new(-45, 2, 265),
	Vector3.new( 10, 2, 300),
}
for i, rp in ipairs(rockPositions) do
	local rock = makePart("Rock"..i, Vector3.new(10, 4, 10), rp, "Dark stone grey", true, true, 0, "SmoothPlastic")
	rock.Parent = fieldFolder
end

-- Path connecting Town to Tolbana (series of slightly lighter plates)
for i = 0, 4 do
	local pathSeg = makePart("PathSegment"..i,
		Vector3.new(8, 0.6, 40),
		Vector3.new(0, 0.3, 120 + i * 50),
		"Light stone grey")
	pathSeg.Parent = fieldFolder
end

-- =====================
-- TOLBANA (center ~0,0,420)
-- =====================
local tolbanaFolder = Instance.new("Folder")
tolbanaFolder.Name = "Tolbana"
tolbanaFolder.Parent = mapFolder

-- Ground plate
local tolbanaGround = makePart("Ground", Vector3.new(150, 1, 150), Vector3.new(0, 0, 420), "Sand green")
tolbanaGround.Parent = tolbanaFolder

-- 6 town buildings
local buildingDefs = {
	{ pos=Vector3.new( 35, 0, 390), size=Vector3.new(14, 12, 14) },
	{ pos=Vector3.new(-35, 0, 390), size=Vector3.new(12, 10, 12) },
	{ pos=Vector3.new( 40, 0, 420), size=Vector3.new(10,  8, 10) },
	{ pos=Vector3.new(-40, 0, 420), size=Vector3.new(16, 16, 12) },
	{ pos=Vector3.new( 30, 0, 450), size=Vector3.new(12, 14, 14) },
	{ pos=Vector3.new(-30, 0, 450), size=Vector3.new(14, 10, 10) },
}
for i, bd in ipairs(buildingDefs) do
	local building = makePart("Building"..i, bd.size, bd.pos + Vector3.new(0, bd.size.Y/2, 0), "Medium stone grey")
	building.Parent = tolbanaFolder
	local roof = makePart("Roof"..i, bd.size + Vector3.new(1, 0, 1), bd.pos + Vector3.new(0, bd.size.Y + 0.5, 0), "Reddish brown")
	roof.Size = Vector3.new(bd.size.X + 1, 1, bd.size.Z + 1)
	roof.Parent = tolbanaFolder
end

-- Raid meeting area: open courtyard, circular marker
local raidMarker = makePart("RaidMeetingCircle", Vector3.new(20, 0.2, 20), Vector3.new(0, 0.6, 420), "Bright blue", true, false, 0.5)
raidMarker.Shape = Enum.PartType.Cylinder
raidMarker.Parent = tolbanaFolder
addBillboard(raidMarker, "Raid Meeting Point", Vector3.new(0, 3, 0), UDim2.new(0, 200, 0, 40))

-- =====================
-- LABYRINTH (center ~0,0,600)
-- =====================
local labFolder = Instance.new("Folder")
labFolder.Name = "Labyrinth"
labFolder.Parent = mapFolder

-- Ground plate
local labGround = makePart("Ground", Vector3.new(200, 1, 200), Vector3.new(0, 0, 600), "Dark stone grey")
labGround.Parent = labFolder

-- Maze walls: grid of thin tall parts (height 20) forming corridors
local mazeWallDefs = {
	-- Horizontal corridors
	{ pos=Vector3.new(-80, 10, 530), size=Vector3.new(40, 20, 3) },
	{ pos=Vector3.new( 30, 10, 530), size=Vector3.new(60, 20, 3) },
	{ pos=Vector3.new(-80, 10, 570), size=Vector3.new(40, 20, 3) },
	{ pos=Vector3.new( 20, 10, 570), size=Vector3.new(60, 20, 3) },
	{ pos=Vector3.new(-50, 10, 610), size=Vector3.new(80, 20, 3) },
	{ pos=Vector3.new( 50, 10, 610), size=Vector3.new(40, 20, 3) },
	{ pos=Vector3.new(-80, 10, 650), size=Vector3.new(60, 20, 3) },
	{ pos=Vector3.new( 30, 10, 650), size=Vector3.new(40, 20, 3) },
	{ pos=Vector3.new(-40, 10, 690), size=Vector3.new(80, 20, 3) },
	-- Vertical corridors
	{ pos=Vector3.new(-80, 10, 565), size=Vector3.new(3, 20, 70) },
	{ pos=Vector3.new(-40, 10, 580), size=Vector3.new(3, 20, 60) },
	{ pos=Vector3.new(  0, 10, 555), size=Vector3.new(3, 20, 50) },
	{ pos=Vector3.new( 40, 10, 590), size=Vector3.new(3, 20, 80) },
	{ pos=Vector3.new( 80, 10, 560), size=Vector3.new(3, 20, 60) },
	{ pos=Vector3.new(-60, 10, 635), size=Vector3.new(3, 20, 50) },
	{ pos=Vector3.new( 20, 10, 640), size=Vector3.new(3, 20, 60) },
	{ pos=Vector3.new( 60, 10, 625), size=Vector3.new(3, 20, 50) },
}
for i, wd in ipairs(mazeWallDefs) do
	local wall = makePart("MazeWall"..i, wd.size, wd.pos, "Dark stone grey", true, true, 0, "Brick")
	wall.Parent = labFolder
end

-- Outer boundary walls for labyrinth
local labBounds = {
	{ pos=Vector3.new(  0, 10, 500), size=Vector3.new(200, 20, 3) }, -- south
	{ pos=Vector3.new(  0, 10, 700), size=Vector3.new(200, 20, 3) }, -- north
	{ pos=Vector3.new(-100,10, 600), size=Vector3.new(3,  20, 200) }, -- west
	{ pos=Vector3.new( 100,10, 600), size=Vector3.new(3,  20, 200) }, -- east
}
for i, bd in ipairs(labBounds) do
	local bwall = makePart("LabBound"..i, bd.size, bd.pos, "Really black", true, true, 0, "SmoothPlastic")
	bwall.Parent = labFolder
end

-- Torch parts: small orange neon cylinders at corridor junctions
local torchPositions = {
	Vector3.new(-60, 5, 540),
	Vector3.new( 10, 5, 540),
	Vector3.new(-60, 5, 580),
	Vector3.new( 50, 5, 580),
	Vector3.new(-20, 5, 620),
	Vector3.new( 70, 5, 620),
	Vector3.new(-70, 5, 660),
	Vector3.new( 10, 5, 660),
}
for i, tp in ipairs(torchPositions) do
	local torch = makePart("Torch"..i, Vector3.new(1, 3, 1), tp, "Bright orange", true, false, 0, "Neon", "Cylinder")
	torch.Parent = labFolder
end

-- Boss door at north end: large dark Part at (0,10,700)
local bossDoorBlock = makePart("BossDoorBlock", Vector3.new(20, 20, 3), Vector3.new(0, 10, 700), "Really black")
bossDoorBlock.Parent = labFolder
addBillboard(bossDoorBlock, "Boss Chamber", Vector3.new(0, 12, 0), UDim2.new(0, 200, 0, 40))

-- =====================
-- BOSS ARENA (center ~0,0,800)
-- =====================
local arenaFolder = Instance.new("Folder")
arenaFolder.Name = "BossArena"
arenaFolder.Parent = mapFolder

-- Ground plate
local arenaGround = makePart("Ground", Vector3.new(150, 1, 150), Vector3.new(0, 0, 800), "Really black")
arenaGround.BrickColor = BrickColor.new("Dark stone grey")
arenaGround.Material = Enum.Material.SmoothPlastic
arenaGround.Parent = arenaFolder

-- Arena wall ring (4 walls, height 25)
local arenaWalls = {
	{ name="ArenaNorth", size=Vector3.new(150, 25, 3), pos=Vector3.new(  0, 12.5, 875) },
	{ name="ArenaSouth", size=Vector3.new(150, 25, 3), pos=Vector3.new(  0, 12.5, 725) },
	{ name="ArenaWest",  size=Vector3.new(3,  25, 150), pos=Vector3.new(-75, 12.5, 800) },
	{ name="ArenaEast",  size=Vector3.new(3,  25, 150), pos=Vector3.new( 75, 12.5, 800) },
}
for _, wd in ipairs(arenaWalls) do
	local w = makePart(wd.name, wd.size, wd.pos, "Really black")
	w.Parent = arenaFolder
end

-- Boss spawn marker: red circle on floor
local bossMarker = makePart("BossSpawnMarker", Vector3.new(15, 0.2, 15), Vector3.new(0, 0.6, 800), "Bright red", true, false, 0.3)
bossMarker.Shape = Enum.PartType.Cylinder
bossMarker.Parent = arenaFolder

-- Treasure chest placeholder
local chest = makePart("TreasureChest", Vector3.new(3, 2, 2), Vector3.new(0, 1, 830), "Bright yellow")
chest.Parent = arenaFolder
addBillboard(chest, "Treasure", Vector3.new(0, 2, 0), UDim2.new(0, 120, 0, 30))

print("[MapBuilder] Floor1Map built successfully")
