--!strict

return function()
	local Config = require("../src/shared/Config")

	it("keeps the tunables fixed", function()
		expect(function()
			(Config :: any).DUST_COIN_VALUE = 99
		end).to.throw()
		expect(Config.DUST_COIN_VALUE).to.equal(1)
		expect(Config.SUCTION_RADIUS).to.equal(5)
		expect(Config.ROOM_SIZE).to.equal(40)
	end)
end
