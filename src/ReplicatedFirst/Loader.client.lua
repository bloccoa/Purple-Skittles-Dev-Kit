--!strict
--//LOADER
--// Loads replicatedstorage assets and initiates the framework + replicates the main gui
--// glad that im no longer scripting like this like therețs nothing wrong with this
--// but itțs a bit of a little SPaghetti code

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local plrGui = plr:WaitForChild("PlayerGui")

local modules = ReplicatedStorage:WaitForChild("Modules")
local assets = ReplicatedStorage:WaitForChild("Assets")

local frameworkModule = require(modules:WaitForChild("Framework"))

script.Main:Clone().Parent = plrGui

ContentProvider:PreloadAsync(assets:GetDescendants())

frameworkModule()