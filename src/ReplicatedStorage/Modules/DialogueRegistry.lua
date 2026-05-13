-- DialogueRegistry.lua
-- ModuleScript: dialogue trees for story NPCs

local DialogueRegistry = {
	Diavel = {
		Name = "Diavel",
		Portrait = "rbxassetid://0",
		Flag = "MetDiavel",
		Lines = {
			"Hey! You there — yeah, you with the sword.",
			"Name's Diavel. I've been organizing a boss raid on Illfang the Kobold Lord.",
			"We're meeting at Tolbana. If you want to clear this floor, you should join us.",
			"Don't worry — I've got a strategy guide. Just follow my lead.",
			"[CHOICE: I'll join the raid. / Maybe later.]",
		},
		Choices = {
			["I'll join the raid."] = {
				Reply = "Excellent. Head to Tolbana and look for the raid party. See you there.",
				Flag = "JoinedRaid",
			},
			["Maybe later."] = {
				Reply = "Suit yourself. But every day we wait, more people lose hope.",
			},
		},
	},
	Kirito = {
		Name = "Kirito",
		Portrait = "rbxassetid://0",
		Flag = "MetKirito",
		Lines = {
			"...",
			"You're still alive. Good.",
			"This isn't a game anymore. Every one of those players out there — real people.",
			"I'm going to clear every floor. You should stay out of my way.",
		},
	},
	GuardNPC = {
		Name = "Town Guard",
		Portrait = "rbxassetid://0",
		Lines = {
			"Stay within the town limits if you value your life.",
			"The fields to the west are crawling with Frenzy Boars. Don't go alone.",
		},
	},
	TownNPC = {
		Name = "Townsfolk",
		Portrait = "rbxassetid://0",
		Lines = {
			"I heard a group of players reached the labyrinth already...",
			"Do you think anyone will actually clear this floor?",
		},
	},
}

return DialogueRegistry
