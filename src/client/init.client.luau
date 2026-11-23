--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HudState = require("@game/ReplicatedStorage/Shared/HudState")
local Hud = require("@self/Hud")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local hud = Hud.mount(playerGui)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local stateEvent = remotes:WaitForChild("State") :: RemoteEvent
local buyEvent = remotes:WaitForChild("BuyBinUpgrade") :: RemoteEvent

stateEvent.OnClientEvent:Connect(function(payload: any)
	local state = HudState.read(payload)
	if state ~= nil then
		hud.setState(state)
	end
end)
stateEvent:FireServer()

hud.onUpgrade(function()
	buyEvent:FireServer()
end)
