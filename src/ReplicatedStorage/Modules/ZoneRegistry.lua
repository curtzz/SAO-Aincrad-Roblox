-- ZoneRegistry.lua
-- ModuleScript: floor and zone definitions

local ZoneRegistry = {
	Floors = {
		Floor1 = {
			Name = "Floor 1 — Town of Beginnings",
			SpawnPosition = Vector3.new(0, 5, 0),
			GatePosition  = Vector3.new(0, 0, -30),
			Zones = { "Town", "Field", "Tolbana", "Labyrinth", "BossArena" },
			SafeZones = { Town = true, Tolbana = true },
		},
	},
}

function ZoneRegistry:GetFloor(key)
	return self.Floors[key]
end

return ZoneRegistry
