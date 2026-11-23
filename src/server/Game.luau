--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Bin = require("@game/ReplicatedStorage/Shared/Bin")
local Config = require("@game/ReplicatedStorage/Shared/Config")
local DustEconomy = require("@game/ReplicatedStorage/Shared/DustEconomy")
local HudState = require("@game/ReplicatedStorage/Shared/HudState")
local SaveData = require("@game/ReplicatedStorage/Shared/SaveData")
local Upgrades = require("@game/ReplicatedStorage/Shared/Upgrades")

local DataService = require("./DataService")
local World = require("./World")

local Game = {}

type Session = {
	player: Player,
	coins: number,
	binLevel: number,
	binDust: number,
	canSave: boolean,
}

local sessions: { [Player]: Session } = {}
local loading: { [Player]: boolean } = {}
local world: World.Map
local stateEvent: RemoteEvent
local rng = Random.new()
local spawnAccum = 0

local function snapshot(session: Session): SaveData.Data
	return {
		coins = session.coins,
		binLevel = session.binLevel,
		binDust = session.binDust,
	}
end

local function push(session: Session)
	stateEvent:FireClient(session.player, HudState.fromSave(snapshot(session)))
end

local function save(session: Session)
	if session.canSave then
		DataService.save(session.player, snapshot(session))
	end
end

local function rootPart(player: Player): BasePart?
	local character = player.Character
	if character == nil then
		return nil
	end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp ~= nil and hrp:IsA("BasePart") then
		return hrp
	end
	return nil
end

local function weld(part0: BasePart, part1: BasePart)
	local constraint = Instance.new("WeldConstraint")
	constraint.Part0 = part0
	constraint.Part1 = part1
	constraint.Parent = part1
end

local function dress(character: Model)
	local hrpInstance = character:WaitForChild("HumanoidRootPart", 5)
	local humanoidInstance = character:WaitForChild("Humanoid", 5)
	if hrpInstance == nil or not hrpInstance:IsA("BasePart") then
		return
	end
	if humanoidInstance == nil or not humanoidInstance:IsA("Humanoid") then
		return
	end
	if character:FindFirstChild("Vacuum") ~= nil then
		return
	end

	local hrp = hrpInstance
	local humanoid = humanoidInstance
	humanoid.WalkSpeed = Config.WALK_SPEED
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff

	local vacuum = Instance.new("Model")
	vacuum.Name = "Vacuum"
	vacuum.Parent = character

	-- HipHeight is the distance from the floor to the root, so the disc sits
	-- on the ground for whatever avatar Studio spawned.
	local floorY = hrp.Position.Y - humanoid.HipHeight

	local function disc(
		name: string,
		height: number,
		diameter: number,
		centerY: number,
		color: Color3
	): Part
		local item = Instance.new("Part")
		item.Name = name
		item.Shape = Enum.PartType.Cylinder
		-- Cylinders are extruded along X. Rotating them onto Y makes a disc.
		item.Size = Vector3.new(height, diameter, diameter)
		item.Color = color
		item.Material = Enum.Material.SmoothPlastic
		item.Anchored = false
		item.CanCollide = false
		item.CanTouch = false
		item.CanQuery = false
		item.Massless = true
		local offsetY = centerY - hrp.Position.Y
		item.CFrame = hrp.CFrame * CFrame.new(0, offsetY, 0) * CFrame.Angles(0, 0, math.rad(90))
		item.Parent = vacuum
		weld(hrp, item)
		return item
	end

	disc("Bumper", 0.45, 4.8, floorY + 0.35, Color3.fromRGB(42, 46, 52))
	disc("Body", 1.05, 4.15, floorY + 0.85, Color3.fromRGB(236, 238, 242))
	disc("Cap", 0.5, 2.2, floorY + 1.45, Color3.fromRGB(176, 188, 200))

	local led = Instance.new("Part")
	led.Name = "Light"
	led.Shape = Enum.PartType.Ball
	led.Size = Vector3.new(0.42, 0.42, 0.42)
	led.Color = Color3.fromRGB(90, 230, 130)
	led.Material = Enum.Material.Neon
	led.Anchored = false
	led.CanCollide = false
	led.CanTouch = false
	led.CanQuery = false
	led.Massless = true
	led.CFrame = hrp.CFrame * CFrame.new(0, (floorY + 1.7) - hrp.Position.Y, -1.15)
	led.Parent = vacuum
	weld(hrp, led)

	for _, desc in character:GetDescendants() do
		if desc:IsDescendantOf(vacuum) then
			continue
		end
		if desc:IsA("BasePart") or desc:IsA("Decal") or desc:IsA("Texture") then
			desc.Transparency = 1
		end
	end
end

