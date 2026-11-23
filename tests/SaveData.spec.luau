--!strict

return function()
	local Config = require("../src/shared/Config")
	local SaveData = require("../src/shared/SaveData")
	local Upgrades = require("../src/shared/Upgrades")

	describe("normalize", function()
		it("uses a zeroed record for missing or garbage saves", function()
			local fresh = SaveData.default()
			expect(fresh.coins).to.equal(0)
			expect(fresh.binLevel).to.equal(0)
			expect(fresh.binDust).to.equal(0)

			local fromNil = SaveData.normalize(nil)
			expect(fromNil.coins).to.equal(0)
			expect(fromNil.binLevel).to.equal(0)
			expect(fromNil.binDust).to.equal(0)

			local broken = SaveData.normalize("nope")
			expect(broken.coins).to.equal(0)
			expect(broken.binLevel).to.equal(0)
		end)

		it("keeps a valid record", function()
			local data = SaveData.normalize({
				coins = 20,
				binLevel = 1,
				binDust = 4,
			})
			expect(data.coins).to.equal(20)
			expect(data.binLevel).to.equal(1)
			expect(data.binDust).to.equal(4)
		end)

		it("floors numbers and drops negatives", function()
			local data = SaveData.normalize({
				coins = 10.9,
				binLevel = 1.2,
				binDust = 3.8,
			})
			expect(data.coins).to.equal(10)
			expect(data.binLevel).to.equal(1)
			expect(data.binDust).to.equal(3)

			local negative = SaveData.normalize({
				coins = -5,
				binLevel = -2,
				binDust = -1,
			})
			expect(negative.coins).to.equal(0)
			expect(negative.binLevel).to.equal(0)
			expect(negative.binDust).to.equal(0)
		end)

		it("clamps level and dust to the upgrade rules", function()
			local data = SaveData.normalize({
				coins = 4,
				binLevel = 99,
				binDust = 1000,
			})
			expect(data.binLevel).to.equal(Config.MAX_BIN_LEVEL)
			expect(data.binDust).to.equal(Upgrades.binCapacity(Config.MAX_BIN_LEVEL))
		end)

		it("rejects non-finite numbers", function()
			local data = SaveData.normalize({
				coins = 0 / 0,
				binLevel = math.huge,
				binDust = -math.huge,
			})
			expect(data.coins).to.equal(0)
			expect(data.binLevel).to.equal(0)
			expect(data.binDust).to.equal(0)
		end)
	end)
end
