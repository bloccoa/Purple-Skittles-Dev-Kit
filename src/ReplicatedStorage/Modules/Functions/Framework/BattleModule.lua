--!nocheck
--// BATTLEMODULE
--// does the battles
--// this is complete gibberish
local returnthis = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local cam: Camera = workspace.CurrentCamera

local SFX = SoundService.sfx
local MUS = SoundService.mus
local musSound = SoundService.music

local modules = ReplicatedStorage:WaitForChild("Modules")
local assets = ReplicatedStorage:WaitForChild("Assets")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local musicModule = require(modules:WaitForChild("Functions").Framework:WaitForChild("MusicModule"))
local plrStatsModule = require(modules.Dictionaries:WaitForChild("PlrStats"))
local Transitions = require(modules.Functions.Framework:WaitForChild("Transitions"))
local ingameMenu = require(modules.Functions.Framework:WaitForChild("IngameMenu"))

local wai: boolean
local sending: boolean

local plrLocalName: string = plrStatsModule.plrLocalName
local originalMus: string? = ""

local gdir: Vector3 = Vector3.new()

local BTT = nil
local BTT2 = { false, 0, CFrame.new(0, 112, 25) * CFrame.Angles(-0.5, 0, 0), 0, false }
local puckAppearances = { -- this is where you change appearances (this is the sign saying this btw)
    ["sine"] = {
        ["Material"] = Enum.Material.Neon,
        ["ParticleColor"] = ColorSequence.new(Color3.new(1, 1, 0)),
        ["Color"] = Color3.fromRGB(245, 205, 48),
    },
    ["cos"] = {
        ["Material"] = Enum.Material.Neon,
        ["ParticleColor"] = ColorSequence.new(Color3.new(1, 0, 0)),
        ["Color"] = Color3.fromRGB(196, 40, 28),
    },
    ["speedchange"] = {
        ["Material"] = Enum.Material.Neon,
        ["ParticleColor"] = ColorSequence.new(Color3.new(0.2, 0.2, 1)),
        ["Color"] = Color3.fromRGB(33, 84, 185),
    },
    ["sinecos"] = {
        ["Material"] = Enum.Material.Neon,
        ["ParticleColor"] = ColorSequence.new(Color3.new(1, 0.5, 0)),
        ["Color"] = Color3.fromRGB(170, 85, 0),
    },
    ["ghost"] = {
        ["Material"] = Enum.Material.Glass,
        ["Color"] = Color3.fromRGB(218, 218, 218),
        ["Transparency"] = 0.3,
        ["Shadows"] = false,
    },
}
local puckEffects = {
    ["sine"] = function(sine)
        return Vector3.new(0, 0, math.sin(sine * 0.1) * 0.5) -- slidy
    end,
    ["cos"] = function(sine)
        return Vector3.new(math.sin((sine * 1.25) / 5) / 20, 0, 0) -- wavy
    end,
    ["sinecos"] = function(sine)
        return Vector3.new(math.sin((sine * 1.25) / 5) / 20, 0, 0) + Vector3.new(0, 0, math.sin(sine * 0.1) * 0.5)
    end,
}

