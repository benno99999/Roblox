--!strict

return function()
	local Config = require("../src/shared/Config")
	local HudState = require("../src/shared/HudState")

	describe("fromSave", function()
		it("includes the next bin upgrade", function()
			local state = HudState.fromSave({
				coins = 16,
				binLevel = 0,
				binDust = 8,
			})
			expect(state.coins).to.equal(16)
			expect(state.binDust).to.equal(8)
			expect(state.binCapacity).to.equal(8)
			expect(state.upgradeCost).to.equal(16)
			expect(state.nextBinCapacity).to.equal(12)
		end)

		it("omits the upgrade once the bin is maxed", function()
			local state = HudState.fromSave({
				coins = 0,
				binLevel = Config.MAX_BIN_LEVEL,
				binDust = 0,
			})
			expect(state.binCapacity).to.equal(40)
			expect(state.upgradeCost).to.equal(nil)
			expect(state.nextBinCapacity).to.equal(nil)
		end)
	end)

	describe("read", function()
		it("accepts a server payload", function()
			local state = HudState.read({
				coins = 3,
				binDust = 1,
				binCapacity = 8,
				upgradeCost = 16,
				nextBinCapacity = 12,
			})
			expect(state).to.be.ok()
			assert(state ~= nil, "payload should parse")
			expect(state.coins).to.equal(3)
			expect(state.nextBinCapacity).to.equal(12)
		end)

		it("accepts a maxed payload with no upgrade fields", function()
			local state = HudState.read({
				coins = 3,
				binDust = 0,
				binCapacity = 40,
			})
			expect(state).to.be.ok()
			assert(state ~= nil, "maxed payload should parse")
			expect(state.upgradeCost).to.equal(nil)
		end)

		it("rejects a payload that is not a hud state", function()
			expect(HudState.read(nil)).to.equal(nil)
			expect(HudState.read("coins")).to.equal(nil)
			expect(HudState.read({ coins = 1, binDust = 0 })).to.equal(nil)
			expect(HudState.read({
				coins = 1,
				binDust = 0,
				binCapacity = 8,
				upgradeCost = "free",
			})).to.equal(nil)
		end)
	end)
end
