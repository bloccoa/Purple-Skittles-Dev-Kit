--!nocheck
--//CUSTOM EVENTS
--// Contains custom events from texts
--// intially called 4u2edit
--// was going to make this nonstrict but this is supposed to be edited
--// so i'm gonna make it easy for People by disabling typechecking here

local CustomEvents = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local plrGui = plr.PlayerGui
local mainGui = plrGui.Main

local modules = ReplicatedStorage:WaitForChild("Modules")
local assets = ReplicatedStorage:WaitForChild("Assets")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local LightingModule = require(modules:WaitForChild("Functions"):WaitForChild("Framework"):WaitForChild("Lighting"))
local plrStatsModule = require(modules.Dictionaries:WaitForChild("PlrStats"))
local itemsModule = require(modules.Dictionaries:WaitForChild("Items"))
local skinsModule = require(modules.Dictionaries:WaitForChild("Skins"))
local musicModule = require(modules:WaitForChild("Functions").Framework:WaitForChild("MusicModule"))

local cam = workspace.CurrentCamera

local SFX = SoundService.sfx
local MUS = SoundService.mus
local musSound = SoundService.music

local puzzle: number = 1

local buismopuzzle: boolean = false

local assetid: string = "http://www.roblox.com/asset/?id="

local devs = {
    138306643, -- bloccopng
    107838331, -- forkdude
    90502184, -- haydoblad
    329600084, -- riley
    557308771, -- CHUM
}

--//LOADING
ContentProvider:PreloadAsync({ "rbxassetid://513353109", "rbxassetid://521491706" }) --preload spoop imgs

--//FUNCTIONS
local function skin(x)
    return skinsModule.find(x)
end

local function itemget(num)
    if num == tonumber(num) then
        num = num < 10 and "00" .. tostring(num) or num < 100 and "0" .. tostring(num) or tostring(num)
    end
    return itemsModule.itemget(num)
end

local function lookforitem(num, ip, re)
    if num == tonumber(num) then
        num = num < 10 and "00" .. tostring(num) or num < 100 and "0" .. tostring(num) or tostring(num)
    end
    for i, v in pairs(ip) do
        if v == num then
            return i
        end
    end
end

