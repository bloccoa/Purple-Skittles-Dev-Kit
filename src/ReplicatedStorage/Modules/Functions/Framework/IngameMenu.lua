--!nocheck
--// INGAMEMENU MODULE
--// module for thIngameMenu

local IngameMenu = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--// VALUES
local plr = Players.LocalPlayer

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local modules = ReplicatedStorage:WaitForChild("Modules")
local assets = ReplicatedStorage:WaitForChild("Assets")

local musicModule = require(modules.Functions.Framework:WaitForChild("MusicModule"))
local Transitions = require(modules.Functions.Framework:WaitForChild("Transitions"))
local plrStatsModule = require(modules.Dictionaries:WaitForChild("PlrStats"))
local itemsModule = require(modules.Dictionaries:WaitForChild("Items"))
local TitleMenu = require(modules.Functions.Framework:WaitForChild("TitleMenu"))

local itemsPage: number = 1

local plrLocalName: string = plrStatsModule.plrLocalName --for stuff like "[plrLocalName] got [BLANK] item".
local MenuScreen: string = "Home"

local cam: Camera = workspace.CurrentCamera

local plrVisibleConnection: RBXScriptConnection = nil

local SFX = SoundService.sfx

local MenuPart = assets.Framework.Menu:Clone()
local MemU = MenuPart.g.menu
local MemO = Instance.new("Vector3Value")
local MenuSelection

local sel, sel2 = nil, nil

IngameMenu.plrsVisible = true
IngameMenu.ITEM = false
IngameMenu.Menu = 0

--// "SWITCHES"
local MenuScreens = {
	["Home"] = function()
		local tx = { "Items", "Stats", "", "Settings", "Main Menu", "Close" }
		local iconstx = {
			"http://www.roblox.com/asset/?id=11720857498",
			"http://www.roblox.com/asset/?id=11720857495",
			"", -- "http://www.roblox.com/asset/?id=11738846055"
			"http://www.roblox.com/asset/?id=11720857501",
			"http://www.roblox.com/asset/?id=11720857500",
			"http://www.roblox.com/asset/?id=11720857496",
		}
		for x = 1, 6 do
			MemU.Selections["sel" .. x].Text = tx[x]
		end
		for x = 1, 6 do
			MemU.Selections["sel" .. x].icon.Image = iconstx[x]
		end
		MemU.title.Text = "Menu"
	end,
	["Items"] = function()
		local pageaddings = (itemsPage - 1) * 5
		for x = 1, 5 do
			MemU.Selections["sel" .. x].Text = itemsModule.itemget(plrStatsModule.plrItems[x + pageaddings])[1]
		end
		for x = 1, 5 do
			MemU.Selections["sel" .. x].icon.Image = ""
		end
		MemU.Selections.sel6.Text = "To Page " .. (itemsPage == 4 and 1 or itemsPage + 1)
		MemU.title.Text = "Items Page " .. itemsPage .. "/4"
	end,
	["Stats"] = function()
		local tx = {
			"Cool: " .. plrStatsModule.stats["cool"] .. "/" .. plrStatsModule.stats["maxcool"],
			"Attack: " .. plrStatsModule.stats["attack"],
			"Speed: " .. plrStatsModule.stats["speed"],
			"Skittles: " .. plrStatsModule.stats["skittles"],
			"Level: " .. plrStatsModule.stats["level"],
			"Exp: " .. plrStatsModule.stats["exp"],
		}
		local iconstx = {
			"http://www.roblox.com/asset/?id=11722816348",
			"http://www.roblox.com/asset/?id=11722816334",
			"http://www.roblox.com/asset/?id=11722816336",
			"http://www.roblox.com/asset/?id=11722816353",
			"http://www.roblox.com/asset/?id=11722882944",
			"http://www.roblox.com/asset/?id=11722816350",
		}
		for x = 1, 6 do
			MemU.Selections["sel" .. x].Text = tx[x]
		end
		for x = 1, 6 do
			MemU.Selections["sel" .. x].icon.Image = iconstx[x]
		end
		MemU.title.Text = plrLocalName .. "'s Stats"
	end,
	["Clothing"] = function()
		local pageaddings = (itemsPage - 1) * 5
		for x = 1, 5 do
			MemU.Selections["sel" .. x].Text = itemsModule.itemget(plrStatsModule.plrItems[x + pageaddings])[1]
		end
		for x = 1, 5 do
			MemU.Selections["sel" .. x].icon.Image = ""
		end
		MemU.Selections.sel6.Text = "To Page " .. (itemsPage == 4 and 1 or itemsPage + 1)
		MemU.title.Text = "Clothing Page " .. itemsPage .. "/4"
	end,
	["Settings"] = function()
		local tx = { "Mute music", "Mute sounds", "Hide other players", "silly setting", "", "Back" }
		MemU.Selections.sel1.Text = SoundService.mus.Volume > 0 and "Mute music" or "Unmute music"
		MemU.Selections.sel2.Text = SoundService.sfx.Volume > 0 and "Mute sounds" or "Unmute sounds"
		MemU.Selections.sel3.Text = IngameMenu.plrsVisible == true and "Hide other players" or "Show other players"
		for x = 4, 6 do
			MemU.Selections["sel" .. x].Text = tx[x]
		end
		for x = 1, 5 do
			MemU.Selections["sel" .. x].icon.Image = ""
		end
		MemU.Selections.sel6.Text = "Back"
		MemU.title.Text = "Settings"
	end,
	["UseItem"] = function()
		local item = itemsModule.itemget(sel)
		local tx = { item[2], "Use.", "Toss.", "", "", "Back" }
		for x = 1, 6 do
			MemU.Selections["sel" .. x].Text = tx[x]
		end
		for x = 1, 5 do
			MemU.Selections["sel" .. x].icon.Image = ""
		end
		MemU.title.Text = item[1]
	end,
	["MainMenu"] = function()
		local tx = { "Yes", "No", "", "", "", "" }
		for x = 1, 6 do
			MemU.Selections["sel" .. x].Text = tx[x]
		end
		for x = 1, 6 do
			MemU.Selections["sel" .. x].icon.Image = ""
		end
		MemU.Selections["sel1"].icon.Image = "http://www.roblox.com/asset/?id=11720857496"
		MemU.Selections["sel2"].icon.Image = "http://www.roblox.com/asset/?id=11720857500"
		MemU.title.Text = "Are you sure?"
	end,
}

