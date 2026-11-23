--!strict

local Config = {
	DUST_COIN_VALUE = 1,
	BASE_BIN_CAPACITY = 8,
	BIN_CAPACITY_PER_LEVEL = 4,
	MAX_BIN_LEVEL = 8,
	-- First upgrade costs one amount; each level after that costs one more step.
	-- A full starting bin is 8 dust, so the first upgrade is two full bins.
	BIN_UPGRADE_BASE_COST = 16,

	SUCTION_RADIUS = 5,
	MAX_DUST = 18,
	DUST_SPAWN_SECONDS = 1.25,
	ROOM_SIZE = 40,
	WALK_SPEED = 18,
}

table.freeze(Config)

return Config
