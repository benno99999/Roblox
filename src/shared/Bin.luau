--!strict

local Bin = {}

export type Bin = {
	capacity: number,
	amount: number,
}

local function integer(value: number): boolean
	return value == math.floor(value)
end

function Bin.new(capacity: number, amount: number?): Bin
	local starting = if amount == nil then 0 else amount
	if capacity < 0 or not integer(capacity) then
		error("capacity must be a non-negative integer", 2)
	end
	if starting < 0 or starting > capacity or not integer(starting) then
		error("amount must be an integer within capacity", 2)
	end
	return {
		capacity = capacity,
		amount = starting,
	}
end

function Bin.space(bin: Bin): number
	return bin.capacity - bin.amount
end

function Bin.isFull(bin: Bin): boolean
	return bin.amount >= bin.capacity
end

-- Stores up to `count` whole dust. Returns how many fit.
function Bin.tryAdd(bin: Bin, count: number): number
	if count <= 0 then
		return 0
	end
	local added = math.min(math.floor(count), Bin.space(bin))
	if added < 0 then
		added = 0
	end
	bin.amount += added
	return added
end

-- Removes every dust mote and returns how many were removed.
function Bin.empty(bin: Bin): number
	local taken = bin.amount
	bin.amount = 0
	return taken
end

return Bin
