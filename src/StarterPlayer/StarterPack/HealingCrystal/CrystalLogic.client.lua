-- CrystalLogic.client.lua
-- LocalScript inside HealingCrystal Tool: activates a heal on use

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local tool   = script.Parent

local COOLDOWN  = 1.0
local lastUse   = 0
local activated = false

local healRemote
task.spawn(function()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
	if remotes then
		healRemote = remotes:WaitForChild("UseHealingCrystal", 30)
	end
end)

local function showParticleBurst()
	local char = player.Character
	if not char then return end
	local hrp  = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Create simple blue part VFX
	for i = 1, 12 do
		task.spawn(function()
			local p = Instance.new("Part")
			p.Size         = Vector3.new(0.4, 0.4, 0.4)
			p.Shape        = Enum.PartType.Ball
			p.BrickColor   = BrickColor.new("Cyan")
			p.Material     = Enum.Material.Neon
			p.Anchored     = false
			p.CanCollide   = false
			p.CFrame       = CFrame.new(hrp.Position + Vector3.new(
				math.random(-3, 3),
				math.random(0, 4),
				math.random(-3, 3)
			))
			p.Velocity     = Vector3.new(
				math.random(-8, 8),
				math.random(5, 14),
				math.random(-8, 8)
			)
			p.Parent       = game:GetService("Workspace")

			task.delay(0.8, function()
				if p and p.Parent then
					p:Destroy()
				end
			end)
		end)
		task.wait(0.02)
	end
end

tool.Activated:Connect(function()
	if activated then return end
	local now = tick()
	if now - lastUse < COOLDOWN then return end

	-- Check HP isn't full
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	if humanoid.Health >= humanoid.MaxHealth then return end

	lastUse   = now
	activated = true

	showParticleBurst()

	if healRemote then
		healRemote:FireServer()
	end

	task.delay(0.5, function()
		activated = false
	end)
end)