--// SETUP
MenuPart.Parent = cam

--// FUNCTIONS
local function loop()
	if IngameMenu.Menu == 2 then
		if not MenuSelection then
			MenuSelection = 1
		end

		MemU.cur.Position = UDim2.new(1, -40, MemU.Selections["sel" .. MenuSelection].Position.Y.Scale, -15)

		for x = 1, 6 do
			MemU.Selections["sel" .. x].TextColor3 = x == MenuSelection and Color3.new(0.3, 0.3, 0.3)
				or Color3.new(0, 0, 0)
		end

		MenuScreens[MenuScreen]()
	end

	MenuPart.CFrame = cam.CFrame * CFrame.new(-1 + MemO.Value.X, 0, -1.8)
	MemU.Size = UDim2.new(0, 320, 0, math.max(64, MemO.Value.Y * 400))
end

remotes.Framework.inpBegan.Event:Connect(function() -- SO INNEFICCICNCIEINTN AAAH90H9H9H999 KIULL
	if plrStatsModule.ButtonsTouching.Z == true then
		if IngameMenu.Menu == 2 then
			SFX.select.Pitch = 0.65
			SFX.select:Play()
			if MenuScreen ~= "Home" and IngameMenu.ITEM == false then
				MenuScreen = MenuScreen == "UseItem" and "Items" or "Home"
				MenuSelection = MenuScreen == "UseItem" and 2 or 1
			end
		end
	elseif plrStatsModule.ButtonsTouching.C == true then
		if IngameMenu.Menu == 2 then
			SFX.select.Pitch = 0.65
			SFX.select:Play()
		end
		MenuSelection = MenuScreen == "UseItem" and 2 or 1
	elseif plrStatsModule.ButtonsTouching.Up == true then
		if IngameMenu.Menu == 2 then
			SFX.select.Pitch = 1
			SFX.select:Play()
			MenuSelection = MenuSelection == 1 and 6 or MenuSelection - 1
		end
	elseif plrStatsModule.ButtonsTouching.X == true then
		if IngameMenu.Menu == 2 then
			SFX.select.Pitch = 0.65
			SFX.select:Play()
		end
	elseif plrStatsModule.ButtonsTouching.Down == true then
		if IngameMenu.Menu == 2 then
			SFX.select.Pitch = 1
			SFX.select:Play()
			if MenuSelection ~= nil then
				MenuSelection = MenuSelection == 6 and 1 or MenuSelection + 1
			else
				MenuSelection = MenuSelection == 6 and 1 or 2
			end
		end
	end
end)