--//FUNCTIONS
local function expt(BT, tx, redo)
    local txt2 = tx:FindFirstChild("pr") or tx:FindFirstChild("pr2")
    if not redo then
        local ex = math.floor(BT.dmg.Value * 0.1)
            + math.floor(BT.hp.Value * 0.05)
            + math.floor(BT.num.Value * 0.075)
            + math.floor(BT.speed.Value * 0.125)
        - math.floor(BT.delay.Value * 0.075)
            + (BT:FindFirstChild("expbonus") and BT.expbonus.Value or 0)
            + (BT:FindFirstChild("expbonus") and BT.expbonus.Value or 0)
        tx.Value = plrLocalName .. " got " .. ex .. " Exp and " .. math.floor(ex / 5) .. " skittles."
        plrStatsModule.stats["exp"] = plrStatsModule.stats["exp"] + ex
        plrStatsModule.stats["skittles"] = plrStatsModule.stats["skittles"] + math.floor(ex / 5)
    else
        tx.Value = "SKIP"
    end
    local lvlxp = 45 * 1.5 ^ (plrStatsModule.stats["level"] - 1)
    txt2.Name = plrStatsModule.stats["exp"] > lvlxp and "pr" or "pr2"
    if plrStatsModule.stats["exp"] > lvlxp then
        plrStatsModule.stats["level"] += 1
        plrStatsModule.stats["attack"] += 2
        plrStatsModule.stats["speed"] += 1
        plrStatsModule.stats["maxcool"] += 10
        plrStatsModule.stats["cool"] = plrStatsModule.stats["maxcool"]
    end
    remotes.Framework.Chat:Invoke(tx, tx)
    lvlxp = 45 * 1.5 ^ (plrStatsModule.stats["level"] - 1)
    if plrStatsModule.stats["exp"] > lvlxp then
        expt(BT, tx, true)
    end
end

local function hit(dmg)
    plrStatsModule.stats["cool"] = math.max(0, plrStatsModule.stats["cool"] - dmg)
    SFX.hit:Play()
    if BTT then
        coroutine.wrap(function()
            BTT.tb.m.BrickColor = BrickColor.new(Color3.new(1, 0, 0))
            task.wait(0.4)
            BTT.tb.m.BrickColor = BrickColor.new(Color3.new(1, 1, 0))
        end)()
    end
end

