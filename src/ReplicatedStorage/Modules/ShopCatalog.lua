-- ShopCatalog.lua
-- ModuleScript: definitions for all shops and their items

local ShopCatalog = {
	ItemShop = {
		Name = "Item Shop",
		Items = {
			{ Id = "HealingCrystal", Name = "Healing Crystal", Price = 50,  Description = "Restores 50% HP" },
			{ Id = "Antidote",       Name = "Antidote",        Price = 30,  Description = "Cures poison" },
			{ Id = "EscapeOrb",      Name = "Escape Orb",      Price = 200, Description = "Teleports to Town" },
		},
	},
	WeaponShop = {
		Name = "Weapon Shop",
		Items = {
			{ Id = "IronSword",   Name = "Iron Sword",   Price = 150, Description = "+5 ATK" },
			{ Id = "SteelRapier", Name = "Steel Rapier", Price = 300, Description = "+10 ATK, fast" },
			{ Id = "AnnealBlade", Name = "Anneal Blade", Price = 800, Description = "+18 ATK, starter sword" },
		},
	},
	ArmorShop = {
		Name = "Armor Shop",
		Items = {
			{ Id = "LeatherVest", Name = "Leather Vest", Price = 100, Description = "+10 Defense" },
			{ Id = "ChainMail",   Name = "Chain Mail",   Price = 250, Description = "+25 Defense" },
			{ Id = "IronPlate",   Name = "Iron Plate",   Price = 500, Description = "+45 Defense" },
		},
	},
	Inn = {
		Name = "Inn",
		Items = {
			{ Id = "RestNight", Name = "Rest (1 Night)", Price = 20, Description = "Fully restores HP" },
			{ Id = "SafeRoom",  Name = "Safe Room",      Price = 50, Description = "AFK protection 1hr" },
		},
	},
}

return ShopCatalog
