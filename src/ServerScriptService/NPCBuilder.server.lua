-- NPCBuilder.server.lua
-- Script: builds story and shop NPCs in Workspace.ShopNPCs

local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPC_DEFINITIONS = {
	{ Name = "Diavel",      Position = Vector3.new(  15, 5,  -10), DialogueId = "Diavel"   },
	{ Name = "Kirito",      Position = Vector3.new( -15, 5,  -10), DialogueId = "Kirito"   },
	{ Name = "Town Guard",  Position = Vector3.new(  80, 5,  -85), DialogueId = "GuardNPC" },
	{ Name = "Townsfolk",   Position = Vector3.new( -80, 5,  -85), DialogueId = "TownNPC"  },
	{ Name = "Item Shop",   Position = Vector3.new(  30, 5,   20), ShopId     = "ItemShop"  },
	{ Name = "Weapon Shop", Position = Vector3.new( -30, 5,   20), ShopId     = "WeaponShop"},
	{ Name = "Armor Shop",  Position = Vector3.new(  30, 5,  -20), ShopId     = "ArmorShop" },
	{ Name = "Inn",         Position = Vector3.new( -30, 5,  -20), ShopId     = "Inn"       },
}

-- Ensure ShopNPCs folder exists
local shopNPCsFolder = Workspace:FindFirstChild("ShopNPCs")
if not shopNPCsFolder then
	shopNPCsFolder = Instance.new("Folder")
	shopNPCsFolder.Name   = "ShopNPCs"
	shopNPCsFolder.Parent = Workspace
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function getFloorY(position)
	local origin    = position + Vector3.new(0, 5, 0)
	local direction = Vector3.new(0, -20, 0)
	local result    = Workspace:Raycast(origin, direction, raycastParams)
	if result then
		return result.Position.Y
	end
	return position.Y
end

local function addBillboard(part, text)
	local bb = Instance.new("BillboardGui")
	bb.Size        = UDim2.new(0, 160, 0, 35)
	bb.StudsOffset = Vector3.new(0, 4, 0)
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

local function buildNPC(def)
	local model = Instance.new("Model")
	model.Name  = def.Name

	-- HumanoidRootPart (torso-like)
	local hrp = Instance.new("Part")
	hrp.Name      = "HumanoidRootPart"
	hrp.Size      = Vector3.new(2, 2, 1)
	hrp.Anchored  = true
	hrp.CanCollide = true
	hrp.BrickColor = BrickColor.new("Medium blue")
	hrp.Parent    = model

	-- Head
	local head = Instance.new("Part")
	head.Name      = "Head"
	head.Size      = Vector3.new(1.5, 1.5, 1.5)
	head.Anchored  = true
	head.CanCollide = false
	head.BrickColor = BrickColor.new("Pastel brown")
	head.Parent    = model

	-- Humanoid (makes it a "character")
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth      = math.huge
	humanoid.Health         = math.huge
	humanoid.WalkSpeed      = 0
	humanoid.DisplayName    = def.Name
	humanoid.Parent         = model

	model.PrimaryPart = hrp

	-- Find floor Y
	local floorY = getFloorY(def.Position)
	local baseY  = floorY + 1  -- stand on floor

	hrp.CFrame  = CFrame.new(def.Position.X, baseY + 1, def.Position.Z)
	head.CFrame = CFrame.new(def.Position.X, baseY + 2.75, def.Position.Z)

	-- Nametag
	addBillboard(head, def.Name)

	-- Attributes for other systems
	if def.ShopId then
		model:SetAttribute("ShopId", def.ShopId)
	end
	if def.DialogueId then
		model:SetAttribute("DialogueId", def.DialogueId)

		-- ProximityPrompt for dialogue
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name                  = "DialoguePrompt"
		prompt.ActionText            = "Talk"
		prompt.ObjectText            = def.Name
		prompt.MaxActivationDistance = 8
		prompt.Parent                = hrp

		-- Fire handled by DialoguePromptBinder
	end

	model.Parent = shopNPCsFolder
end

-- Wait a moment for map to be built
task.wait(1)

for _, def in ipairs(NPC_DEFINITIONS) do
	task.spawn(buildNPC, def)
end

print("[NPCBuilder] NPCs created")