local function hitme(wa, num, speed, dmg, bt)
    task.wait(wa)

    local speedchange1: number = 0

    local firstpuck: boolean = true
    local bre: boolean = false
    local tr: boolean = false

    local pucks = {}

    _G.c = true
    sending = true

    for x = 1, num do
        if bt:FindFirstChild("effect") and bt.effect.Value == "speedchange" then
            speedchange1 = speedchange1 + 1
        end

        local r

        if bt:FindFirstChild("effect") and bt.effect.Value == "egg" then
            r = BTT.tb.puckEgg:Clone()
            r.BrickColor = BrickColor.Random()
        else
            r = BTT.tb.puck:Clone()
        end

        if speedchange1 == 2 then --gotta blast
            Instance.new("BoolValue", r).Name = "FAST"
        end

        r.Parent = BTT
        table.insert(pucks, r)

        local ran = math.random(3)
        r.Sound.Pitch = ran / 3 + 1
        ran = ran == 1 and -1 or ran == 2 and 0 or 1
        BTT.opp.CFrame = CFrame.new(ran, 103.034, -4)
        r.CFrame = CFrame.new(ran, 102.875, -3.4)
        if sending then
            r.Sound:Play()
        end

        if bt:FindFirstChild("effect") and puckAppearances[bt.effect.Value] then
            local fx = bt.effect.Value
            r.Material = puckAppearances[fx]["Material"]
            r.Color = puckAppearances[fx]["Color"]
            if puckAppearances[fx]["ParticleColor"] then
                r.p.Enabled = true
                r.p.Color = puckAppearances[fx]["ParticleColor"]
            end
            if puckAppearances[fx]["Transparency"] then
                r.Transparency = puckAppearances[fx]["Transparency"]
            end
            if puckAppearances[fx]["Shadow"] then
                r.CastShadow = puckAppearances[fx]["Shadow"]
            end
        end

        if sending then --show moves
            coroutine.wrap(function()
                local y = 0
                while true do
                    local dt = RunService.RenderStepped:Wait()
                    if bre == true then
                        break
                    end
                    y = y + (dt * 60)
                    r.CFrame =
                        CFrame.new(ran, 102.875, -3.4 + y / 20 * (r:FindFirstChild("FAST") and speed * 1.5 or speed))
                end
            end)()
            task.wait(r:FindFirstChild("FAST") and wa * 2 or wa)
        end
    end

    sending = false
    bre = true
    BTT2[3] = CFrame.new(0, 107, 4) * CFrame.Angles(-1.3, 0, 0) --you reactTM cam
    BTT2[5] = true

    for _, v in pairs(pucks) do -- hide pucks
        v.CFrame = CFrame.new(v.Position.X, -9999, -9999)
    end

    task.wait(wa)

    for i, puck in pairs(pucks) do --moves to hit
        if not bt:FindFirstChild("effect") or (bt.effect.Value ~= "falalalala" and bt.effect.Value ~= "sansfunny") then
            if firstpuck then
                firstpuck = false
            else
                task.wait(puck:FindFirstChild("FAST") and wa * puck.FAST.Value or wa)
            end
        end
        coroutine.wrap(function()
            local sine: number = 0
            while true do
                local dt = RunService.RenderStepped:Wait()
                if puck.Position.Z > 3.4 then -- wait until past hit point
                    break
                end
                sine = sine + (dt * 60)

                local b = (bt:FindFirstChild("effect") and puckEffects[bt.effect.Value])
                    and puckEffects[bt.effect.Value](sine)
                    or Vector3.new()

                puck.CFrame = CFrame.new(
                    puck.Position.X,
                    102.875,
                    -2 + sine / 20 * (puck:FindFirstChild("FAST") and speed * 2 or speed)
                ) + b
                if bt:FindFirstChild("effect") and bt.effect.Value == "ghost" then
                    puck.Transparency = puckAppearances["ghost"]["Transparency"] * (sine / 12)
                end
            end

            if math.floor(BTT.you.Position.X + 0.5) == math.floor(puck.Position.X + 0.5) then --if ur pos = puck pos
                puck.Sound:Play()
                coroutine.wrap(function()
                    TweenService:Create(
                        puck,
                        TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        { Transparency = 1, CFrame = puck.CFrame - Vector3.new(0, 0, 0.25) }
                    ):Play()
                    task.wait(0.15)
                    puck:Destroy()
                end)()
            else
                hit(dmg or 5)
                coroutine.wrap(function()
                    TweenService:Create(
                        puck,
                        TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        { Transparency = 1, CFrame = puck.CFrame + Vector3.new(0, 0, 1) }
                    ):Play()
                    task.wait(0.15)
                    puck:Destroy()
                end)()
            end

            if i == #pucks then
                tr = true
            end
        end)()
        if bt:FindFirstChild("effect") and (bt.effect.Value == "falalalala" or bt.effect.Value == "sansfunny") then
            task.wait(puck:FindFirstChild("FAST") and wa * puck.FAST.Value or wa)
        end
    end
    repeat
        RunService.RenderStepped:Wait()
    until tr
    BTT.opp.CFrame = CFrame.new(0, 103.034, -4)
    BTT2[5] = false
    repeat
        RunService.RenderStepped:Wait()
    until tr
    BTT.opp.CFrame = CFrame.new(0, 103.034, -4)
    BTT2[5] = false
end

