--!strict
local CharacterController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local modules = ReplicatedStorage.Modules
local remotes = ReplicatedStorage.Remotes
local assets = ReplicatedStorage.Assets

local Transitions = require(modules.Functions.Framework:WaitForChild("Transitions"))
local plrStatsModule = require(modules.Dictionaries:WaitForChild("PlrStats"))
local Skins = require(modules.Dictionaries:WaitForChild("Skins"))

local plr = Players.LocalPlayer

local OriginalPlrPos: Vector3

function CharacterController.setupChar()
    plrStatsModule.plrChar.b.b:GetPropertyChangedSignal("Image"):Connect(function() --temp
        plrStatsModule.plrAppearance.skin = plrStatsModule.plrChar.b.b.Image
        remotes.Appearance.ChangeAppearance:FireServer(plrStatsModule.plrAppearance)
    end)
    
    plrStatsModule.plrChar.Touched:Connect(function(h)
        if h and h.Parent then
            if
                string.sub(h.Name, 1, 6) == "random"
                and not _G.c
                and not h.Anchored
                and plrStatsModule.stats["cool"] > 0
            then
                plrStatsModule.battling = true
                OriginalPlrPos = plrStatsModule.plrChar.Position
                if plrStatsModule.room then
                    plrStatsModule.room:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
                end
                remotes.Framework.battle:Invoke(
                    nil,
                    h.BT.img.Value,
                    h,
                    h.BT:FindFirstChild("wotah") and workspace.map:FindFirstChild("wotah_reference")
                        or plrStatsModule.f1
                        or assets.Framework.BattlePlaceholder,
                    true,
                    plrStatsModule.maps,
                    h.BT.music.Value
                )
                if plrStatsModule.room then
                    plrStatsModule.room:SetPrimaryPartCFrame(CFrame.new(0, 100, 0))
                end
                plrStatsModule.plrChar.CFrame = CFrame.new(OriginalPlrPos)
                plrStatsModule.plrChar.p.Position = OriginalPlrPos
                plrStatsModule.battling = false
                Transitions.PixelTransition()
            end
        end
    end)

    local ite = {}
	for x = 1, 20 do
		if #plrStatsModule.plrItems == 20 then
			if x <= 10 then
				ite[x] = "0" .. string.sub(plrStatsModule.plrItems, x * 2 - 1, x * 2)
			else
				ite[x] = "000"
			end
		else
			ite[x] = string.sub(plrStatsModule.plrItems, x * 3 - 2, x * 3)
		end
	end
	plrStatsModule.plrItems = ite
	plrStatsModule.data[3] = not plrStatsModule.data[3] and "00" or plrStatsModule.data[3]
	plrStatsModule.plrChar.b.b.Image = "http://www.roblox.com/asset/?id=" .. Skins.find(plrStatsModule.data[3])
	plrStatsModule.plrChar.b.b.ImageRectSize = Vector2.new(50, 50)
	plrStatsModule.plrChar.b.b.ImageRectOffset = Vector2.new(0, 0)

    plr.ReplicationFocus = plrStatsModule.plrChar
    plrStatsModule.plrChar.CollisionGroup = "localPlayer"
end

return CharacterController