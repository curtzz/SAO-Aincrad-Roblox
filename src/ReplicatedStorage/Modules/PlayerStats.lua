-- PlayerStats.lua
-- ModuleScript: manages player profiles with DataStore persistence

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DATASTORE_KEY = "PlayerStats_v2"
local AUTO_SAVE_INTERVAL = 180

local store = nil
if not RunService:IsStudio() then
	pcall(function()
		store = DataStoreService:GetDataStore(DATASTORE_KEY)
	end)
else
	pcall(function()
		store = DataStoreService:GetDataStore(DATASTORE_KEY)
	end)
end

local PlayerStats = {}
local profiles = {}

local ProfileLoaded = Instance.new("BindableEvent")
PlayerStats.ProfileLoaded = ProfileLoaded

local function defaultProfile()
	return {
		Level = 1,
		XP = 0,
		MaxHP = 100,
		CurrentHP = 100,
		Col = 0,
		Inventory = {},
		UnlockedFloors = { Floor1 = true },
		StoryFlags = {},
		_dirty = false,
	}
end

local function deepCopy(t)
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

function PlayerStats.Load(player)
	local userId = player.UserId
	local key = DATASTORE_KEY .. "_" .. tostring(userId)
	local data = nil

	if store then
		local ok, result = pcall(function()
			return store:GetAsync(key)
		end)
		if ok and result then
			data = result
		end
	end

	local profile = defaultProfile()
	if data then
		for k, v in pairs(data) do
			if profile[k] ~= nil then
				profile[k] = v
			end
		end
		-- ensure sub-tables exist
		if not profile.Inventory then profile.Inventory = {} end
		if not profile.UnlockedFloors then profile.UnlockedFloors = { Floor1 = true } end
		if not profile.StoryFlags then profile.StoryFlags = {} end
	end
	profile._dirty = false
	profiles[userId] = profile

	ProfileLoaded:Fire(player, profile)
end

function PlayerStats.Save(player)
	local userId = player.UserId
	local profile = profiles[userId]
	if not profile then return end
	if not profile._dirty then return end
	if not store then return end

	local saveData = {}
	for k, v in pairs(profile) do
		if k ~= "_dirty" then
			saveData[k] = v
		end
	end

	local key = DATASTORE_KEY .. "_" .. tostring(userId)
	local ok, err = pcall(function()
		store:SetAsync(key, saveData)
	end)
	if ok then
		profile._dirty = false
	else
		warn("PlayerStats.Save failed for", player.Name, ":", err)
	end
end

function PlayerStats.Unload(player)
	PlayerStats.Save(player)
	profiles[player.UserId] = nil
end

function PlayerStats.Get(player)
	return profiles[player.UserId]
end

function PlayerStats.AddItem(player, itemId)
	local profile = profiles[player.UserId]
	if not profile then return end
	table.insert(profile.Inventory, itemId)
	profile._dirty = true
end

function PlayerStats.RemoveItem(player, itemId)
	local profile = profiles[player.UserId]
	if not profile then return end
	for i, id in ipairs(profile.Inventory) do
		if id == itemId then
			table.remove(profile.Inventory, i)
			profile._dirty = true
			return true
		end
	end
	return false
end

function PlayerStats.AddCol(player, amount)
	local profile = profiles[player.UserId]
	if not profile then return end
	profile.Col = profile.Col + amount
	profile._dirty = true
end

function PlayerStats.SpendCol(player, amount)
	local profile = profiles[player.UserId]
	if not profile then return false end
	if profile.Col < amount then return false end
	profile.Col = profile.Col - amount
	profile._dirty = true
	return true
end

function PlayerStats.SetLevel(player, level)
	local profile = profiles[player.UserId]
	if not profile then return end
	profile.Level = level
	profile._dirty = true
end

function PlayerStats.SetXP(player, xp)
	local profile = profiles[player.UserId]
	if not profile then return end
	profile.XP = xp
	profile._dirty = true
end

function PlayerStats.UnlockFloor(player, floorKey)
	local profile = profiles[player.UserId]
	if not profile then return end
	profile.UnlockedFloors[floorKey] = true
	profile._dirty = true
end

function PlayerStats.GetUnlockedFloors(player)
	local profile = profiles[player.UserId]
	if not profile then return {} end
	return profile.UnlockedFloors
end

function PlayerStats.SetFlag(player, flagKey)
	local profile = profiles[player.UserId]
	if not profile then return end
	profile.StoryFlags[flagKey] = true
	profile._dirty = true
end

function PlayerStats.GetFlag(player, flagKey)
	local profile = profiles[player.UserId]
	if not profile then return false end
	return profile.StoryFlags[flagKey] == true
end

-- Auto-save loop
task.spawn(function()
	while true do
		task.wait(AUTO_SAVE_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			local profile = profiles[player.UserId]
			if profile and profile._dirty then
				PlayerStats.Save(player)
			end
		end
	end
end)

return PlayerStats
