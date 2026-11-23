--!strict

local Config = require("./Config")

local Upgrades = {}

export type Purchase = {
	ok: boolean,
	coins: number,
	level: number,
	reason: string?,
}

local function validLevel(level: number): boolean
	return level == math.floor(level) and level >= 0 and level <= Config.MAX_BIN_LEVEL
end

function Upgrades.binCapacity(level: number): number
	local clamped = level
	if clamped < 0 then
		clamped = 0
	elseif clamped > Config.MAX_BIN_LEVEL then
		clamped = Config.MAX_BIN_LEVEL
	end
	clamped = math.floor(clamped)
	return Config.BASE_BIN_CAPACITY + clamped * Config.BIN_CAPACITY_PER_LEVEL
end

-- Cost of the next bin upgrade, or nil when `level` cannot buy another one.
function Upgrades.binUpgradeCost(level: number): number?
	if not validLevel(level) or level >= Config.MAX_BIN_LEVEL then
		return nil
	end
	return Config.BIN_UPGRADE_BASE_COST * (level + 1)
end

function Upgrades.tryBuyBin(coins: number, level: number): Purchase
	if not validLevel(level) then
		return {
			ok = false,
			coins = coins,
			level = level,
			reason = "invalid_level",
		}
	end

	local cost = Upgrades.binUpgradeCost(level)
	if cost == nil then
		return {
			ok = false,
			coins = coins,
			level = level,
			reason = "max_level",
		}
	end
	if coins < cost then
		return {
			ok = false,
			coins = coins,
			level = level,
			reason = "not_enough_coins",
		}
	end

	return {
		ok = true,
		coins = coins - cost,
		level = level + 1,
	}
end

return Upgrades
