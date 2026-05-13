-- CombatHandler.server.lua
-- Script: handles server-side skill and basic attack combat logic

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SwordSkills   = require(ReplicatedStorage.Modules.SwordSkills)
local ZoneRegistry  = require(ReplicatedStorage.Modules.ZoneRegistry)

local Remotes
local ActivateSkillRemote
local BasicAttackRemote

local function waitForRemotes()
	Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if Remotes then
		ActivateSkillRemote = Remotes:WaitForChild("ActivateSkill", 30)
		BasicAttackRemote   = Remotes:WaitForChild("BasicAttack", 30)
	end
end
task.spawn(waitForRemotes)

-- Safe zone centers for Floor1
local SAFE_ZONE_CENTERS = {
	Town    = Vector3.new(0,  0,   0),
	Tolbana = Vector3.new(0,  0, 420),
}
local SAFE_ZONE_RADIUS = 110

local function isInSafeZone(position)
	for _, center in pairs(SAFE_ZONE_CENTERS) do
		if (position - center).Magnitude <= SAFE_ZONE_RADIUS then
			return true
		end
	end
	return false
end

local function getPlayerFromCharacter(character)
	return Players:GetPlayerFromCharacter(character)
end

-- Per-player per-skill cooldown tracking
local cooldowns = {}  -- cooldowns[userId][skillKey] = lastUsedTime

local function getCooldownTable(userId)
	if not cooldowns[userId] then
		cooldowns[userId] = {}
	end
	return cooldowns[userId]
end

local function isOnCooldown(userId, skillKey, cooldownDuration)
	local cd = getCooldownTable(userId)
	local last = cd[skillKey]
	if not last then return false end
	return (tick() - last) < cooldownDuration
end

local function setCooldown(userId, skillKey)
	getCooldownTable(userId)[skillKey] = tick()
end

local function applySkill(player, skillKey, targetPosition)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local skill = SwordSkills[skillKey]
	if not skill then return end

	-- Cooldown check
	if isOnCooldown(player.UserId, skillKey, skill.Cooldown) then return end
	setCooldown(player.UserId, skillKey)

	-- Check if attacker is in safe zone
	if isInSafeZone(hrp.Position) then return end

	-- Create hitbox near player
	local hitbox = Instance.new("Part")
	hitbox.Name        = "SkillHitbox"
	hitbox.Size        = Vector3.new(skill.Range, 4, skill.Range)
	hitbox.CFrame      = CFrame.new(hrp.Position + hrp.CFrame.LookVector * (skill.Range * 0.5))
	hitbox.Anchored    = true
	hitbox.CanCollide  = false
	hitbox.Transparency = 1
	hitbox.Parent      = game:GetService("Workspace")

	-- Find characters in range
	local hitParts = game:GetService("Workspace"):GetPartsInPart(hitbox)
	local hitModels = {}
	for _, part in ipairs(hitParts) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and not hitModels[model] and model ~= char then
			hitModels[model] = true
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				-- Don't damage players in safe zones
				local targetHRP = model:FindFirstChild("HumanoidRootPart")
				if targetHRP and not isInSafeZone(targetHRP.Position) then
					humanoid:TakeDamage(skill.Damage)
				end
			end
		end
	end

	task.delay(0.2, function()
		if hitbox and hitbox.Parent then
			hitbox:Destroy()
		end
	end)
end

local function applyBasicAttack(player)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if isOnCooldown(player.UserId, "BasicAttack", 0.45) then return end
	setCooldown(player.UserId, "BasicAttack")

	if isInSafeZone(hrp.Position) then return end

	local hitbox = Instance.new("Part")
	hitbox.Name        = "BasicAttackHitbox"
	hitbox.Size        = Vector3.new(8, 4, 8)
	hitbox.CFrame      = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 5)
	hitbox.Anchored    = true
	hitbox.CanCollide  = false
	hitbox.Transparency = 1
	hitbox.Parent      = game:GetService("Workspace")

	local hitParts = game:GetService("Workspace"):GetPartsInPart(hitbox)
	local hitModels = {}
	for _, part in ipairs(hitParts) do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and not hitModels[model] and model ~= char then
			hitModels[model] = true
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				local targetHRP = model:FindFirstChild("HumanoidRootPart")
				if targetHRP and not isInSafeZone(targetHRP.Position) then
					humanoid:TakeDamage(12)
				end
			end
		end
	end

	task.delay(0.2, function()
		if hitbox and hitbox.Parent then
			hitbox:Destroy()
		end
	end)
end

-- Wait for remotes then connect
task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if not remotes then return end

	local activateRemote = remotes:WaitForChild("ActivateSkill", 30)
	if activateRemote then
		activateRemote.OnServerEvent:Connect(function(player, skillKey, targetPosition)
			applySkill(player, skillKey, targetPosition)
		end)
	end

	local basicRemote = remotes:WaitForChild("BasicAttack", 30)
	if basicRemote then
		basicRemote.OnServerEvent:Connect(function(player)
			applyBasicAttack(player)
		end)
	end
end)

-- Clean up cooldowns when player leaves
Players.PlayerRemoving:Connect(function(player)
	cooldowns[player.UserId] = nil
end)

print("[CombatHandler] Ready")
