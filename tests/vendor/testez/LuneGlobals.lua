-- Publishes a named global. Luau's _G table is not the global environment,
-- and this runtime has no setfenv, so each name gets a tiny setter chunk.

local luau = require("@lune/luau")

local getters = {}
local setters = {}

local function ident(name)
	if string.match(name, "^[%a_][%w_]*$") == nil then
		error("Cannot bind global '" .. tostring(name) .. "'", 2)
	end
end

local LuneGlobals = {}

function LuneGlobals.get(name)
	ident(name)
	local getter = getters[name]
	if getter == nil then
		getter = luau.load("return function()\n\treturn " .. name .. "\nend")()
		getters[name] = getter
	end
	return getter()
end

function LuneGlobals.set(name, value)
	ident(name)
	local setter = setters[name]
	if setter == nil then
		setter = luau.load("return function(value)\n\t" .. name .. " = value\nend")()
		setters[name] = setter
	end
	setter(value)
end

return LuneGlobals