local function attack(sp)
    _G.c = true
    if sp then
        local r = BTT.tb.puck:Clone()
        r.Parent = BTT
        r.CFrame = CFrame.new(0, 102.875, 3)
        local moveFactorThing: number = 1
        wai = true
        BTT.you.CFrame = CFrame.new(0, 103.034, 4)
        repeat
            RunService.RenderStepped:Wait()
        until not wai
        for x = 1, 5 do
            BTT.you.CFrame += Vector3.new(0, 0, -x / 25)
        end
        r.Sound:Play()
        local miss = false
        BTT2[5] = 1

        local vx, vy = math.random(-50, 50) / 1000, -0.1

        local stop: boolean = false
        RunService:BindToRenderStep("movePucks",Enum.RenderPriority.Input.Value,function(dt)  
            local finalCFrame : CFrame = r.CFrame + Vector3.new(vx * (dt * 60), 0, vy * (dt * 60))
            if math.abs(finalCFrame.Position.X) > 1.8 then
                vx = -vx
                finalCFrame += Vector3.new(vx, 0, 0)
                r.Sound:Play()
            end --bounce on wall
            if finalCFrame.Position.Z > 3.4 then --you
                if math.abs(BTT.you.Position.X - finalCFrame.Position.X) < 1 then
                    vy = -vy - 0.01
                    r.Sound:Play()
                    vx = (finalCFrame.Position.X - BTT.you.Position.X) * 0.3
                    finalCFrame = CFrame.new(finalCFrame.Position.X, finalCFrame.Position.Y, 3.4)
                elseif finalCFrame.Position.Z > 4.12 then
                    miss = true
                    stop = true
                    return
                end
            elseif finalCFrame.Position.Z < -3.4 then --opp
                if math.abs(BTT.opp.Position.X - finalCFrame.Position.X) < 1 then
                    vy = -vy + 0.01
                    finalCFrame += Vector3.new(0, 0, vy)
                    vx = (finalCFrame.Position.X - BTT.opp.Position.X) * 0.3
                    r.Sound:Play()
                else
                    miss = false
                    stop = true
                    return
                end
            end
            vx *= 0.98
            r.CFrame = finalCFrame --* CFrame.new(dt * 60, dt * 60, dt * 60) -- dude
            BTT.opp.CFrame = BTT.opp.CFrame:Lerp(
                CFrame.new(r.Position.X + (math.sin(tick()) + math.random(-100, 100) * 0.01) * 0.01, 103.034, -4),
                1 - 0.021 ^ dt
            )
        end)
        repeat RunService.RenderStepped:Wait() until miss or stop -- dont judge me im lazy
        RunService:UnbindFromRenderStep("movePucks")

        if miss then
            plrStatsModule.stats["cool"] = math.max(0, plrStatsModule.stats["cool"] - plrStatsModule.stats["attack"])
            SFX.hit:Play()
        else
            BTT.npc.cool.Value = math.max(0, BTT.npc.cool.Value - plrStatsModule.stats["attack"] * 2)
            SFX.hit:Play()
        end
        _G.c = false
        BTT2[5] = false
        r:Destroy()
    else
        local dr: number = math.random(2) == 1 and 1 or -1
        local miss: boolean | number = false
        local speed = 0.0375
        local r = BTT.tb.puck:Clone()
        r.Parent = BTT

        BTT.you.CFrame = CFrame.new(dr, 103.034, 4)
        wai = true
        local sine: number = 0
        while true do
            local dt = RunService.RenderStepped:Wait()
            sine += dt * 60
            if not wai then
                break
            end
            r.CFrame = CFrame.new((sine * speed) * dr - dr, 102.875, 3)
            if math.abs(r.CFrame.X) > 1.75 then
                miss = 1
                break
            end
        end

        if miss == 0 or not miss then
            local newSine: number = 0
            while true do
                local dt = RunService.RenderStepped:Wait()
                sine += dt * 90
                newSine += dt * 60
                BTT.you.CFrame += Vector3.new(0, 0, -newSine / 60)
                r.CFrame = CFrame.new((sine * speed) * dr - dr, 102.875, 3)
                if newSine >= 5 then
                    break
                end
            end
        end
        miss = math.abs(r.Position.X - BTT.you.Position.X) > 0.5 and 0 or miss
        if miss then
            SFX.toss:Play()
        else
            r.Sound:Play()
            local bx = (r.Position.X - 1 * dr)
            while true do
                local dt = RunService.RenderStepped:Wait()
                if r.Position.Z < -4 then
                    break
                end
                r.CFrame = r.CFrame + Vector3.new(bx * (dt * 60), 0, -(dt * 60) * 0.5)
                if math.abs(r.Position.X) > 2 then
                    r.Sound.Pitch = 0.8
                    r.Sound:Play()
                    bx = -bx
                end
            end
            BTT.npc.cool.Value = math.max(0, BTT.npc.cool.Value - plrStatsModule.stats["attack"])
            SFX.hit:Play()
            r:Destroy()
            r = nil
        end
        task.wait(0.4)
        if r then
            task.wait(0.6)
            r:Destroy()
        end
    end
