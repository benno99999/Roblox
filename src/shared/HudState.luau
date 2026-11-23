--!strict

local SaveData = require("./SaveData")
local Upgrades = require("./Upgrades")

local HudState = {}

export type State = {
	coins: number,
	binDust: number,
	binCapacity: number,
	upgradeCost: number?,
	nextBinCapacity: number?,
}

function HudState.fromSave(data: SaveData.Data): State
	local state: State = {
		coins = data.coins,
		binDust = data.binDust,
		binCapacity = Upgrades.binCapacity(data.binLevel),
	}
	local cost = Upgrades.binUpgradeCost(data.binLevel)
	if cost ~= nil then
		state.upgradeCost = cost
		state.nextBinCapacity = Upgrades.binCapacity(data.binLevel + 1)
	end
	return state
end

function HudState.read(payload: any): State?
	if typeof(payload) ~= "table" then
		return nil
	end

	local coins = payload.coins
	local binDust = payload.binDust
	local binCapacity = payload.binCapacity
	if
		typeof(coins) ~= "number"
		or typeof(binDust) ~= "number"
		or typeof(binCapacity) ~= "number"
	then
		return nil
	end

	local upgradeCost = payload.upgradeCost
	local nextBinCapacity = payload.nextBinCapacity
	if upgradeCost ~= nil and typeof(upgradeCost) ~= "number" then
		return nil
	end
	if nextBinCapacity ~= nil and typeof(nextBinCapacity) ~= "number" then
		return nil
	end

	return {
		coins = coins,
		binDust = binDust,
		binCapacity = binCapacity,
		upgradeCost = upgradeCost,
		nextBinCapacity = nextBinCapacity,
	}
end

return HudState
