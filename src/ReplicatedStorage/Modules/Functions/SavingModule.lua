--!strict
--//SAVING MODULES
--// Saves stuff.
--// intially the saveStuff function

local returnthis = {}

local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local plrGui = plr.PlayerGui

local cam = workspace.CurrentCamera

returnthis.npcsave = {}

--//THE MAIN THING
function returnthis.Save(int, o: any)
	if int == 1 then --npc cant talk
		o.tx:Destroy()
	elseif int == 2 then --delete npc
		o:Destroy()
	elseif int == 4 then --move up
		o.tx:Destroy()
		o.CFrame = o.CFrame + Vector3.new(0, 2)
	elseif int == 5 then --Donald
		o.CFrame = o.CFrame + Vector3.new(0, 0, 2)
		for x = 1, 20 do
			o.b.b.Rotation = x / 20 * 180
			o.CFrame = o.CFrame + Vector3.new(0, -0.4)
		end
		o.tx:ClearAllChildren()
		o.tx.Value = "!NOW I"
	elseif int == 6 then --move left
		o.tx:Destroy()
		o.CanCollide = false
		o.CornerWedgePartHitbox.CFrame = o.CornerWedgePartHitbox.CFrame + Vector3.new(-2, 0)
	elseif int == 7 then --save quest states
		if o:FindFirstChild("questisACTIVATE") then
			o.questisACTIVATE.Value = true
		end
	elseif int == 8 then --nothin'
	elseif int == 9 then --tossed on shore
		o.tx:Destroy()
		o.tx2.Name = "tx"
		o.b.b.Rotation = 360
		if o:FindFirstChild("hit") then
			o.hit.CanCollide = true
		end
		o.CFrame = o.CFrame + Vector3.new(-6, 4.2, -5)
		o.Size = Vector3.new(2, 2, 2)
		if o:FindFirstChild("questisACTIVATE") then
			o.questisACTIVATE.Value = true
		end
	elseif int == 10 then --nothin'
	elseif int == 11 then --hypersnake
		local tempnpc = cam.npcs:FindFirstChild("Chill Snakeman")

		o:Destroy()

		if tempnpc then
			tempnpc.CFrame = tempnpc.CFrame + Vector3.new(0, 4)
		end
	elseif int == 12 then --chill snakeman
		local tempnpc = cam.npcs:FindFirstChild("Chill Snakeman")

		if tempnpc then
			tempnpc.tx:Destroy()
			tempnpc.tx2.Name = "tx"
		end
	end
end

return returnthis