function IngameMenu.menu(open: any?, item: boolean?, saveD: boolean?)
	if not plrStatsModule.battling or item or IngameMenu.ITEM == true then
		if item then
			IngameMenu.ITEM = item or false
			MenuScreen = "Items"
		end
		if open and IngameMenu.Menu == 2 then --interact menu
			if MenuScreen == "Home" then
				if MenuSelection == 1 and not saveD then
					itemsPage = 1
					MenuScreen = "Items"
				elseif MenuSelection == 2 and not saveD then
					MenuScreen = "Stats"
				elseif MenuSelection == 3 then
					--MenuScreen = "Clothing"
				elseif MenuSelection == 4 then
					MenuScreen = "Settings"
				elseif MenuSelection == 5 then
					MenuScreen = "MainMenu"
				elseif MenuSelection == 6 then
					IngameMenu.menu() -- back
				end
			elseif MenuScreen == "Items" then
				if MenuSelection == 6 then -- page advance
					itemsPage = itemsPage == 4 and 1 or itemsPage + 1
				else
					local pageaddings = (itemsPage - 1) * 5
					sel = plrStatsModule.plrItems[MenuSelection + pageaddings]
					if sel ~= "000" then
						MenuScreen = "UseItem"
						sel2 = MenuSelection + pageaddings
					end
				end
				if IngameMenu.ITEM == true then
					MemU.Visible = false
					IngameMenu.Menu = 0
					MenuScreen = "Home"
					local r1, r2, r3 = itemsModule.useitem(
						sel2,
						false,
						plrStatsModule.plrItems,
						plrStatsModule.stats["maxcool"],
						plrStatsModule.plrChar,
						plrStatsModule.stats["cool"],
						plrStatsModule.data[3]
					)
					if r1 then
						plrStatsModule.plrItems = r1
					end
					if r2 then
						plrStatsModule.stats["cool"] = r2
					end
					if r3 then
						plrStatsModule.data[3] = r3
					end
					IngameMenu.ITEM = false
					IngameMenu.Menu = 0
					MenuScreen = "Home"
				end
			elseif MenuScreen == "Stats" then
				MenuScreen = "Home"
			elseif MenuScreen == "Settings" then
				if MenuSelection == 1 then
					if SoundService.mus.Volume > 0 then
						SoundService.mus.Volume = 0
					else
						SoundService.mus.Volume = 0.5
					end
					MemU.Selections.sel1.Text = SoundService.mus.Volume > 0 and "Mute music" or "Unmute music"
				elseif MenuSelection == 2 then
					if SoundService.sfx.Volume > 0 then
						SoundService.sfx.Volume = 0
					else
						SoundService.sfx.Volume = 1
					end
					MemU.Selections.sel2.Text = SoundService.sfx.Volume > 0 and "Mute sounds" or "Unmute sounds"
				elseif MenuSelection == 3 then
					if IngameMenu.plrsVisible == true then
						plrVisibleConnection = workspace.char.ChildAdded:Connect(function(add)
							if add.Name ~= plr.Name then
								for _, c in pairs(add:GetChildren()) do
									if c:IsA("BillboardGui") and c.Name ~= "h" then
										c.Enabled = false
									end
								end
							end
						end)
						for _, v in pairs(workspace.char:GetChildren()) do
							if v.Name ~= plr.Name then
								for _, c in pairs(v:GetChildren()) do
									if c:IsA("BillboardGui") and c.Name ~= "h" then
										c.Enabled = false
									end
								end
							end
						end
						IngameMenu.plrsVisible = false
					else
						for _, v in pairs(workspace.char:GetChildren()) do
							if v.Name ~= plr.Name then
								for _, c in pairs(v:GetChildren()) do
									if c:IsA("BillboardGui") and c.Name ~= "h" then
										c.Enabled = true
									end
								end
							end
						end
						IngameMenu.plrsVisible = true
						plrVisibleConnection:Disconnect()
					end
					MemU.Selections.sel3.Text = IngameMenu.plrsVisible == true and "Hide other players" or "Show other players"
				elseif MenuSelection == 6 then
					MenuScreen = "Home"
				end
			elseif MenuScreen == "UseItem" then
				if MenuSelection == 2 or MenuSelection == 3 then
					local r1, r2, r3
					MemU.Visible = false
					IngameMenu.Menu = 0
					MenuScreen = "Home"
					if MenuSelection == 2 then
						r1, r2, r3 = itemsModule.useitem(
							sel2,
							false,
							plrStatsModule.plrItems,
							plrStatsModule.stats["maxcool"],
							plrStatsModule.plrChar,
							plrStatsModule.stats["cool"],
							plrStatsModule.data[3]
						)
					elseif MenuSelection == 3 then
						r1, r2, r3 = itemsModule.useitem(
							sel2,
							true,
							plrStatsModule.plrItems,
							plrStatsModule.stats["maxcool"],
							plrStatsModule.plrChar,
							plrStatsModule.stats["cool"],
							plrStatsModule.data[3]
						)
					end
					if sel2 > 5 then
						itemsPage = 2
						MenuScreen = "Items"
					else
						MenuScreen = "Items"
					end
					IngameMenu.Menu = 0
					MenuScreen = "Home"
					if r1 then
						plrStatsModule.plrItems = r1
					end
					if r2 then
						plrStatsModule.stats["cool"] = r2
					end
					if r3 then
						plrStatsModule.data[3] = r3
					end
				elseif MenuSelection == 6 then
					MenuScreen = "Home"
				end
			elseif MenuScreen == "MainMenu" then
				if MenuSelection == 1 then
					plrStatsModule.LOAD = true
					Transitions.CircleTransition(false)
					if plrStatsModule.room then
						plrStatsModule.room:Destroy()
					end
					plrStatsModule.plrChar:Destroy()
					musicModule.musicstop()
					MenuScreen = "Home"
					IngameMenu.menu()
					remotes.reload:FireServer()
					plrStatsModule.plrChar = workspace.char:WaitForChild(plr.Name)
					plrStatsModule.plrAppearance = remotes.Appearance.GetAppearance:InvokeServer(plr.Name)
					TitleMenu.InitTitleMenu()
				else
					MenuScreen = "Home"
				end
			end
			MenuSelection = MenuScreen == "UseItem" and 2 or 1
		elseif IngameMenu.Menu == 0 and not _G.c and not open then -- open menu
			MenuScreens[MenuScreen]()
			IngameMenu.Menu = 1
			_G.c = true
			MemU.Visible = true
			MemU.Size = UDim2.new(0, 320, 0, 64)
			MemO.Value = Vector3.new()
			for _, v in pairs(MemU:GetDescendants()) do
				if v:IsA("TextLabel") then
					v.TextTransparency = 1
				end
			end
			TweenService:Create(
				MemO,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{ Value = Vector3.new(1, 0, 0) }
			):Play()
			task.wait(0.15)
			TweenService:Create(
				MemO,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{ Value = Vector3.new(1, 1, 0) }
			):Play()
			for _, v in pairs(MemU:GetDescendants()) do
				if v:IsA("TextLabel") then
					TweenService:Create(
						v,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{ TextTransparency = 0 }
					):Play()
				end
			end
			task.wait(0.15)
			IngameMenu.Menu = 2
        elseif IngameMenu.Menu == 2 and MenuScreen == "Home" and not open then -- close menu
            if IngameMenu.ITEM == true then return end
			IngameMenu.Menu = 1
			TweenService:Create(
				MemO,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{ Value = Vector3.new(1, 0, 0) }
			):Play()
			for _, v in pairs(MemU:GetDescendants()) do
				if v:IsA("TextLabel") then
					TweenService:Create(
						v,
						TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
						{ TextTransparency = 1 }
					):Play()
				end
			end
			task.wait(0.15)
			TweenService:Create(
				MemO,
				TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
				{ Value = Vector3.new() }
			):Play()
			task.wait(0.15)
			MemU.Visible = false
			IngameMenu.Menu = 0
			_G.c = false
        elseif not open and MenuScreen ~= "Home" then
            if IngameMenu.ITEM == true then return end
			MenuScreens[MenuScreen]()
			MenuScreen = MenuScreen == "UseItem" and "Items" or "Home"
		end
	end
end

--// CONNECTIONS
RunService.RenderStepped:Connect(loop)

return IngameMenu
