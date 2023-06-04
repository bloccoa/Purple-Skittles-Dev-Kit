--!nocheck
local returnthis = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--//VALUES
local plr = Players.LocalPlayer
local plrGui = plr.PlayerGui
local mainGui = plrGui.Main

local modules = ReplicatedStorage:WaitForChild("Modules")
local assets = ReplicatedStorage:WaitForChild("Assets")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local LightingModule = require(modules:WaitForChild("Functions"):WaitForChild("Framework"):WaitForChild("Lighting"))
local Transitions = require(modules.Functions.Framework:WaitForChild("Transitions"))
local musicModule = require(modules.Functions.Framework:WaitForChild("MusicModule"))
local plrStatsModule = require(modules.Dictionaries:WaitForChild("PlrStats"))
local SavingModule = require(modules.Functions:WaitForChild("SavingModule"))
local CharacterController = require(modules.Functions.Framework:WaitForChild("CharacterController"))

local musSound = SoundService.music

local cam = workspace.CurrentCamera

local TitleMenu = nil

local MENUOPT: number = 1

local MenuCredits: boolean | number = false
local saveD: boolean = false

local inpconnection:RBXScriptConnection = nil

returnthis.inMenu = false
local function decode(str)
	if str then
		return Vector3.new(
			tonumber(string.sub(str, 1, 3)),
			tonumber(string.sub(str, 4, 6)),
			tonumber(string.sub(str, 7, 9))
		) - Vector3.new(1, 1, 1) * 255
	else
		return assets.p.Position
	end
end

local function loadNpc(ID, Action)
	local npc
	for _, v in pairs(plrStatsModule.maps[2]:GetChildren()) do
		if v:FindFirstChild("save") and v.save.npc.Value == ID then
			npc = v
			break
		end
	end

	for _, v in pairs(plrStatsModule.maps[4]) do
		for _, e in pairs(v.npcs:GetChildren()) do
			if e:FindFirstChild("save") and e.save.npc.Value == ID then
				npc = e
				break
			end
		end
	end

	for _, v in pairs(plrStatsModule.maps[5]) do
		if v:FindFirstChild("npcs") then
			for _, e in pairs(v.npcs:GetChildren()) do
				if e:FindFirstChild("save") and e.save.npc.Value == ID then
					npc = e
					break
				end
			end
		end
	end

	if npc then
		SavingModule.Save(Action, npc)
	end
end