--//THE MAIN THING
function CustomEvents.customEvent(tx, o, DATA)
    local TEXT = DATA[1]
    local cool = DATA[2]
    local mhp = DATA[3]
    --cch=x, give item
    --plrStatsModule.plrChar.Anchored,_G.c=true,true
    if tx:FindFirstChild("INT") then
        _G.c = false
        TEXT.Visible = false

        if tx.INT.Value == 0 then --cactus move
            _G.set("skittles", _G.get("skittles") - 10)
            o.tx:Destroy()
            for x = 1, 60 do
                o.CFrame = o.CFrame + Vector3.new(0, -0.1, 0)
                wait()
            end
            for x = 1, 10 do
                o["Prickboy the Snakeman"].CFrame = o["Prickboy the Snakeman"].CFrame + Vector3.new(0, 0.2)
                wait()
            end
            o["Prickboy the Snakeman"].Parent = o.Parent
        elseif tx.INT.Value == 1 then --check if can give item
            local idk = false
            if _G.giveItem(tx.INT.itemV.Value, plrStatsModule.plrItems, true) then --check if items full
                idk, plrStatsModule.plrItems = _G.giveItem(tx.INT.itemV.Value, plrStatsModule.plrItems)
                remotes.Framework.Chat:Invoke(tx.INT.po, o)
            else
                remotes.Framework.Chat:Invoke(tx.INT.po2, o)
            end
        elseif tx.INT.Value == 2 then --cool doctor
            if cool >= mhp then
                remotes.Framework.Chat:Invoke(tx.tx2, o)
            else
                _G.c = true
                TEXT.cur.Visible = false
                cool = _G.coolme()
                SFX.heal:Play()
                task.wait(1.5)
                _G.c = false
                remotes.Framework.Chat:Invoke(tx.INT.tx, o)
            end
        elseif tx.INT.Value == 3 then --remove, no anim
            o:Destroy()
            SFX.poot:Play()
        elseif tx.INT.Value == 4 then --move up
            o.tx:Destroy()
            for x = 1, 40 do
                o.CFrame = o.CFrame + Vector3.new(0, 0.05)
                RunService.RenderStepped:Wait()
            end
        elseif tx.INT.Value == 5 then --shut up npc
            o.tx:Destroy()
        elseif tx.INT.Value == 6 then --remove, anim
            o.tx:Destroy()
            if o:FindFirstChild("b") and o.b:FindFirstChild("b") then
                o.CanCollide = false
                if string.find(o.Name, "Fridge") then
                    o.b.b.ImageRectOffset = Vector2.new(100, o.b.b.ImageRectOffset.Y)
                else
                    TweenService:Create(
                        o.b.b,
                        TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        { ImageTransparency = 1 }
                    ):Play()
                    task.wait(0.75)
                    o:Destroy()
                end
            end
        elseif tx.INT.Value == 7 then --HYPERSNAKE
            if cam.npcs:FindFirstChild("Chill Snakeman") then
                cam.npcs["Chill Snakeman"].CFrame = cam.npcs["Chill Snakeman"].CFrame + Vector3.new(0, 4)
            end
            o.tx:Destroy()
            SFX.rocket:Play()
            local HYPERSNAKEFLYSPEED = 0.1
            for x = 1, 160 do
                o.CFrame = o.CFrame + Vector3.new(0, HYPERSNAKEFLYSPEED, 0)
                if o:FindFirstChild("Particle") then
                    o.Particle.CFrame = o.Particle.CFrame + Vector3.new(0, HYPERSNAKEFLYSPEED, 0)
                end
                SFX.rocket.Volume = SFX.rocket.Volume - 0.005
                RunService.RenderStepped:Wait()
                HYPERSNAKEFLYSPEED = HYPERSNAKEFLYSPEED + 0.01
            end
            SFX.rocket:Stop()
            o:Destroy()
            SFX.explosion.Volume = 0.4
            SFX.explosion:Play()
        elseif tx.INT.Value == 9 then --soccersnake control
            o.Anchored = false
            o.tx:Destroy()
        elseif tx.INT.Value == 13 then --create item stufffff
            local i = assets.Framework.po:Clone()
            i.Parent = tx
            i.Value = "Take the " .. itemget(tx.INT.itemV.Value)[1] .. "?"
            i.ans1.INT.po.Value = "You took the " .. itemget(tx.INT.itemV.Value)[1] .. "."
            tx.INT.itemV.Parent = i.ans1.INT
            if tx.INT:FindFirstChild("topo") then
                for _, v in pairs(tx.INT.topo:GetChildren()) do
                    v.Parent = i.ans1.INT.po
                end
            end
            if tx.INT:FindFirstChild("toco") then
                for _, v in pairs(tx.INT.toco:GetChildren()) do
                    v:Clone().Parent = i.ans1.INT.po2
                    v.Parent = i.ans2
                end
            end
            tx.INT:Destroy()
            remotes.Framework.Chat:Invoke(tx.po, o)
        elseif tx.INT.Value == 14 then --check for item, use item
            if lookforitem(tx.INT.ITEM.Value, plrStatsModule.plrItems) then
                plrStatsModule.plrItems[lookforitem(tx.INT.ITEM.Value, plrStatsModule.plrItems)] = "000"
                remotes.Framework.Chat:Invoke(tx.INT.tx, o)
                return plrStatsModule.plrItems
            else
                remotes.Framework.Chat:Invoke(tx.INT.tx2, o)
            end
        elseif tx.INT.Value == 15 then --check for item, dont use item
            if lookforitem(tx.INT.ITEM.Value, plrStatsModule.plrItems) then
                if tx.INT:FindFirstChild("tx") then
                    remotes.Framework.Chat:Invoke(tx.INT.tx, o)
                elseif tx.INT:FindFirstChild("po") then
                    remotes.Framework.Chat:Invoke(tx.INT.po, o)
                end
            else
                if tx.INT:FindFirstChild("tx2") then
                    remotes.Framework.Chat:Invoke(tx.INT.tx2, o)
                elseif tx.INT:FindFirstChild("po2") then
                    remotes.Framework.Chat:Invoke(tx.INT.po2, o)
                end
            end
        elseif tx.INT.Value == 16 then --check for two items, use items
            if
                lookforitem(tx.INT.ITEM.Value, plrStatsModule.plrItems)
                and lookforitem(tx.INT.ITEM2.Value, plrStatsModule.plrItems)
            then
                plrStatsModule.plrItems[lookforitem(tx.INT.ITEM.Value, plrStatsModule.plrItems)] = "000"
                plrStatsModule.plrItems[lookforitem(tx.INT.ITEM2.Value, plrStatsModule.plrItems)] = "000"
                remotes.Framework.Chat:Invoke(tx.INT.tx, o)
                return plrStatsModule.plrItems
            else
                remotes.Framework.Chat:Invoke(tx.INT.tx2, o)
            end
        elseif tx.INT.Value == 19 then --move left
            for x = 1, 20 do
                o.CFrame = o.CFrame + Vector3.new(-0.101, 0)
                wait()
            end
        elseif tx.INT.Value == 20 then --npc cant talk
            o.tx:Destroy()
        elseif tx.INT.Value == 21 then --save
            _G.c = true
            _G.saveme(o.tag.Value)
            _G.c = false
            SFX.save:Play()
            remotes.Framework.Chat:Invoke(tx.INT.tx, o)
        elseif tx.INT.Value == 22 then --move left for cornerwedge
            o.tx:Destroy()
            for x = 1, 20 do
                o.CornerWedgePartHitbox.CFrame = o.CornerWedgePartHitbox.CFrame + Vector3.new(-0.1, 0)
                task.wait()
            end
            o.CanCollide = false
        elseif tx.INT.Value == 24 then --makes the player task.wait 2.3 seconds
            _G.c = true
            TEXT.cur.Visible = false
            task.wait(2.3)
            _G.c = false
            remotes.Framework.Chat:Invoke(tx.INT.tx, o)
        elseif tx.INT.Value == 31 then
            SFX.poot:Play()
            o:Destroy()
            plrStatsModule.plrItems[lookforitem(13, plrStatsModule.plrItems)] = "000" --get rid of explosives
            return plrStatsModule.plrItems
        elseif tx.INT.Value == 33 then --wisdom stand guy
            _G.c = false
            remotes.Framework.Chat:Invoke(o.tx.ans1, o)
        elseif tx.INT.Value == 34 then --check for skittles
            _G.c = false
            if _G.get("skittles") >= tx.INT.amount.Value then
                remotes.Framework.Chat:Invoke(tx.INT.tx, o)
            else
                remotes.Framework.Chat:Invoke(tx.INT.tx2, o)
            end
        elseif tx.INT.Value == 36 then --deduct skittles
            _G.set("skittles", _G.get("skittles") - tx.INT.amount.Value)
        end
    end
    --plrStatsModule.plrChar.Anchored,_G.c=false,false
    return nil, cool
end

return CustomEvents
