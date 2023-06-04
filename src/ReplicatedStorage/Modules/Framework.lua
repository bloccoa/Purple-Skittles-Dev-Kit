--!nocheck
--//FRAMEWORK
--// The main game script.

return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local UserInputService = game:GetService("UserInputService")
	local ContentProvider = game:GetService("ContentProvider")
	local SoundService = game:GetService("SoundService")
	local StarterGui = game:GetService("StarterGui")
	local RunService = game:GetService("RunService")
	local Lighting = game:GetService("Lighting")
	local Players = game:GetService("Players")

	--//TYPES
	type plrAppearance = {
		name: string,
		skin: string,
		big: boolean,
	}

	--//VALUES
	local plr = Players.LocalPlayer
	local plrGui = plr.PlayerGui
	local mainGui = plrGui.Main

	local modules = ReplicatedStorage:WaitForChild("Modules")
	local assets = ReplicatedStorage:WaitForChild("Assets")
	local remotes = ReplicatedStorage:WaitForChild("Remotes")

	local LightingModule = require(modules:WaitForChild("Functions"):WaitForChild("Framework"):WaitForChild("Lighting"))
	local musicSets = require(modules:WaitForChild("Dictionaries"):WaitForChild("musicSets"))
	local musicModule = require(modules.Functions.Framework:WaitForChild("MusicModule"))
	local plrStatsModule = require(modules.Dictionaries:WaitForChild("PlrStats"))
	local itemsModule = require(modules.Dictionaries:WaitForChild("Items"))
	local Transitions = require(modules.Functions.Framework:WaitForChild("Transitions"))
	local ingameMenu = require(modules.Functions.Framework:WaitForChild("IngameMenu"))
	local TitleMenu = require(modules.Functions.Framework:WaitForChild("TitleMenu"))
	local SavingModule = require(modules.Functions:WaitForChild("SavingModule"))
	local chatModule = require(modules.Functions.Framework:WaitForChild("Chat"))

	plrStatsModule.plrChar = workspace.char:WaitForChild(plr.Name)
	plrStatsModule.plrAppearance = remotes.Appearance.GetAppearance:InvokeServer(plr.Name)
	local InpType: Enum.UserInputType = Enum.UserInputType.Keyboard

	local cam = workspace.CurrentCamera

	local SFX = SoundService.sfx
	local musSound = SoundService.music

	local effect: ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")

	local f1: BasePart = nil
	local saved = nil
	local BL

	local runn: boolean = false
	local NoInteract: boolean = false
	local runn2: boolean = false
	local CONT: boolean = false
	local saveD: boolean = false
	local visible: boolean = true

	local OriginalPlrPos: Vector3 = Vector3.new()
	local face: Vector3 = Vector3.new(0, 0, 1)
	local side, hold = Vector3.new()
	local dir: Vector3 = Vector3.new()
	local cp: Vector3 = Vector3.new() -- why is this named like this

	local pre = {}

	-- inputs
	local updateinputforthesetxts = {}
	local updateinputforthese = {
		mainGui.credits.group.exit,
	}

	local IgnoreParams = RaycastParams.new()
	IgnoreParams.FilterDescendantsInstances = { plrStatsModule.plrChar, workspace.char }
	IgnoreParams.FilterType = Enum.RaycastFilterType.Exclude

	--//SETUP
	StarterGui:SetCoreGuiEnabled("Backpack", false)

	for name, id in pairs(musicSets.ids) do
		table.insert(pre, id)
	end

	ContentProvider:PreloadAsync(pre)

	if not ReplicatedStorage:FindFirstChild("push") then
		workspace:WaitForChild("map"):WaitForChild("push").Parent = ReplicatedStorage
		workspace.map:WaitForChild("npcs").Parent = ReplicatedStorage
		workspace:WaitForChild("RE").Parent = ReplicatedStorage
	end

	chatModule.ChatLabel.Parent = cam

	effect.Name = "FX"
	effect.Parent = Lighting

	plrStatsModule.plrChar.h.AlwaysOnTop = true
	plrStatsModule.plrChar.n.AlwaysOnTop = true

	--//FUNCTIONS

	local function faceit(dir: Vector3, char, BL, hold)
		if dir.Magnitude > 0.1 then
			local e = math.sin(tick() * 15) > 0 and 100 or 150
			local d = CFrame.new(Vector3.new(0), dir).LookVector
			if hold then
				d = -side
			end
			if d.Z > math.sin(math.pi / 4) then
				char.b.b.ImageRectOffset = Vector2.new(e, 0)
				char.b.b.ImageRectSize = Vector2.new(50, 50)
				return Vector3.new(0, 0, 1)
			elseif d.Z < -math.sin(math.pi / 4) then
				char.b.b.ImageRectOffset = Vector2.new(e, 100)
				char.b.b.ImageRectSize = Vector2.new(50, 50)
				return Vector3.new(0, 0, -1)
			elseif d.X <= -math.sin(math.pi / 4) then
				char.b.b.ImageRectOffset = Vector2.new(e, 50)
				char.b.b.ImageRectSize = Vector2.new(50, 50)
				return Vector3.new(-1, 0, 0)
			elseif d.X >= math.sin(math.pi / 4) then
				char.b.b.ImageRectOffset = Vector2.new(50 + e, 50)
				char.b.b.ImageRectSize = Vector2.new(-50, 50)
				return Vector3.new(1, 0, 0)
			end
		elseif char.b.b.ImageRectSize.X > 0 then
			char.b.b.ImageRectOffset = Vector2.new((BL < 0 and 50 or 0), char.b.b.ImageRectOffset.Y)
		else
			char.b.b.ImageRectOffset = Vector2.new(50 + (BL < 0 and 50 or 0), char.b.b.ImageRectOffset.Y)
		end
	end

	function _G.trs(t)
		if t then
			cp = plrStatsModule.plrChar.Position
		end
		Transitions.CircleTransition(t)
	end

	function _G.giveItem(num, ite, toss)
		SFX.itemget:Play()
		num = num < 10 and "00" .. tostring(num) or num < 100 and "0" .. tostring(num) or tostring(num)
		local temp = ite or plrStatsModule.plrItems
		for i, v in pairs(temp) do
			if v == "000" then
				if toss then
					return true
				end
				temp[i] = num
				if not toss then
					plrStatsModule.plrItems = temp
				end
				return itemsModule.itemget(num), plrStatsModule.plrItems
			end
		end
	end

	function _G.canItem(num)
		local list = { 13, 23, 27, 31, 40, 41, 48, 50, 51, 52, 57, 90, 95 }
		for _, v in pairs(list) do
			if tonumber(num) == v then
				return true
			end
		end
	end

	local function defsave()
		--3=outfit 4=room
		local ite = ""
		for _, v in pairs(plrStatsModule.plrItems) do
			ite = ite .. v
		end
		local dt = {
			plrStatsModule.data[1],
			ite,
			plrStatsModule.data[3],
			plrStatsModule.data[4],
			plrStatsModule.stats["cool"],
			"0",
			plrStatsModule.stats["attack"],
			plrStatsModule.stats["speed"],
			plrStatsModule.stats["skittles"],
			plrStatsModule.stats["level"],
			plrStatsModule.stats["exp"],
			plrStatsModule.stats["maxcool"],
		}
		for x = 1, modules.Dictionaries["NPC SAVE LOG"].NumberOfSaves.Value do
			if not SavingModule.npcsave[x] then
				SavingModule.npcsave[x] = 0
			end
		end
		remotes.save:FireServer(dt, SavingModule.npcsave)
		saveD = true
		saveD = false
	end

	--wake me up inside
	function _G.saveme(n)
		saved = false
		plrStatsModule.data[1] = tostring(n)
		defsave()
		repeat
			RunService.RenderStepped:Wait()
		until saved
		return
	end

	function _G.GPOS(pos, ach, dir)
		plrStatsModule.plrChar.CFrame = CFrame.new(pos)
		plrStatsModule.plrChar.Anchored = ach
		if dir then
			faceit(dir, plrStatsModule.plrChar, 100, false)
		end
	end

	function _G.get(str)
		if str == "skittles" then
			return plrStatsModule.stats["skittles"]
		elseif str == "broat" then
			return plrStatsModule.broat[1]
		elseif str == "attack" then
			return plrStatsModule.stats["attack"]
		elseif str == "speed" then
			return plrStatsModule.stats["speed"]
		end
	end

	function _G.set(str, value)
		if str == "skittles" then
			plrStatsModule.stats["skittles"] = value
		elseif str == "runn" then
			runn = value
			plrStatsModule.plrChar.b.b.ImageColor3 = Color3.new(0, 0, 1)
			plrStatsModule.plrChar.b.b.ac.ImageColor3 = Color3.new(0, 0, 1)
		elseif str == "runn2" then
			runn2 = value
		elseif str == "attack" then
			plrStatsModule.stats["attack"] = plrStatsModule.stats["attack"] + 2
		elseif str == "speed" then
			plrStatsModule.stats["speed"] = plrStatsModule.stats["speed"] + 2
		elseif str == "speedattack" then
			plrStatsModule.stats["attack"] = plrStatsModule.stats["attack"] + 1
			plrStatsModule.stats["speed"] = plrStatsModule.stats["speed"] + 1
		end
	end

	function _G.coolme()
		plrStatsModule.stats["cool"] = plrStatsModule.stats["maxcool"]
		return plrStatsModule.stats["maxcool"]
	end

	--//INPUT
	local function inp(k, dn)
		if not plrStatsModule.LOAD then
			if dn then
				if table.find(plrStatsModule.Keybinds.Up, k) then
					plrStatsModule.ButtonsTouching.Up = true
				elseif table.find(plrStatsModule.Keybinds.Left, k) then
					plrStatsModule.ButtonsTouching.Left = true
				elseif table.find(plrStatsModule.Keybinds.Down, k) then
					plrStatsModule.ButtonsTouching.Down = true
				elseif table.find(plrStatsModule.Keybinds.Right, k) then
					plrStatsModule.ButtonsTouching.Right = true
				elseif k == "Backspace" and plr.Name == "Player1" then
					runn = not runn
				elseif table.find(plrStatsModule.Keybinds.X, k) then
					plrStatsModule.ButtonsTouching.X = true

					if not plrStatsModule.battling then
						local RaycastResult = workspace:Raycast(
							plrStatsModule.plrChar.Position + Vector3.new(0, 1),
							face * 2,
							IgnoreParams
						)
						if
							not RaycastResult
							or string.sub(RaycastResult.Instance.Name, 1, 4) == "door"
							or string.sub(RaycastResult.Instance.Name, 1, 4) == "tunn"
							or RaycastResult.Instance.Name == "broat"
						then
							RaycastResult = workspace:Raycast(plrStatsModule.plrChar.Position, face * 2, IgnoreParams)
						end
						if RaycastResult and not NoInteract then
							local instance = RaycastResult.Instance
							if instance.Parent.Name == "npcs" and instance:FindFirstChild("tx") then
								if
									plrStatsModule.stats["cool"] > 0
									or (instance.Name == "Dr. Cool" or instance.Name == "looC .rD" or instance.Name == "Spacedoc" or instance.Name == "Cool Doctor")
									or instance.Name == "Penpoint"
								then
									chatModule.Chat(instance.tx, instance)
								end
							elseif instance.Name == "door" then
								NoInteract = true
								Transitions.CircleTransition()
								plrStatsModule.room.Parent = nil
								plrStatsModule.room = nil
								plrStatsModule.plrChar.CFrame = CFrame.new(OriginalPlrPos)
								cp = OriginalPlrPos
								plrStatsModule.plrChar.p.Position = plrStatsModule.plrChar.Position
								plrStatsModule.data[4] = "0"
								Transitions.CircleTransition(1)
								NoInteract = false
							elseif string.sub(instance.Name, 1, 4) == "door" then
								NoInteract = true
								Transitions.CircleTransition()
								if plrStatsModule.room then
									plrStatsModule.room.Parent = nil
								else
									OriginalPlrPos = plrStatsModule.plrChar.Position
								end
								plrStatsModule.room = plrStatsModule.maps[4][tonumber(string.sub(instance.Name, 5, -1))]
								plrStatsModule.room.Parent = cam
								plrStatsModule.room.white.Transparency = 0
								plrStatsModule.room:SetPrimaryPartCFrame(CFrame.new(0, 100, 0))
								plrStatsModule.plrChar.CFrame =
									CFrame.new((plrStatsModule.room.door.CFrame * CFrame.new(0, 0, -2)).Position)
								plrStatsModule.plrChar.p.Position = plrStatsModule.plrChar.Position
								cp = plrStatsModule.plrChar.Position
								plrStatsModule.data[4] = tostring(string.sub(instance.Name, 5, -1))
								if plrStatsModule.room:FindFirstChild("Lighting") then
									LightingModule:update(plrStatsModule.room.Lighting, TweenInfo.new(0))
								end
								Transitions.CircleTransition(1)
								NoInteract = false
							elseif string.sub(instance.Name, 1, 4) == "tunn" then
								NoInteract = true
								Transitions.CircleTransition()
								if plrStatsModule.data[4] == "0" then
									plrStatsModule.room =
										plrStatsModule.maps[5][tonumber(string.sub(instance.Name, 5, -1))]
									plrStatsModule.room.Parent = cam
									plrStatsModule.room.white.Transparency = 0
									plrStatsModule.room:SetPrimaryPartCFrame(CFrame.new(0, 100, 0))
									for _, v in pairs(plrStatsModule.room:GetChildren()) do
										if v:FindFirstChild("topz") and v.topz.Value == instance.topz.Value then
											plrStatsModule.plrChar.CFrame = v.CFrame - v.CFrame.LookVector * 2
											break
										end
									end
									plrStatsModule.plrChar.p.Position = plrStatsModule.plrChar.Position
									cp = plrStatsModule.plrChar.Position
									plrStatsModule.data[4] = "t" .. tostring(string.sub(instance.Name, 5, -1))
								else
									for _, v in pairs(workspace.map:GetChildren()) do
										if
											v.Name == plrStatsModule.room.Name
											and v.topz.Value == instance.topz.Value
										then --fix this
											plrStatsModule.plrChar.CFrame = v.CFrame - v.CFrame.LookVector * 2
											break
										else
											for _, v in pairs(cam.npcs:GetChildren()) do
												if
													v.Name == plrStatsModule.room.Name
													and v.topz.Value == instance.topz.Value
												then --fix this
													plrStatsModule.plrChar.CFrame = v.CFrame - v.CFrame.LookVector * 2
													break
												end
											end
										end
									end
									plrStatsModule.room.Parent = nil
									plrStatsModule.room = nil
									plrStatsModule.plrChar.p.Position = plrStatsModule.plrChar.Position
									plrStatsModule.data[4] = "0"
								end
								cp = plrStatsModule.plrChar.Position
								Transitions.CircleTransition(1)
								NoInteract = false
							elseif instance.Name == "broat" then
								if not plrStatsModule.broat[1] then
									plrStatsModule.broat[1] = true
									plrStatsModule.broat[2] = plrStatsModule.plrChar.b.b.Image
									plrStatsModule.plrChar.b.b.Image = "http://www.roblox.com/asset/?id=415140172"
									plrStatsModule.plrChar.b.b.ac.Visible = false
									plrStatsModule.plrChar.CFrame = instance.CFrame * CFrame.new(0, 0, 6)
									_G.set("runn2", true)
								else
									plrStatsModule.broat[1] = false
									plrStatsModule.plrChar.b.b.Image = plrStatsModule.broat[2]
									plrStatsModule.plrChar.b.b.ac.Visible = true
									plrStatsModule.plrChar.CFrame = instance.CFrame * CFrame.new(0, 0, -6)
									_G.set("runn2", false)
								end
							end
							remotes.room:FireServer(tostring(plrStatsModule.room))
						end
					end
					if not chatModule.ChatFrame.Visible then
						ingameMenu.menu(true, false, saveD)
					end
				elseif table.find(plrStatsModule.Keybinds.Z, k) then
					plrStatsModule.ButtonsTouching.Z = true
					BL = 0
					if runn and not _G.c then
						chatModule.Chat(assets.Framework.runnEnd, assets.Framework.runnEnd)
						runn = false
						plrStatsModule.plrChar.b.b.ImageColor3 = Color3.new(1, 1, 1)
						plrStatsModule.plrChar.b.b.ac.ImageColor3 = Color3.new(1, 1, 1)
					else
						local RaycastResult = workspace:Raycast(
							plrStatsModule.plrChar.Position + Vector3.new(0, 1),
							face * 2,
							IgnoreParams
						)
						if not RaycastResult then
							RaycastResult = workspace:Raycast(plrStatsModule.plrChar.Position, face * 2, IgnoreParams)
						end

						if RaycastResult then
							local instance = RaycastResult.Instance
							if instance.Name == "Push" or instance.Name == "SecretPush" then
								side, hold = RaycastResult.Normal, instance
								local t = math.abs(plrStatsModule.plrChar.Position.X - instance.Position.X)
									> instance.Size.X / 2
								if plrStatsModule.plrChar.Position.X > instance.Position.X and t then
									side = Vector3.new(1)
								elseif plrStatsModule.plrChar.Position.X < instance.Position.X and t then
									side = Vector3.new(-1)
								elseif plrStatsModule.plrChar.Position.Z > instance.Position.Z then
									side = Vector3.new(0, 0, 1)
								elseif plrStatsModule.plrChar.Position.Z < instance.Position.Z then
									side = Vector3.new(0, 0, -1)
								end
								if instance:FindFirstChild("Dir") and side.Z ~= 0 then
									side, hold = Vector3.new(0)
								elseif instance:FindFirstChild("Dir2") and side.X ~= 0 then
									side, hold = Vector3.new(0)
								end
							end
						end
						if _G.c then
							chatModule.ans = chatModule.ans == 1 and 2 or 1
						end
						if ingameMenu.Menu == 2 then
							if not chatModule.ChatFrame.Visible then
								ingameMenu.menu(false, false, saveD)
							end
						end
					end
				elseif table.find(plrStatsModule.Keybinds.C, k) then
					plrStatsModule.ButtonsTouching.C = true
					if TitleMenu.inMenu == false then
						if not chatModule.ChatFrame.Visible then
							ingameMenu.menu(false, false, saveD)
						end
					end
				end
				remotes.Framework.inpBegan:Fire() -- THIS IS TOO INNEFICIENT THIS SUCKS AAHHHHHHH
			else
				if table.find(plrStatsModule.Keybinds.Up, k) then
					plrStatsModule.ButtonsTouching.Up = false
				elseif table.find(plrStatsModule.Keybinds.Left, k) then
					plrStatsModule.ButtonsTouching.Left = false
				elseif table.find(plrStatsModule.Keybinds.Down, k) then
					plrStatsModule.ButtonsTouching.Down = false
				elseif table.find(plrStatsModule.Keybinds.Right, k) then
					plrStatsModule.ButtonsTouching.Right = false
				elseif table.find(plrStatsModule.Keybinds.X, k) then
					plrStatsModule.ButtonsTouching.X = false
				elseif table.find(plrStatsModule.Keybinds.Z, k) then
					plrStatsModule.ButtonsTouching.Z = false
					if hold then
						hold.p.Position =
							Vector3.new(math.floor(hold.p.Position.X + 0.5), 0, math.floor(hold.p.Position.Z + 0.5))
						side, hold = Vector3.new(0)
					end
				elseif table.find(plrStatsModule.Keybinds.C, k) then
					plrStatsModule.ButtonsTouching.C = false
				end
			end
		end
	end

	local function customTexts(txt) -- lazy import
		if string.find(txt, "%%") then -- there is a punishment for people like me who do this type of overcomplication
			local startval, endval = string.find(txt, "%%")
			local firststring = string.sub(txt, 1, startval - 1)
			local secondstring = string.sub(txt, endval + 5, #txt)
			local inbetween = string.sub(txt, startval + 2, endval + 2)
			if plrStatsModule.Keybinds[inbetween] then
				txt = firststring .. plrStatsModule.Keybinds[inbetween][plrStatsModule.CurrentInputType] .. secondstring
			end
		end
		return txt
	end

	--//TOUCHSCREEN
	local function tooch(pos)
		local pw, pa, ps, pd = 0, 0, 0, 0
		local to = mainGui.touch.to
		local pr = Vector3.new(pos.X, 0, pos.Y) - Vector3.new(to.AbsolutePosition.X + 70, 0, to.AbsolutePosition.Y + 70)

		if pr.Magnitude > 10 then
			for i, v in pairs(plrGui:GetGuiObjectsAtPosition(pos.X, pos.Y)) do
				if v:IsA("Frame") and v:IsDescendantOf(to) then
					if v.Name == "up" then --Up
						to.ImageRectOffset = Vector2.new(161, 23)
						pw = true
					elseif v.Name == "down" then --Down
						to.ImageRectOffset = Vector2.new(161, 300)
						ps = true
					elseif v.Name == "left" then --Left
						to.ImageRectOffset = Vector2.new(24, 162)
						pa = true
					elseif v.Name == "right" then --Right
						to.ImageRectOffset = Vector2.new(300, 162)
						pd = true
					elseif v.Name == "downright" then --DownRight
						to.ImageRectOffset = Vector2.new(300, 300)
						ps, pd = true, true
					elseif v.Name == "downleft" then --DownLeft
						to.ImageRectOffset = Vector2.new(22, 300)
						pa, ps = true, true
					elseif v.Name == "upright" then --UpRight
						to.ImageRectOffset = Vector2.new(300, 24)
						pw, pd = true, true
					elseif v.Name == "upleft" then --UpLeft
						to.ImageRectOffset = Vector2.new(23, 24)
						pw, pa = true, true
					else --Middle
						to.ImageRectOffset = Vector2.new(161, 162)
					end
					break
				end
			end
		else --Middle
			to.ImageRectOffset = Vector2.new(161, 162)
		end

		if pw ~= plrStatsModule.ButtonsTouching.Up then
			inp("Up", pw == true)
		end
		if pa ~= plrStatsModule.ButtonsTouching.Left then
			inp("Left", pa == true)
		end
		if ps ~= plrStatsModule.ButtonsTouching.Down then
			inp("Down", ps == true)
		end
		if pd ~= plrStatsModule.ButtonsTouching.Right then
			inp("Right", pd == true)
		end
	end

	mainGui.touch.to.InputChanged:Connect(function(obj)
		tooch(Vector2.new(obj.Position.X, obj.Position.Y))
	end)
	mainGui.touch.to.InputBegan:Connect(function(obj)
		tooch(Vector2.new(obj.Position.X, obj.Position.Y))
	end)
	mainGui.touch.to.InputEnded:Connect(function()
		mainGui.touch.to.ImageRectOffset = Vector2.new(161, 162)
	end)

	for i, v in pairs(plrStatsModule.MobileButtons) do
		v.MouseButton1Down:Connect(function()
			if plrStatsModule.ButtonsTouching[i] == false then
				inp(i, true)
			end
		end)
		v.MouseButton1Up:Connect(function()
			if plrStatsModule.ButtonsTouching[i] == true then
				inp(i, false)
			end
		end)
		v.InputBegan:Connect(function()
			if plrStatsModule.ButtonsTouching[i] == false then
				inp(i, true)
			end
		end)
		v.InputEnded:Connect(function()
			if plrStatsModule.ButtonsTouching[i] == true then
				inp(i, false)
			end
		end)
	end

	_G.c = false

	local function inputTypeChanged(lastInputType)
		InpType = lastInputType
		if plrStatsModule.InputTypes[InpType] then
			plrStatsModule.CurrentInputType = plrStatsModule.InputTypes[InpType]
		end
		if InpType == Enum.UserInputType.Touch then
			mainGui.touch.Visible = true
			mainGui.ctrl.Visible = false
		else
			mainGui.touch.Visible = false
			mainGui.ctrl.Visible = true
		end
		for _, v in pairs(updateinputforthese) do
			if not updateinputforthesetxts[v.Name] then
				updateinputforthesetxts[v.Name] = v.Text
				v.Text = customTexts(v.Text)
			else
				v.Text = customTexts(updateinputforthesetxts[v.Name])
			end
		end
	end

	--//REMOTES
	remotes.save.OnClientEvent:Connect(function(d, s)
		if s then
			saved = true
		else
			if d and d ~= "gg" then
				plrStatsModule.data = d --20 items,clothes,?,room
			else
				plrStatsModule.data = {}
			end
		end
	end)
	remotes.Framework.setCamPos.Event:Connect(function(_pos, _posAddition)
		if _pos ~= false then
			cp = _pos
		else
			cp += _posAddition
		end
	end)

	--//CONNECTIONS
	--//INPUT
	UserInputService.InputChanged:Connect(function(input, gameproc, ip)
		if gameproc then
			return
		end
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			ip = Vector3.new(input.Position.X, 0, -input.Position.Y)
			CONT = true
			local sp = (ip.Magnitude > 1 and CFrame.new(Vector3.new(0), ip).LookVector or ip)
			dir = (ip.Magnitude > 0.1 and CFrame.new(Vector3.new(0), ip).LookVector * sp.Magnitude or Vector3.new(0))
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			ip = Vector3.new(input.Position.X, 0, -input.Position.Y)
			CONT = true
		end
	end)
	UserInputService.InputBegan:Connect(function(k, gameproc)
		if gameproc then
			return
		end
		k = string.sub(tostring(k.KeyCode), 14, -1)
		inp(k, true)
	end)
	UserInputService.InputEnded:Connect(function(k)
		k = string.sub(tostring(k.KeyCode), 14, -1)
		inp(k)
	end)
	UserInputService.LastInputTypeChanged:Connect(inputTypeChanged)
	inputTypeChanged(UserInputService:GetLastInputType()) -- this should fix my mobile phone not working at all with this

	local zonesWhitelist = workspace.zones:GetChildren()
	cam.ChildAdded:Connect(function(ch)
		for _, v in pairs(ch:GetDescendants()) do
			if musicSets.translate[v.Name] then
				table.insert(zonesWhitelist, v)
			end
		end
	end)

	--//menu
	TitleMenu.InitTitleMenu()

	--//loops
	RunService.RenderStepped:Connect(function(dt)
		if not plrStatsModule.LOAD and TitleMenu.inMenu == false then
			local gdir = dir

			local wasd = {
				plrStatsModule.ButtonsTouching.Up,
				plrStatsModule.ButtonsTouching.Left,
				plrStatsModule.ButtonsTouching.Down,
				plrStatsModule.ButtonsTouching.Right,
			} --THIS IS INNEFICIENT. AND IT'S BAD. Oh well
			for i, v in pairs(wasd) do
				if v == true then
					wasd[i] = 1
				else
					wasd[i] = 0
				end
			end
			if math.abs(wasd[1] - wasd[3]) + math.abs(wasd[2] - wasd[4]) > 0 then
				gdir = CFrame.new(Vector3.new(), Vector3.new(wasd[4] - wasd[2], 0, wasd[3] - wasd[1])).LookVector
			elseif not CONT then
				gdir = Vector3.new()
			end
			local ggdir = gdir
			--gdir=gdir*(btb==1 and .5 or (plrStatsModule.stats["speed"]/100-.1+1))
			plrStatsModule.plrChar.b.AlwaysOnTop = plrStatsModule.battling

			if _G.scriptCam == true or plrStatsModule.battling then
			else
				cp = cp:Lerp(plrStatsModule.plrChar.Position, 1 - 0.007 ^ dt)
				cam.CFrame = CFrame.new(cp + Vector3.new(0, (runn2 and 3 or 2), (runn2 and 1.5 or 1)) * 12, cp)
					* CFrame.Angles(0, 0, plrStatsModule.plrChar.b.b.Rotation / 180 * math.pi)
				cam.FieldOfView = 50
				cam.Focus = cam.CFrame
			end

			plrStatsModule.plrChar.p.Position = plrStatsModule.plrChar.Position
			f1 = workspace:FindPartOnRayWithIgnoreList(
				Ray.new(plrStatsModule.plrChar.Position + gdir / 10, Vector3.new(0, -2)),
				{ plrStatsModule.plrChar }
			)
			plrStatsModule.f1 = f1

			if _G.c or mainGui.cut.Visible then
				gdir = Vector3.new(0)
			end
			if plrStatsModule.stats["cool"] <= 0 then
				musSound.Pitch = 1 + math.sin(tick()) / 10
			else
				musSound.Pitch = 1
			end

			if hold then
				local side2 = Vector3.new(math.abs(side.X), 0, math.abs(side.Z))
				plrStatsModule.plrChar.p.MaxForce = Vector3.new(4000, 0, 4000)
				if gdir.Magnitude > 0.1 then
					hold.p.Position = hold.Position + gdir * side2 / 2
				else
					hold.p.Position =
						Vector3.new(math.floor(hold.p.Position.X + 0.5), 0, math.floor(hold.p.Position.Z + 0.5))
				end
				plrStatsModule.plrChar.p.Position = hold.Position + (side * 2 + gdir * side2 / 2)
				if
					(hold.Position - plrStatsModule.plrChar.Position).Magnitude > 4
					or math.abs(hold.Position.Y - plrStatsModule.plrChar.Position.Y) > 2
				then
					side, hold = Vector3.new(0)
				end
			elseif gdir.Magnitude > 0.1 and f1 then
				plrStatsModule.plrChar.p.MaxForce = Vector3.new(4000, 0, 4000)
				local slow = (f1 and f1.Name == "slow" and 0.75 or 1)
				slow = plrStatsModule.stats["cool"] < 0 and 0.75 or slow
				plrStatsModule.plrChar.p.Position = plrStatsModule.plrChar.Position
					+ gdir * slow * (runn and 3 or runn2 and 1.75 or 1)
				if runn then
					plrStatsModule.plrChar.AssemblyLinearVelocity = Vector3.new(
						plrStatsModule.plrChar.AssemblyLinearVelocity.X,
						math.min(0, plrStatsModule.plrChar.AssemblyLinearVelocity.Y),
						plrStatsModule.plrChar.AssemblyLinearVelocity.Z
					)
				end
				if runn2 then
					plrStatsModule.plrChar.AssemblyLinearVelocity = Vector3.new(
						plrStatsModule.plrChar.AssemblyLinearVelocity.X,
						math.min(0, plrStatsModule.plrChar.AssemblyLinearVelocity.Y),
						plrStatsModule.plrChar.AssemblyLinearVelocity.Z
					)
				end
			elseif f1 then
				plrStatsModule.plrChar.p.MaxForce = Vector3.new(4000, 0, 4000)
			else
				plrStatsModule.plrChar.p.MaxForce = Vector3.new(1, 0, 1)
					* math.min(0, math.max(1, math.abs(plrStatsModule.plrChar.AssemblyLinearVelocity.Y * 10)))
				--p.p.Position=Vector3.new(math.floor(p.Position.X/2+.5)*2,0,math.floor(p.Position.Z/2+.5)*2)
			end

			local param = RaycastParams.new()
			param.FilterType = Enum.RaycastFilterType.Include
			param.FilterDescendantsInstances = zonesWhitelist
			local ray = workspace:Raycast(plrStatsModule.plrChar.Position, Vector3.new(0, 999, 0), param)
			local r1 = ray and ray.Instance

			if r1 and not plrStatsModule.battling and not _G.c then
				local area = musicSets.translate[r1.Name]
				if r1.Name == "sIlence" or not musicSets.ids[area] then -- im not removing this hhh9hahah
					musSound.Volume = 0
					SFX.yalikejazz.Volume = 0.2
					musSound.SoundId = ""
				elseif musSound.SoundId ~= musicSets.ids[area] then
					musicModule.music = musicSets.ids[area]
					musicModule.musicstop()
					musSound.SoundId = musicModule.music
					musSound.Volume = 0.35
					musSound:Play()
					if assets.lighting:FindFirstChild(area) then
                        LightingModule:update(assets.lighting[area])
					end
				end
			end

			BL = not BL and 0 or BL - 1
			if BL < -10 then
				BL = math.random(100, 200)
			end

			mainGui.uncool.Visible = plrStatsModule.stats["cool"] <= 0

			face = faceit(gdir, plrStatsModule.plrChar, BL, hold) or face
			plrStatsModule.plrChar.b.b.ac.ImageRectOffset = Vector2.new(
				plrStatsModule.plrChar.b.b.ImageRectOffset.Y
					+ (plrStatsModule.plrChar.b.b.ImageRectSize.X < 0 and 50 or 0),
				0
			)
			plrStatsModule.plrChar.b.b.ac.ImageRectSize = Vector2.new(plrStatsModule.plrChar.b.b.ImageRectSize.X, 100)

			if plrStatsModule.plrChar.Position.Y < -100 then
				plrStatsModule.plrChar.CFrame = assets.p.CFrame
			end

			chatModule.ChatLabel.CFrame = chatModule.ChatFrame.Visible and cam.CFrame * CFrame.new(0, -0.3, -1.8)
				or CFrame.new()

			if chatModule.ChatFrame.Visible and plrStatsModule.battling then
				chatModule.ChatLabel.CFrame = chatModule.ChatFrame.Visible and cam.CFrame * CFrame.new(0, -0.3, -1.38)
					or CFrame.new()
				plrStatsModule.plrChar.b.AlwaysOnTop = false
			end

			for i, v in pairs(chatModule.ChatFrame.Frame:GetChildren()) do --opex
				if v.Name == "B_" then
					v.Rotation = math.sin(tick() * 10) * 45 + 15
				elseif v.Name == "B^" then
					v.n.Value = v.n.Value + 1 / 10
					if v.n.Value > 6 then
						v.n.Value = 0
					end
					local ti = v.n.Value
					if ti > 5 then
						local x = ti - 5
						v.TextColor3 = Color3.new(1, 0, 1):Lerp(Color3.new(1, 0, 0), x)
					elseif ti > 4 then
						local x = ti - 4
                        v.TextColor3 = Color3.new(0, 0, 1):Lerp(Color3.new(1, 0, 1), x)
					elseif ti > 3 then
						local x = ti - 3
                        v.TextColor3 = Color3.new(0, 1, 1):Lerp(Color3.new(0, 0, 1), x)
					elseif ti > 2 then
						local x = ti - 2
                        v.TextColor3 = Color3.new(0, 1, 0):Lerp(Color3.new(0, 1, 1), x)
					elseif ti > 1 then
						local x = ti - 1
                        v.TextColor3 = Color3.new(1, 1, 0):Lerp(Color3.new(0, 1, 0), x)
					else
						local x = ti
                        v.TextColor3 = Color3.new(1, 0, 0):Lerp(Color3.new(1, 1, 0), x)
					end
					v.Position = UDim2.new(0, v.Position.X.Offset, 0, v.p.Value + math.sin(tick() * 10 + i) * 5)
				elseif v.Name == "B&" then
					v.Position = UDim2.new(0, v.x.Value + math.random(-1, 1), 0, v.y.Value + math.random(-1, 1))
				end
			end

			plrStatsModule.plrChar.h.hp.Text = plrStatsModule.stats["cool"]
			plrStatsModule.plrChar.h.fillFrame.fill.Size =
				UDim2.new(plrStatsModule.stats["cool"] / plrStatsModule.stats["maxcool"], 0, 1, 0) -- too lazy to think of a proper way to do this

			local Pdir = nil
			if _G.c then
				if dir.Magnitude >= 1 and not Pdir then
					Pdir = true
					--if Menu == 2 then
					--	SFX.select.Pitch = 1
					--	SFX.select:Play()
					--	if dir.Z > 0 then
					--		MenuSelection = MenuSelection == 6 and 1 or MenuSelection + 1
					--	else
					--		MenuSelection = MenuSelection == 1 and 6 or MenuSelection - 1
					--	end
					--else
					chatModule.ans = chatModule.ans == 1 and 2 or 1
					--end
				elseif dir.Magnitude < 0.8 then
					Pdir = nil
				end
			end

			for _, v in pairs(Players:GetChildren()) do
				if v ~= plr then
					local r = workspace.char:FindFirstChild(v.Name)
					if r then
						visible = ingameMenu.plrsVisible
						if v.area.Value ~= plr.area.Value or plrStatsModule.battling or not visible then
							r.h.Enabled = false
							r.b.Enabled = false
							r.n.Enabled = false
						end
						if visible then
							r.b.b.ac.ImageRectOffset =
								Vector2.new(r.b.b.ImageRectOffset.Y + (r.b.b.ImageRectSize.X < 0 and 50 or 0), 0)
							r.b.b.ac.ImageRectSize = Vector2.new(r.b.b.ImageRectSize.X, 100)
							r.b.Enabled = true
							r.h.Enabled = false
							r.n.t.Text = v.DisplayName
							r.n.Enabled = true
						end
						local d = Vector3.new(r.Velocity.X, 0, r.Velocity.Z)
						d = d.Magnitude > 0.1 and CFrame.new(Vector3.new(), d).LookVector or Vector3.new()
						if v.Name ~= plr.Name then
							faceit(d, r, 10, false) -- animate for others??? Yesss
							r.b.b.ac.ImageRectOffset =
								Vector2.new(r.b.b.ImageRectOffset.Y + (r.b.b.ImageRectSize.X < 0 and 50 or 0), 0)
							r.b.b.ac.ImageRectSize = Vector2.new(r.b.b.ImageRectSize.X, 100)
						end
					end
				end
			end

			local r, e = Color3.new(1, 0, 0), Color3.new(0.5, 0.5, 0.5)
			mainGui.ctrl.u.BackgroundColor3 = ggdir.Z < -0.2 and r or e
			mainGui.ctrl.d.BackgroundColor3 = ggdir.Z > 0.2 and r or e
			mainGui.ctrl.l.BackgroundColor3 = ggdir.X < -0.2 and r or e
			mainGui.ctrl.r.BackgroundColor3 = ggdir.X > 0.2 and r or e
			mainGui.ctrl.a.BackgroundColor3 = plrStatsModule.ButtonsTouching.X == true and r or e
			mainGui.ctrl.b.BackgroundColor3 = plrStatsModule.ButtonsTouching.Z == true and r or e
			mainGui.ctrl.st.BackgroundColor3 = plrStatsModule.ButtonsTouching.C == true and r or e
			local u = 999
			mainGui.touch.buttons.bt1.ImageRectOffset =
				Vector2.new(plrStatsModule.ButtonsTouching.Z == true and 125 or 0, 0)
			mainGui.touch.buttons.bt2.ImageRectOffset =
				Vector2.new(plrStatsModule.ButtonsTouching.X == true and 125 or 0, 0)
			mainGui.touch.bt3.ImageRectOffset = Vector2.new(plrStatsModule.ButtonsTouching.C == true and 125 or 0, 0)

			for _, v in pairs(plrStatsModule.maps[3]:GetChildren()) do
				if (v.Position - plrStatsModule.plrChar.Position).Magnitude < 50 and not _G.c then
					v.move.Value = v.move.Value + 1
					if v.move.Value > 100 then
						v.move.Value = 0
						local r = math.random(4)
						v.p.Position = v.Position
							+ Vector3.new(r == 1 and 1 or r == 2 and -1 or 0, 0, r == 3 and 1 or r == 4 and -1 or 0)
								* 2
						v.Anchored = false
					end
					v.b.b.ImageRectOffset = Vector2.new(math.sin(tick() * 12) > 0 and 200 or 0, 0)
				end
			end
		end
	end)
end