local function bindCharacter(player: Player, character: Model)
	dress(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		return
	end
	humanoid.Died:Connect(function()
		task.delay(1, function()
			if player.Parent == nil or player.Character ~= character then
				return
			end
			player:LoadCharacter()
		end)
	end)
end

local function onDock(position: Vector3): boolean
	local localPos = world.dock.CFrame:PointToObjectSpace(position)
	local half = world.dock.Size / 2
	return math.abs(localPos.X) <= half.X
		and math.abs(localPos.Z) <= half.Z
		and localPos.Y <= half.Y + 6
		and localPos.Y >= -half.Y - 2
end

local function spawnDust()
	if #world.dustFolder:GetChildren() >= Config.MAX_DUST then
		return
	end

	local dockPos = world.dock.Position
	local dockHalf = world.dock.Size / 2
	for _ = 1, 8 do
		local x = rng:NextNumber(world.minX, world.maxX)
		local z = rng:NextNumber(world.minZ, world.maxZ)
		local onPad = math.abs(x - dockPos.X) <= dockHalf.X + 1
			and math.abs(z - dockPos.Z) <= dockHalf.Z + 1
		if not onPad then
			local dust = Instance.new("Part")
			dust.Name = "Dust"
			dust.Shape = Enum.PartType.Ball
			dust.Size = Vector3.new(1.15, 1.15, 1.15)
			dust.Anchored = true
			dust.CanCollide = false
			dust.CanTouch = false
			dust.Material = Enum.Material.Sand
			dust.Color = Color3.fromRGB(
				rng:NextInteger(120, 150),
				rng:NextInteger(108, 132),
				rng:NextInteger(88, 110)
			)
			dust.CFrame = CFrame.new(x, world.floorTop + dust.Size.Y / 2, z)
			dust.Parent = world.dustFolder
			return
		end
	end
end

local function collect(session: Session, origin: Vector3)
	local bin = Bin.new(Upgrades.binCapacity(session.binLevel), session.binDust)
	if Bin.isFull(bin) then
		return
	end

	local changed = false
	for _, child in world.dustFolder:GetChildren() do
		if child:IsA("BasePart") then
			local offset = Vector3.new(child.Position.X - origin.X, 0, child.Position.Z - origin.Z)
			if offset.Magnitude <= Config.SUCTION_RADIUS then
				if Bin.tryAdd(bin, 1) == 0 then
					break
				end
				session.binDust = bin.amount
				child:Destroy()
				changed = true
			end
		end
	end

	if changed then
		push(session)
	end
end

local function sell(session: Session, position: Vector3)
	if session.binDust <= 0 or not onDock(position) then
		return
	end
	local sale = DustEconomy.sell(session.coins, session.binDust)
	session.coins = sale.coins
	session.binDust = 0
	push(session)
	save(session)
end

local function onHeartbeat(dt: number)
	spawnAccum += dt
	if spawnAccum >= Config.DUST_SPAWN_SECONDS then
		spawnAccum = 0
		spawnDust()
	end

	for _, session in sessions do
		local root = rootPart(session.player)
		if root ~= nil then
			collect(session, root.Position)
			sell(session, root.Position)
		end
	end
end

local function addPlayer(player: Player)
	if sessions[player] ~= nil or loading[player] == true then
		return
	end
	loading[player] = true

	local data, canSave = DataService.load(player)
	loading[player] = nil
	if player.Parent == nil then
		return
	end

	local session: Session = {
		player = player,
		coins = data.coins,
		binLevel = data.binLevel,
		binDust = data.binDust,
		canSave = canSave,
	}
	sessions[player] = session

	player.CharacterAdded:Connect(function(character)
		bindCharacter(player, character)
	end)
	if player.Character ~= nil then
		bindCharacter(player, player.Character)
	else
		player:LoadCharacter()
	end
	push(session)
end

local function removePlayer(player: Player)
	local session = sessions[player]
	sessions[player] = nil
	loading[player] = nil
	if session ~= nil then
		save(session)
	end
end

function Game.start()
	-- The room is built before anyone spawns. Respawn is manual because
	-- CharacterAutoLoads would drop players in before the floor exists.
	Players.CharacterAutoLoads = false
	world = World.build()

	local remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage

	stateEvent = Instance.new("RemoteEvent")
	stateEvent.Name = "State"
	stateEvent.Parent = remotes
	-- The first server push can happen before the client is listening.
	stateEvent.OnServerEvent:Connect(function(player: Player)
		local session = sessions[player]
		if session ~= nil then
			push(session)
		end
	end)

	local buyEvent = Instance.new("RemoteEvent")
	buyEvent.Name = "BuyBinUpgrade"
	buyEvent.Parent = remotes

	buyEvent.OnServerEvent:Connect(function(player: Player)
		local session = sessions[player]
		if session == nil then
			return
		end
		local result = Upgrades.tryBuyBin(session.coins, session.binLevel)
		if not result.ok then
			return
		end
		session.coins = result.coins
		session.binLevel = result.level
		push(session)
		save(session)
	end)

	for _ = 1, 10 do
		spawnDust()
	end

	RunService.Heartbeat:Connect(onHeartbeat)
	Players.PlayerAdded:Connect(addPlayer)
	Players.PlayerRemoving:Connect(removePlayer)
	game:BindToClose(function()
		for _, session in sessions do
			save(session)
		end
	end)

	for _, player in Players:GetPlayers() do
		addPlayer(player)
	end
end

return Game
