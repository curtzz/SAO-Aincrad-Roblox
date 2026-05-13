-- GateHandler.server.lua
-- Script: handles portal touch → show gate menu; RequestTeleport → teleport player

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerStats  = require(ReplicatedStorage.Modules.PlayerStats)
local ZoneRegistry = require(ReplicatedStorage.Modules.ZoneRegistry)

local touchDebounce = {}  -- [userId] = lastTouchTime

local function findPortalParts()
	local gatesFolder = Workspace:WaitForChild("Gates", 60)
	local portals = {}
	if gatesFolder then
		for _, child in ipairs(gatesFolder:GetDescendants()) do
			if child:IsA("BasePart") and child.Name == "Portal" then
				table.insert(portals, child)
			end
		end
	end
	return portals
end

local function getPlayerFromHit(hit)
	local model = hit:FindFirstAncestorOfClass("Model")
	if not model then return nil end
	return Players:GetPlayerFromCharacter(model)
end

task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end

	local openGateMenuRemote = remotes:WaitForChild("OpenGateMenu",     30)
	local requestTeleportRemote = remotes:WaitForChild("RequestTeleport", 30)

	-- Bind portal touch
	task.spawn(function()
		local portals = findPortalParts()
		for _, portal in ipairs(portals) do
			portal.Touched:Connect(function(hit)
				local player = getPlayerFromHit(hit)
				if not player then return end

				local now = tick()
				if touchDebounce[player.UserId] and now - touchDebounce[player.UserId] < 1 then return end
				touchDebounce[player.UserId] = now

				local unlockedFloors = PlayerStats.GetUnlockedFloors(player)
				openGateMenuRemote:FireClient(player, {
					unlockedFloors = unlockedFloors,
					currentFloor   = "Floor1",
				})
			end)
		end
	end)

	-- Handle teleport requests
	requestTeleportRemote.OnServerEvent:Connect(function(player, floorKey)
		local unlockedFloors = PlayerStats.GetUnlockedFloors(player)
		if not unlockedFloors[floorKey] then return end

		local floor = ZoneRegistry:GetFloor(floorKey)
		if not floor then return end

		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(floor.SpawnPosition)
		end
	end)
end)

-- Clean up debounce on leave
Players.PlayerRemoving:Connect(function(player)
	touchDebounce[player.UserId] = nil
end)

print("[GateHandler] Ready")
