-- SwordCombat.client.lua
-- LocalScript inside AnnealBlade Tool: handles basic attack on click

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local tool   = script.Parent

local COOLDOWN   = 0.45
local lastSwing  = 0

local basicAttackRemote
task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if remotes then
		basicAttackRemote = remotes:WaitForChild("BasicAttack", 30)
	end
end)

local function swingAnimation()
	-- Brief rotation of the tool handle to simulate a swing
	local handle = tool:FindFirstChildOfClass("Part") or tool:FindFirstChild("Handle")
	if not handle then return end
	local originalCFrame = handle.CFrame
	task.spawn(function()
		for i = 1, 6 do
			handle.CFrame = originalCFrame * CFrame.Angles(0, 0, math.rad(i * 15))
			task.wait(0.02)
		end
		for i = 6, 0, -1 do
			handle.CFrame = originalCFrame * CFrame.Angles(0, 0, math.rad(i * 15))
			task.wait(0.02)
		end
		handle.CFrame = originalCFrame
	end)
end

tool.Activated:Connect(function()
	local now = tick()
	if now - lastSwing < COOLDOWN then return end
	lastSwing = now

	swingAnimation()

	if basicAttackRemote then
		basicAttackRemote:FireServer()
	end
end)
