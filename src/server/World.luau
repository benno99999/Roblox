--!strict

local Config = require("@game/ReplicatedStorage/Shared/Config")

local World = {}

export type Map = {
	dustFolder: Folder,
	dock: BasePart,
	floorTop: number,
	minX: number,
	maxX: number,
	minZ: number,
	maxZ: number,
}

local FLOOR_COLOR = Color3.fromRGB(186, 152, 112)
local WALL_COLOR = Color3.fromRGB(236, 232, 224)
local DOCK_COLOR = Color3.fromRGB(70, 162, 255)

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cframe
	item.Color = color
	item.Material = material
	item.Anchored = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

function World.build(): Map
	local existing = workspace:FindFirstChild("House")
	if existing ~= nil then
		existing:Destroy()
	end

	local house = Instance.new("Folder")
	house.Name = "House"
	house.Parent = workspace

	local floorSize = Config.ROOM_SIZE
	local floor = part(
		house,
		"Floor",
		Vector3.new(floorSize, 1, floorSize),
		CFrame.new(0, 0, 0),
		FLOOR_COLOR,
		Enum.Material.Wood
	)

	local floorTop = floor.Position.Y + floor.Size.Y / 2
	local half = floorSize / 2
	local wallHeight = 10
	local wallCenterY = floorTop + wallHeight / 2
	local walls = {
		{
			size = Vector3.new(floorSize, wallHeight, 1),
			cframe = CFrame.new(0, wallCenterY, -half),
		},
		{
			size = Vector3.new(floorSize, wallHeight, 1),
			cframe = CFrame.new(0, wallCenterY, half),
		},
		{
			size = Vector3.new(1, wallHeight, floorSize),
			cframe = CFrame.new(-half, wallCenterY, 0),
		},
		{
			size = Vector3.new(1, wallHeight, floorSize),
			cframe = CFrame.new(half, wallCenterY, 0),
		},
	}
	for _, wall in walls do
		part(house, "Wall", wall.size, wall.cframe, WALL_COLOR, Enum.Material.SmoothPlastic)
	end

	local dock = part(
		house,
		"SellPad",
		Vector3.new(9, 0.4, 9),
		CFrame.new(12, floorTop + 0.2, 12),
		DOCK_COLOR,
		Enum.Material.SmoothPlastic
	)
	dock.CanCollide = false

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "SellLabel"
	billboard.Size = UDim2.fromOffset(120, 36)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = dock

	local text = Instance.new("TextLabel")
	text.BackgroundTransparency = 1
	text.Size = UDim2.fromScale(1, 1)
	text.Font = Enum.Font.GothamBold
	text.Text = "SELL"
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextSize = 28
	text.Parent = billboard

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.new(-12, floorTop + 1, -12)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Parent = house

	local dustFolder = Instance.new("Folder")
	dustFolder.Name = "Dust"
	dustFolder.Parent = house

	workspace.FallenPartsDestroyHeight = -50

	local inset = 3
	return {
		dustFolder = dustFolder,
		dock = dock,
		floorTop = floorTop,
		minX = -half + inset,
		maxX = half - inset,
		minZ = -half + inset,
		maxZ = half - inset,
	}
end

return World
