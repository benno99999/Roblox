--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")

if not fs.isDir("tests") or not fs.isFile("tests/run.luau") then
	error("Run tests from the repository root: lune run tests/run", 0)
end

local TestEZ = require("./vendor/testez")

local specs = {}
for _, name in fs.readDir("tests") do
	if string.match(name, "%.spec%.luau$") ~= nil then
		table.insert(specs, name)
	end
end
table.sort(specs)

if #specs == 0 then
	error("No specs found in tests/", 0)
end

local modules = {}
for _, name in specs do
	local stem = string.gsub(name, "%.luau$", "")
	local method = require("./" .. stem)
	if type(method) ~= "function" then
		error(name .. " must return a function", 0)
	end
	local title = string.gsub(stem, "%.spec$", "")
	table.insert(modules, {
		method = method,
		path = { title, "tests" },
		pathStringForSorting = string.lower(title),
	})
end

local plan = TestEZ.TestPlanner.createPlan(modules)
local results = TestEZ.TestRunner.runPlan(plan)
TestEZ.Reporters.TextReporter.report(results)

if results.failureCount > 0 or #results.errors > 0 then
	process.exit(1)
end