end

local function killene(npc)
    local ran = math.random(3)
    if ran == 1 then
        for x = 1, 30 do
            npc.CFrame = CFrame.new(math.fmod(x, 2) == 1 and -x / 20 or x / 20, 103.5 - x / 30, -8)
            RunService.RenderStepped:Wait()
            npc.b.b.ImageTransparency = x / 30
        end
    elseif ran == 2 then
        local b = npc.b.b
        local num = 50 - math.random(3) * 10
        for x = 1, num do
            local r = b:Clone()
            r.Parent = npc.b
            r.Size = UDim2.new(1, 0, 1 / num, 0)
            r.Position = UDim2.new(0, 0, x / num - 1 / num, 0)
            r.ImageRectOffset = Vector2.new(0, x / num * 150 - 150 / num)
            r.ImageRectSize = Vector2.new(150, 150 / num)
        end
        b:Destroy()
        for x = 1, 30 do
            for i, v in pairs(npc.b:GetChildren()) do
                v.Position = UDim2.new(
                    x / 30 * (math.fmod(i, 2) == 1 and 1 or -1) * v.Position.Y.Scale,
                    0,
                    v.Position.Y.Scale,
                    0
                )
                v.ImageTransparency = x / 30
            end
            npc.CFrame = CFrame.new(0, 103.5 - x / 30, -8)
            RunService.RenderStepped:Wait()
        end
    elseif ran == 3 then
        local b = npc.b.b
        local num = 50 - math.random(3) * 10
        for x = 1, num do
            local r = b:Clone()
            r.Parent = npc.b
            r.Size = UDim2.new(1 / num, 0, 1, 0)
            r.Position = UDim2.new(x / num - 1 / num, 0, 0, 0)
            r.ImageRectOffset = Vector2.new(x / num * 150 - 150 / num, 0)
            r.ImageRectSize = Vector2.new(150 / num, 150)
        end
        b:Destroy()
        for x = 1, 30 do
            for i, v in pairs(npc.b:GetChildren()) do
                v.Position = UDim2.new(v.Position.X.Scale, 0, x / 30 * (math.fmod(i, 2) == 1 and 1 or -1), 0)
                v.ImageTransparency = x / 30
            end
            npc.CFrame = CFrame.new(0, 103.5 - x / 30, -8)
            RunService.RenderStepped:Wait()
        end
    end
end