local function defload(kill: boolean?)
	plrStatsModule.LOAD = true
	mainGui.op.BackgroundTransparency = 0
	plrStatsModule.data = nil
	saveD = true
	musicModule.musicstop()
	if plrStatsModule.maps[1] then
		plrStatsModule.maps[1]:Destroy()
	end
	if plrStatsModule.maps[2] then
		plrStatsModule.maps[2]:Destroy()
	end
	if plrStatsModule.maps[3] then
		plrStatsModule.maps[3]:Destroy()
	end
	if cam:FindFirstChild("cake") then
		cam.cake:Destroy()
	end
	musicModule.music = ""
	musSound.SoundId = ""
	plrStatsModule.plrChar.b.b.ImageRectOffset = Vector2.new(0, 0)
	if plrStatsModule.room then
		plrStatsModule.room:Destroy()
	end
	if not kill then
		remotes.load:FireServer()
		repeat
			RunService.RenderStepped:Wait()
		until plrStatsModule.data
	else
		plrStatsModule.data = {}
	end

	local mp3, mp4 = {}, {}
	for _, v in pairs(assets.rooms:GetChildren()) do
		if string.sub(v.Name, 1, 4) == "room" then
			mp3[tonumber(string.sub(v.Name, 5, -1))] = v:Clone()
		end
	end
	for _, v in pairs(assets.tunn:GetChildren()) do
		if string.sub(v.Name, 1, 4) == "tunn" then
			mp4[tonumber(string.sub(v.Name, 5, -1))] = v:Clone()
		end
	end
	plrStatsModule.maps =
		{ ReplicatedStorage.push:Clone(), ReplicatedStorage.npcs:Clone(), ReplicatedStorage.RE:Clone(), mp3, mp4 }
	plrStatsModule.maps[1].Parent, plrStatsModule.maps[2].Parent, plrStatsModule.maps[3].Parent = cam, cam, cam
	saveD = false
	plrStatsModule.plrItems = not plrStatsModule.data[2] and string.rep("0", 60) or plrStatsModule.data[2]
	--items='21051027133201000600'
	CharacterController.setupChar()

	plrStatsModule.data[4] = not plrStatsModule.data[4] and "0" or plrStatsModule.data[4]
	SavingModule.npcsave = plrStatsModule.data[6] or {}
	for i, v in pairs(SavingModule.npcsave) do
		loadNpc(i, v)
	end
	if plrStatsModule.data[1] then
		if #plrStatsModule.data[1] == 9 then
			plrStatsModule.plrChar.CFrame = CFrame.new(decode(plrStatsModule.data[1]))
		else
			for _, v in pairs(plrStatsModule.maps[2]:GetChildren()) do
				if v:FindFirstChild("tag") and v.tag.Value == tonumber(plrStatsModule.data[1]) then
					plrStatsModule.plrChar.CFrame = v.CFrame - Vector3.new(2)
					break
				end
			end
		end
	else
		plrStatsModule.plrChar.CFrame = workspace.map.spawn.CFrame
	end
	--attack,speed,skittles,level,exp
	plrStatsModule.stats = {
		["cool"] = not plrStatsModule.data[5] and 100 or tonumber(plrStatsModule.data[5]),
		["attack"] = tonumber(plrStatsModule.data[7]) or 10,
		["speed"] = tonumber(plrStatsModule.data[8]) or 10,
		["skittles"] = tonumber(plrStatsModule.data[9]) or 0,
		["level"] = tonumber(plrStatsModule.data[10]) or 1,
		["exp"] = tonumber(plrStatsModule.data[11]) or 0,
		["maxcool"] = tonumber(plrStatsModule.data[12]) or 100,
	}
	plrStatsModule.stats["maxcool"] = tonumber(plrStatsModule.data[12]) or 100
    local lazyfix: {any} = { false, "" }
    plrStatsModule.broat = lazyfix
	plrStatsModule.plrChar.p.Position = plrStatsModule.plrChar.Position
    remotes.Framework.setCamPos:Fire(plrStatsModule.plrChar.Position)
	coroutine.wrap(function()
		task.wait(1)
		if plrStatsModule.LOAD then
			plrStatsModule.LOAD = false
		end
		mainGui.op.BackgroundTransparency = 1
		Transitions.CircleTransition(1)
	end)()
end

