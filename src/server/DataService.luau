--!strict

local DataStoreService = game:GetService("DataStoreService")

local SaveData = require("@game/ReplicatedStorage/Shared/SaveData")

local STORE_NAME = "RoboVac_v1"
local PROBE_KEY = "__robovac_probe__"

local memory: { [string]: SaveData.Data } = {}
local store: DataStore? = nil
local checked = false
local enabled = false

local DataService = {}

local function keyFor(player: Player): string
	return "player_" .. tostring(player.UserId)
end

-- DataStore calls throw in Studio when API access is off, and in unpublished places.
-- One failed probe switches the server to an in-memory table for the rest of the session.
local function resolve(): DataStore?
	if checked then
		return if enabled then store else nil
	end
	checked = true

	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(STORE_NAME)
	end)
	if not ok or typeof(result) ~= "Instance" then
		warn("[RoboVac] DataStore unavailable. Progress lasts until this server stops.")
		return nil
	end

	store = result :: DataStore
	local probeOk = pcall(function()
		(store :: DataStore):GetAsync(PROBE_KEY)
	end)
	enabled = probeOk
	if not probeOk then
		warn("[RoboVac] DataStore unavailable. Progress lasts until this server stops.")
	end
	return if enabled then store else nil
end

function DataService.load(player: Player): (SaveData.Data, boolean)
	local key = keyFor(player)
	local active = resolve()
	if active == nil then
		local cached = memory[key]
		if cached == nil then
			return SaveData.default(), true
		end
		return SaveData.normalize(cached), true
	end

	local ok, result = pcall(function()
		return active:GetAsync(key)
	end)
	if not ok then
		warn("[RoboVac] Could not load " .. key .. ": " .. tostring(result))
		return SaveData.default(), false
	end
	if result == nil then
		return SaveData.default(), true
	end
	return SaveData.normalize(result), true
end

function DataService.save(player: Player, data: SaveData.Data)
	local key = keyFor(player)
	local clean = SaveData.normalize(data)
	memory[key] = clean

	local active = resolve()
	if active == nil then
		return
	end

	local ok, err = pcall(function()
		active:SetAsync(key, {
			coins = clean.coins,
			binLevel = clean.binLevel,
			binDust = clean.binDust,
		})
	end)
	if not ok then
		warn("[RoboVac] Could not save " .. key .. ": " .. tostring(err))
	end
end

return DataService
