-- RemoteSetup.server.lua
-- Script: creates all RemoteEvents and RemoteFunctions under ReplicatedStorage.Remotes

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end

local remoteEvents = {
	"OpenShop",
	"BuyItem",
	"BuyResult",
	"ActivateSkill",
	"BasicAttack",
	"LevelUp",
	"OpenGateMenu",
	"RequestTeleport",
	"ZoneUnlocked",
	"DiscardItem",
	"OpenDialogue",
	"AdvanceDialogue",
	"UseHealingCrystal",
}

for _, name in ipairs(remoteEvents) do
	if not remotes:FindFirstChild(name) then
		local re = Instance.new("RemoteEvent")
		re.Name = name
		re.Parent = remotes
	end
end

print("[RemoteSetup] All remotes created under ReplicatedStorage.Remotes")
