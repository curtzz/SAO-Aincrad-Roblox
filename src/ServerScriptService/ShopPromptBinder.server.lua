-- ShopPromptBinder.server.lua
-- Script: binds ProximityPrompts on shop NPCs to fire OpenShop remote

local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")

local function getOpenShopRemote()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if remotes then
		return remotes:WaitForChild("OpenShop", 30)
	end
end

local function bindShopNPC(model, shopId, openShopRemote)
	local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("BasePart")
	if not hrp then return end

	-- Avoid duplicate prompts
	if hrp:FindFirstChild("ShopPrompt") then return end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name         = "ShopPrompt"
	prompt.ActionText   = "Shop"
	prompt.ObjectText   = model.Name
	prompt.MaxActivationDistance = 10
	prompt.Parent       = hrp

	prompt.Triggered:Connect(function(triggerPlayer)
		openShopRemote:FireClient(triggerPlayer, shopId)
	end)
end

local function processShopNPCs(folder, openShopRemote)
	for _, model in ipairs(folder:GetChildren()) do
		if model:IsA("Model") then
			local shopId = model:GetAttribute("ShopId")
			if shopId then
				bindShopNPC(model, shopId, openShopRemote)
			end
		end
	end
end

task.spawn(function()
	local openShopRemote = getOpenShopRemote()
	if not openShopRemote then return end

	-- Wait for ShopNPCs folder
	local shopNPCs = Workspace:WaitForChild("ShopNPCs", 60)
	if not shopNPCs then return end

	processShopNPCs(shopNPCs, openShopRemote)

	-- Watch for newly-added NPCs
	shopNPCs.ChildAdded:Connect(function(child)
		if child:IsA("Model") then
			task.wait(0.1) -- let attributes be set
			local shopId = child:GetAttribute("ShopId")
			if shopId then
				bindShopNPC(child, shopId, openShopRemote)
			end
		end
	end)
end)

print("[ShopPromptBinder] Ready")
