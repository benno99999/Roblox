--!strict

local Config = require("./Config")
local Upgrades = require("./Upgrades")

local SaveData = {}

export type Data = {
	coins: number,
	binLevel: number,
	binDust: number,
}

function SaveData.default(): Data
	return {
		coins = 0,
		binLevel = 0,
		binDust = 0,
	}
end

local function whole(value: any): number?
	if typeof(value) ~= "number" then
		return nil
	end
	if value ~= value or value >= math.huge or value <= -math.huge then
		return nil
	end
	return math.floor(value)
end

function SaveData.normalize(raw: any): Data
	if typeof(raw) ~= "table" then
		return SaveData.default()
	end

	local coins = whole(raw.coins) or 0
	if coins < 0 then
		coins = 0
	end

	local binLevel = whole(raw.binLevel) or 0
	if binLevel < 0 then
		binLevel = 0
	elseif binLevel > Config.MAX_BIN_LEVEL then
		binLevel = Config.MAX_BIN_LEVEL
	end

	local capacity = Upgrades.binCapacity(binLevel)
	local binDust = whole(raw.binDust) or 0
	if binDust < 0 then
		binDust = 0
	elseif binDust > capacity then
		binDust = capacity
	end

	return {
		coins = coins,
		binLevel = binLevel,
		binDust = binDust,
	}
end

return SaveData