function returnthis.BATTLE(ex: boolean?, img: any?, bat: any?, mo: BasePart?, re: boolean?, maps: any?, mus: string?)
    if not _G.c then
        _G.c = true --ratt
        if not ex and mo and img and bat and maps then -- typechecking makes me do this horrible thing
            plrStatsModule.battling = true
            originalMus = musSound.SoundId
            musicModule.musicstop()
            if mus then
                if MUS.battle:FindFirstChild(mus) then
                    musicModule.musicplay(mus)
                else
                    musSound.SoundId = "rbxassetid://" .. mus
                    musSound:Play()
                end
                if bat and bat.BT:FindFirstChild("effect") and bat.BT.effect.Value == "final" then
                    coroutine.wrap(function()
                        task.wait(28.081)
                        musicModule.musicstop()
                        musSound.SoundId = "rbxassetid://11159119716"
                        musSound:Play()
                    end)()
                end
            end
            Transitions.PixelTransition(true)
            local inpconnection = remotes.Framework.inpBegan.Event:Connect(
                function() -- SO INNEFICCICNCIEINTN AAAH90H9H9H999 KIULL
                    if plrStatsModule.ButtonsTouching.X == true then
                        if wai then
                            wai = false
                        end
                        if sending then
                            sending = false
                        end
                    elseif plrStatsModule.ButtonsTouching.Z == true then
                        if wai then
                            wai = false
                        end
                    end
                end
            )
            local bt = bat.BT
            BTT2[3] = CFrame.new(0, 112, 24) * CFrame.Angles(-0.5, 0, 0) --choose
            cam.CFrame = BTT2[3]
            BTT = assets.battle:Clone()
            BTT:PivotTo(CFrame.new(0, 100, 1.5))
            BTT.Parent = cam
            if re then
                BTT.npc.b.b.Image = "http://www.roblox.com/asset/?id=" .. img
                BTT.npc.b.b.ImageRectSize = Vector2.new(100, 100)
            else
                BTT.npc.b.b.Image = img.Image
                BTT.npc.b.b.ImageColor3 = img.ImageColor3
            end
            BTT.npc.cool.Value = bt.hp.Value
            BTT.npc.mhp.Value = bt.hp.Value
            BTT.floor.Material, BTT.floor.BrickColor = mo.Material, mo.BrickColor
            for _, v in pairs(BTT:GetChildren()) do
                if v.Name == "wall" then
                    v.Material, v.BrickColor =
                        mo.Material, BrickColor.new(mo.BrickColor.r * 1.2, mo.BrickColor.g * 1.2, mo.BrickColor.b * 1.2)
                end
            end
            plrStatsModule.plrChar.CFrame = CFrame.new(0, 103, 14)
            BTT2[1] = true
            BTT2[2] = 0
            plrStatsModule.plrChar.p.Position = plrStatsModule.plrChar.Position
            cam.FieldOfView = 70
            coroutine.wrap(function()
                while BTT ~= nil do
                    local dt = RunService.RenderStepped:Wait()
                    cam.CFrame = cam.CFrame:Lerp(BTT2[3], 1 - 0.0000005 ^ dt)
                    cam.Focus = cam.CFrame
                    local r = nil
                    if plrStatsModule.plrChar.Position.X < -1 then
                        if plrStatsModule.plrChar.Position.Z < 14 then
                            BTT2[2], r = 1, true
                        else
                            BTT2[2], r = 4, true
                        end
                    elseif plrStatsModule.plrChar.Position.X > 1 then
                        if plrStatsModule.plrChar.Position.Z < 14 then
                            BTT2[2], r = 2, true
                        else
                            BTT2[2], r = 3, true
                        end
                    end
                    if not r then
                        BTT2[2] = 0
                    end
                    if BTT2[5] then
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
                            gdir =
                                CFrame.new(Vector3.new(), Vector3.new(wasd[4] - wasd[2], 0, wasd[3] - wasd[1])).LookVector
                        else
                            gdir = Vector3.new()
                        end
                        BTT2[4] = gdir.X
                        if BTT2[5] ~= 1 then
                            BTT.you.CFrame = CFrame.new(gdir.X, 103.034, 4)
                        else
                            BTT.you.CFrame = BTT.you.CFrame:Lerp(CFrame.new(gdir.X, 103.034, 4), 1 - 0.000005 ^ dt)
                        end
                    end
                    if BTT then
                        BTT.tb.m.g.b.hp.Size =
                            UDim2.new(plrStatsModule.stats["cool"] / plrStatsModule.stats["maxcool"], 0, 1, 0)
                        BTT.tb.m.g.b.hp.Position =
                            UDim2.new(0.5 - plrStatsModule.stats["cool"] / (plrStatsModule.stats["maxcool"] * 2),0,0,0)
                        BTT.tb.m.g.b.hp.Text = plrStatsModule.stats["cool"]
                        BTT.tb.y.g.b.hp.Size = UDim2.new(BTT.npc.cool.Value / BTT.npc.mhp.Value, 0, 1, 0)
                        BTT.tb.y.g.b.hp.Position = UDim2.new(0.5 - BTT.npc.cool.Value / (BTT.npc.mhp.Value * 2),0,0,0)
                        BTT.tb.y.g.b.hp.Text = BTT.npc.cool.Value

                        BTT.buttons.fite.g.g.ImageColor3 = BTT2[2] == 1 and Color3.new(0, 0, 0)
                            or Color3.fromRGB(255, 80, 80)
                        BTT.buttons.item.g.g.ImageColor3 = BTT2[2] == 2 and Color3.new(0, 0, 0)
                            or Color3.fromRGB(80, 255, 80)
                        BTT.buttons.run.g.g.ImageColor3 = BTT2[2] == 3 and Color3.new(0, 0, 0)
                            or Color3.fromRGB(168, 80, 255)
                        BTT.buttons.swap.g.g.ImageColor3 = BTT2[2] == 4 and Color3.new(0, 0, 0)
                            or Color3.fromRGB(255, 255, 80)
                    end
                end
            end)()
            Transitions.PixelTransition()
            local win: boolean = false

            while BTT2[2] ~= 3 do
                task.wait()
                _G.c = false
                wai = true
                while true do
                    RunService.RenderStepped:Wait()
                    if not wai and BTT2[2] > 0 then
                        break
                    elseif not wai then
                        wai = true
                    end
                end
                if BTT2[2] == 1 then --ATTACK
                    BTT2[3] = CFrame.new(0, 105, 6) * CFrame.Angles(-0.5, 0, 0) --you attack
                    attack()
                elseif BTT2[2] == 4 then --SPECIAL
                    BTT2[3] = CFrame.new(0, 105, 6) * CFrame.Angles(-0.5, 0, 0) --you attack
                    attack(true)
                    if plrStatsModule.stats["cool"] <= 0 then
                        _G.c = false
                        break
                    end
                elseif BTT2[2] == 2 then --ITEM
                    ingameMenu.menu(false, true)
                    repeat
                        RunService.RenderStepped:Wait()
                    until ingameMenu.ITEM == false
                end
                if BTT.npc.cool.Value <= 0 then
                    musicModule.musicstop()
                    musicModule.musicplay("BattleWon")
                    killene(BTT.npc)
                    _G.c = false
                    expt(bt, BTT["floor"].tx.pr.pr)
                    musSound.Looped = true --notgoodplschange
                    win = true
                    _G.c = false
                    break
                end
                BTT2[3] = CFrame.new(0, 107, -4) * CFrame.Angles(-1.3, 0, 0) --opp sending
                _G.c = true
                hitme(bt.delay.Value / 100, bt.num.Value, bt.speed.Value / 100, bt.dmg.Value, bt)
                _G.c = false
                if plrStatsModule.stats["cool"] <= 0 then
                    _G.c = false
                    break
                end
                BTT2[3] = CFrame.new(0, 112, 24) * CFrame.Angles(-0.5, 0, 0) --choose
            end
            returnthis.BATTLE(true)

            if re and win then
                local r = ReplicatedStorage.RE[bat.Name]:Clone()
                bat:Destroy()
                coroutine.wrap(function()
                    repeat
                        RunService.RenderStepped:Wait()
                    until (r.Position - plrStatsModule.plrChar.Position).Magnitude > 200
                    r.Parent = maps[3]
                end)()
            elseif re then
                bat.move.Value, bat.Anchored = 0, true
            end

            local ran: boolean = false
            if BTT2[2] == 3 then
                ran = true
            end
            inpconnection:Disconnect()
            return win, ran
        else
            Transitions.PixelTransition(true)
            musicModule.musicstop()
            musSound.SoundId = originalMus
            musSound:Play()
            originalMus = nil
            BTT:Destroy()
            BTT = nil
            plrStatsModule.battling = false
            _G.c = false
        end
    end
end

remotes.Framework.battle.OnInvoke = function(...)
    return returnthis.BATTLE(...)
end

return returnthis
