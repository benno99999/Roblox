--!strict

local HudState = require("@game/ReplicatedStorage/Shared/HudState")

local ENABLED = Color3.fromRGB(58, 148, 86)
local DISABLED = Color3.fromRGB(72, 76, 82)
local PANEL = Color3.fromRGB(22, 26, 30)

local Hud = {}

export type Handle = {
	setState: (state: HudState.State) -> (),
	onUpgrade: (callback: () -> ()) -> (),
}

local function label(
	parent: Instance,
	name: string,
	order: number,
	size: number,
	bold: boolean
): TextLabel
	local item = Instance.new("TextLabel")
	item.Name = name
	item.BackgroundTransparency = 1
	item.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
	item.TextSize = size
	item.TextColor3 = Color3.fromRGB(240, 242, 245)
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.Size = UDim2.new(1, 0, 0, size + 6)
	item.LayoutOrder = order
	item.Text = ""
	item.Parent = parent
	return item
end

function Hud.mount(parent: Instance): Handle
	local upgradeCallback: (() -> ())? = nil

	local gui = Instance.new("ScreenGui")
	gui.Name = "RoboVacHud"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parent

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.BackgroundColor3 = PANEL
	panel.BackgroundTransparency = 0.12
	panel.BorderSizePixel = 0
	panel.Position = UDim2.fromOffset(16, 16)
	panel.Size = UDim2.fromOffset(280, 0)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = panel

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 14)
	padding.PaddingRight = UDim.new(0, 14)
	padding.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = panel

	local title = label(panel, "Title", 1, 20, true)
	title.Text = "Robo-Vac"

	local coins = label(panel, "Coins", 2, 18, false)
	local bin = label(panel, "Bin", 3, 18, false)

	local button = Instance.new("TextButton")
	button.Name = "Upgrade"
	button.LayoutOrder = 4
	button.Size = UDim2.new(1, 0, 0, 36)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 16
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.BackgroundColor3 = DISABLED
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = "Upgrade bin"
	button.Parent = panel

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button

	local hint = label(panel, "Hint", 5, 14, false)
	hint.TextColor3 = Color3.fromRGB(190, 196, 204)
	hint.TextWrapped = true
	hint.Size = UDim2.new(1, 0, 0, 36)
	hint.Text = "Drive over dust. Step on the blue dock to sell."

	button.MouseButton1Click:Connect(function()
		if button.Active and upgradeCallback ~= nil then
			upgradeCallback()
		end
	end)

	local function setState(state: HudState.State)
		coins.Text = string.format("Coins: %d", math.floor(state.coins))
		if state.binDust >= state.binCapacity then
			bin.Text = string.format(
				"Bin: %d / %d (full)",
				math.floor(state.binDust),
				math.floor(state.binCapacity)
			)
		else
			bin.Text = string.format(
				"Bin: %d / %d",
				math.floor(state.binDust),
				math.floor(state.binCapacity)
			)
		end

		local cost = state.upgradeCost
		local nextCapacity = state.nextBinCapacity
		if cost == nil or nextCapacity == nil then
			button.Text = "Bin fully upgraded"
			button.Active = false
			button.AutoButtonColor = false
			button.BackgroundColor3 = DISABLED
			return
		end

		button.Text = string.format("Upgrade bin to %d (%d coins)", nextCapacity, cost)
		local canBuy = state.coins >= cost
		button.Active = canBuy
		button.AutoButtonColor = canBuy
		button.BackgroundColor3 = if canBuy then ENABLED else DISABLED
	end

	return {
		setState = setState,
		onUpgrade = function(callback: () -> ())
			upgradeCallback = callback
		end,
	}
end

return Hud
