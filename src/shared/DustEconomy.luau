--!strict

local Config = require("./Config")

local DustEconomy = {}

export type Sale = {
	coins: number,
	earned: number,
	dustSold: number,
}

function DustEconomy.sellValue(dustCount: number): number
	if dustCount <= 0 then
		return 0
	end
	return math.floor(dustCount) * Config.DUST_COIN_VALUE
end

function DustEconomy.sell(coins: number, dustCount: number): Sale
	local sold = if dustCount > 0 then math.floor(dustCount) else 0
	local earned = DustEconomy.sellValue(sold)
	return {
		coins = coins + earned,
		earned = earned,
		dustSold = sold,
	}
end

return DustEconomy
