--!strict

return function()
	local Config = require("../src/shared/Config")
	local DustEconomy = require("../src/shared/DustEconomy")

	describe("sellValue", function()
		it("pays the configured coin value per whole mote", function()
			expect(Config.DUST_COIN_VALUE).to.equal(1)
			expect(DustEconomy.sellValue(0)).to.equal(0)
			expect(DustEconomy.sellValue(-4)).to.equal(0)
			expect(DustEconomy.sellValue(8)).to.equal(8)
			expect(DustEconomy.sellValue(2.9)).to.equal(2)
		end)
	end)

	describe("sell", function()
		it("adds the payout to the player's coins", function()
			local sale = DustEconomy.sell(5, 8)
			expect(sale.dustSold).to.equal(8)
			expect(sale.earned).to.equal(8)
			expect(sale.coins).to.equal(13)
		end)

		it("changes nothing when the bin is empty", function()
			local sale = DustEconomy.sell(5, 0)
			expect(sale.dustSold).to.equal(0)
			expect(sale.earned).to.equal(0)
			expect(sale.coins).to.equal(5)
		end)
	end)
end
