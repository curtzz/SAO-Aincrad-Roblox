-- SwordSkills.lua
-- ModuleScript: definitions for all sword skills

local SwordSkills = {
	Linear = {
		Name = "Linear",
		Damage = 18,
		Cooldown = 1.2,
		Color = Color3.fromRGB(100, 180, 255),
		Range = 12,
	},
	Horizontal = {
		Name = "Horizontal",
		Damage = 22,
		Cooldown = 1.5,
		Color = Color3.fromRGB(255, 200, 50),
		Range = 14,
	},
	SonicLeap = {
		Name = "Sonic Leap",
		Damage = 30,
		Cooldown = 2.0,
		Color = Color3.fromRGB(50, 255, 100),
		Range = 20,
	},
	VorpalStrike = {
		Name = "Vorpal Strike",
		Damage = 45,
		Cooldown = 3.5,
		Color = Color3.fromRGB(200, 50, 255),
		Range = 10,
	},
}

return SwordSkills
