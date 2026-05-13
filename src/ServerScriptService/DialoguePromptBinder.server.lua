-- DialoguePromptBinder.server.lua
-- Script: binds dialogue ProximityPrompts; handles AdvanceDialogue choice flags

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStats       = require(ReplicatedStorage.Modules.PlayerStats)
local DialogueRegistry  = require(ReplicatedStorage.Modules.DialogueRegistry)

local function bindDialogueNPC(model, openDialogueRemote)
	local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildOfClass("BasePart")
	if not hrp then return end

	local dialogueId = model:GetAttribute("DialogueId")
	if not dialogueId then return end
	local registryEntry = DialogueRegistry[dialogueId]
	if not registryEntry then return end

	local prompt = hrp:FindFirstChild("DialoguePrompt")
	if not prompt then return end

	-- Connect trigger
	if prompt:GetAttribute("DialogueBound") then return end
	prompt:SetAttribute("DialogueBound", true)

	prompt.Triggered:Connect(function(player)
		local flagAlreadySet = false
		if registryEntry.Flag then
			flagAlreadySet = PlayerStats.GetFlag(player, registryEntry.Flag)
		end

		openDialogueRemote:FireClient(player, {
			npcId        = dialogueId,
			flagAlreadySet = flagAlreadySet,
		})

		-- Set the met-flag now
		if registryEntry.Flag and not flagAlreadySet then
			PlayerStats.SetFlag(player, registryEntry.Flag)
		end
	end)
end

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end

	local openDialogueRemote  = remotes:WaitForChild("OpenDialogue",   30)
	local advanceDialogueRemote = remotes:WaitForChild("AdvanceDialogue", 30)

	-- Handle choice flags sent from client
	advanceDialogueRemote.OnServerEvent:Connect(function(player, npcId, choiceKey)
		if not npcId or not choiceKey then return end
		local entry = DialogueRegistry[npcId]
		if not entry or not entry.Choices then return end
		local choice = entry.Choices[choiceKey]
		if choice and choice.Flag then
			PlayerStats.SetFlag(player, choice.Flag)
		end
	end)

	-- Bind existing NPCs
	local shopNPCs = Workspace:WaitForChild("ShopNPCs", 60)
	if shopNPCs then
		for _, model in ipairs(shopNPCs:GetChildren()) do
			if model:IsA("Model") then
				bindDialogueNPC(model, openDialogueRemote)
			end
		end

		shopNPCs.ChildAdded:Connect(function(child)
			if child:IsA("Model") then
				task.wait(0.1)
				bindDialogueNPC(child, openDialogueRemote)
			end
		end)
	end
end)

print("[DialoguePromptBinder] Ready")
