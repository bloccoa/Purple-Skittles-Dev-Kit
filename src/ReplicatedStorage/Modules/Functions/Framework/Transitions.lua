--!strict
--//TRANSITIONS
--// transitions like the circle one and the pixely one

local returnthis = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local assets = ReplicatedStorage:WaitForChild("Assets")

local plr = Players.LocalPlayer
local plrGui = plr.PlayerGui
local mainGui = plrGui.Main

--//THE MAIN THING
function returnthis.CircleTransition(t: any?)
	local c = mainGui.cut
	c.Visible = true
	for x = t and 0 or 25, t and 25 or 0, t and 1 or -1 do
		local dt = RunService.RenderStepped:Wait()
		local sz = (
			(x ^ 3)
			/ (20 ^ 3)
			* (mainGui.AbsoluteSize.X > mainGui.AbsoluteSize.Y and mainGui.AbsoluteSize.X or mainGui.AbsoluteSize.Y)
		) / 2 * (dt*60)
		c.cen.Position = UDim2.new(0.5, -sz, 0.5, -sz)
		c.cen.Size = UDim2.new(0, sz * 2, 0, sz * 2)
		c.l.Size = UDim2.new(0.5, -sz, 1, 0)
        c.r.Size = UDim2.new(-0.5, sz, 1, 0)
		c.u.Size = UDim2.new(0, sz * 2, 0.5, -sz)
        c.u.Position = UDim2.new(0.5, -sz, 0, 0)
		c.d.Size = UDim2.new(0, sz * 2, -0.5, sz)
        c.d.Position = UDim2.new(0.5, -sz, 1, 0)
	end
	c.Visible = not t
end

function returnthis.PixelTransition(t: boolean?)
	local effect: ColorCorrectionEffect = Lighting.FX
	if t then
		local ro = math.random(3)
		local ro2 = (math.random(2) - 1.5) * 2
		for x = 1, 24 do
			effect.Saturation = -x / 20 * 2.8
			for y = 1, 22 do
				local e = assets.Framework.GUI.fr:Clone()
				e.Parent = mainGui.op
				e.Position = UDim2.new(x / 20 - 1 / 20, 0, y / 20 - 1 / 20, -36)
				e.Size = UDim2.new(1 / 20, 1, 1 / 20, 1)
				e.BackgroundColor3 = Color3.new(
					math.random() + (ro == 1 and x / 20 or ro2 / y),
					math.random() + (ro == 2 and x / 20 or ro2 / y),
					math.random() + (ro == 3 and x / 20 or ro2 / y)
				)
				if math.fmod(y, 5) == 0 then
					RunService.RenderStepped:Wait()
				end
			end
		end
	else
		local t = mainGui.op:GetChildren()

		for y, v in pairs(t) do
			if math.fmod(y, 5) == 2 then
				RunService.RenderStepped:Wait()
			end
			v:Destroy()
			effect.Saturation = -(#t - y) / #t * 2.8
		end
	end
end

return returnthis