function returnthis.InitTitleMenu()
	MENUOPT = 1
    returnthis.inMenu = true

	TitleMenu = assets.MainMenu:Clone()
	TitleMenu.Parent = cam
	LightingModule:update(assets.lighting.Title, TweenInfo.new(0))
	musicModule.musicplay("Title")

	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = TitleMenu.campos.CFrame
	cam.Focus = cam.CFrame
	cam.FieldOfView = 45

	mainGui.uncool.Visible = false
	mainGui.op.BackgroundTransparency = 1
	Transitions.CircleTransition(1)
	plrStatsModule.LOAD = false

    inpconnection = remotes.Framework.inpBegan.Event:Connect(function()
        if plrStatsModule.ButtonsTouching.Up == true then
            if TitleMenu and TitleMenu:FindFirstChild("g") and MenuCredits == false then
                MENUOPT = MENUOPT ~= 1 and MENUOPT - 1 or 1
                TweenService:Create(
                    TitleMenu.you,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    { CFrame = CFrame.new(MENUOPT * 1.4 - 2.8, 103.025, 4) }
                ):Play()
                task.wait(0.5)
            end
        elseif plrStatsModule.ButtonsTouching.Down == true then
            if TitleMenu and TitleMenu:FindFirstChild("g") and MenuCredits == false then
                MENUOPT = MENUOPT ~= 3 and MENUOPT + 1 or 3
                TweenService:Create(
                    TitleMenu.you,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    { CFrame = CFrame.new(MENUOPT * 1.4 - 2.8, 103.025, 4) }
                ):Play()
                task.wait(0.5)
            end
        elseif plrStatsModule.ButtonsTouching.X == true then
            if TitleMenu and TitleMenu:FindFirstChild("g") then
                if MENUOPT ~= 3 and MenuCredits == false then
                    musicModule.musicstop()
                    TitleMenu.puck.Transparency = 0
                    TitleMenu.puck.Sound:Play()
                    TitleMenu.g:Destroy()
                    TitleMenu.puck.CFrame = TitleMenu.you.CFrame + Vector3.new(0, 0, -0.65)
                    TweenService:Create(
                        TitleMenu.puck,
                        TweenInfo.new(1, Enum.EasingStyle.Linear),
                        { CFrame = CFrame.new(-2.8 + MENUOPT * 1.4, 103.025, -4.655) }
                    ):Play()
                    task.wait(0.7)
                    Transitions.CircleTransition()
                    TitleMenu:Destroy()
                    TitleMenu = nil
                    inpconnection:Disconnect()
                    returnthis.inMenu = false
                    return
                elseif MENUOPT == 3 and MenuCredits == false then
                    MenuCredits = 1 -- nothing lol
                    TitleMenu.puck.Transparency = 0
                    musicModule.musicstop()
                    musicModule.musicplay("MenuCredits")
                    mainGui.credits.Visible = true
                    mainGui.credits.BackgroundTransparency = 1
                    mainGui.credits.group.GroupTransparency = 1
                    mainGui.credits.group.GroupColor3 = Color3.new(0, 0, 0)
                    TitleMenu.puck.Sound:Play()
                    TitleMenu.puck.CFrame = TitleMenu.you.CFrame + Vector3.new(0, 0, -0.65)
    
                    TweenService:Create(
                        mainGui.credits.group,
                        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        { GroupColor3 = Color3.new(1, 1, 1), GroupTransparency = 0 }
                    ):Play()
                    TweenService:Create(
                        mainGui.credits,
                        TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        { BackgroundTransparency = 0 }
                    ):Play()
                    TweenService:Create(
                        TitleMenu.puck,
                        TweenInfo.new(1, Enum.EasingStyle.Linear),
                        { CFrame = CFrame.new(-2.8 + MENUOPT * 1.4, 103.025, -4.655) }
                    ):Play()
    
                    task.wait(1)
                    TitleMenu.puck.Transparency = 1
                    MenuCredits = true
                    return
                elseif MENUOPT == 3 and MenuCredits == true then
                    MenuCredits = false
                    musicModule.musicstop()
                    musicModule.musicplay("Title")
                    mainGui.credits.Visible = false
                    return
                end
            end
        end
    end)

	while TitleMenu do
		mainGui.touch.buttons.bt1.ImageRectOffset =
			Vector2.new(plrStatsModule.ButtonsTouching.Z == true and 125 or 0, 0)
		mainGui.touch.buttons.bt2.ImageRectOffset =
			Vector2.new(plrStatsModule.ButtonsTouching.X == true and 125 or 0, 0)
		mainGui.touch.bt3.ImageRectOffset = Vector2.new(plrStatsModule.ButtonsTouching.C == true and 125 or 0, 0)
		RunService.RenderStepped:Wait()
	end

	if MENUOPT == 2 then
		defload(true)
	elseif MENUOPT == 1 then
		defload()
	end

	coroutine.wrap(function()
		task.wait(1)
		plrStatsModule.LOAD = false
		mainGui.op.BackgroundTransparency = 1
		musSound:Play()
		Transitions.CircleTransition(1)
	end)()
end

return returnthis
