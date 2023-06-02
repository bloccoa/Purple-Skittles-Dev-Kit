-- // PLRSTATS
-- // Default values, like default costume and name.
local PlrStats = {}

local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local plrGui = plr.PlayerGui
local mainGui = plrGui.Main

PlrStats.plrLocalName = "Timothy" -- for stuff like "[plrLocalName] got [BLANK] item".

PlrStats.plrChar = nil
PlrStats.plrAppearance = nil
PlrStats.data = nil -- this is a really bad way of doing this
PlrStats.plrItems = nil
PlrStats.room = nil -- probably a really bad way of doing this too
PlrStats.f1 = nil

PlrStats.onpath = false
PlrStats.LOAD = false
PlrStats.battling = false

PlrStats.broat = { false, "" }
PlrStats.maps = {}

PlrStats.stats = {
	["cool"] = 100,
	["attack"] = 10,
	["speed"] = 10,
	["skittles"] = 5,
	["level"] = 1,
	["exp"] = 0,
	["maxcool"] = 10,
}

PlrStats.Keybinds = {
	["Up"] = { "W", "DPadUp", "Up" },
	["Left"] = { "A", "DPadLeft", "Left" },
	["Down"] = { "S", "DPadDown", "Down" },
	["Right"] = { "D", "DPadRight", "Right" },
	["Z"] = { "LeftShift", "ButtonB", "Z" },
	["X"] = { "Space", "ButtonA", "X" },
	["C"] = { "Q", "ButtonY", "C" },
}

PlrStats.MobileButtons = {
	["Z"] = mainGui.touch.buttons.bt1,
	["X"] = mainGui.touch.buttons.bt2,
	["C"] = mainGui.touch.bt3,
}

PlrStats.ButtonsTouching = {
	["Up"] = false,
	["Left"] = false,
	["Down"] = false,
	["Right"] = false,
	["Z"] = false,
	["X"] = false,
	["C"] = false,
}

PlrStats.InputTypes = {
	[Enum.UserInputType.Keyboard] = 1,
	[Enum.UserInputType.Gamepad1] = 2,
	[Enum.UserInputType.Touch] = 3,
}

PlrStats.CurrentInputType = 3

return PlrStats
