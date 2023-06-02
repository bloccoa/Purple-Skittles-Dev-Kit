--!strict
local returnthis = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local modules = ReplicatedStorage:WaitForChild("Modules")
local assets = ReplicatedStorage:WaitForChild("Assets")
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local BattleModule = require(modules.Functions.Framework:WaitForChild("BattleModule"))
local plrStatsModule = require(modules.Dictionaries:WaitForChild("PlrStats"))
local SavingModule = require(modules.Functions:WaitForChild("SavingModule"))
local Transitions = require(modules.Functions.Framework:WaitForChild("Transitions"))
local CustomEvents = require(modules.Functions:WaitForChild("CustomEvents"))

local SFX = SoundService.sfx

local hint: boolean = false
local hintready: boolean = false
local wai

local OriginalPlrPos: Vector3 = Vector3.new()

returnthis.ans = 1
returnthis.ChatLabel = assets.Framework.Text:Clone()
returnthis.ChatFrame = returnthis.ChatLabel.g.t

local function getBounds(tx)
	assets.Framework.GUI.t.Text = tx
	return assets.Framework.GUI.t.TextBounds.X
end

local function getWord(tx: string) : string
	for x = 1, #tx do
		local i = string.sub(tx, x, x)
		if i == " " or i == "." or i == "?" or i == "!" or x == #tx then
			return string.sub(tx, 1, x == #tx and -1 or x - 1)
		end
    end
    return tx
end

local function customTexts(txt: string): string
	if string.find(txt, "%%") then -- there is a punishment for people like me who do this type of overcomplication
        local startval, endval = string.find(txt, "%%")
        local startval: number = startval :: number -- bad fix for typechecking but whatever
        local endval: number = endval :: number
		local firststring = string.sub(txt, 1, startval - 1)
		local secondstring = string.sub(txt, endval + 5, #txt)
		local inbetween = string.sub(txt, startval + 2, endval + 2)
		if plrStatsModule.Keybinds[inbetween] then
			txt = firststring .. plrStatsModule.Keybinds[inbetween][plrStatsModule.CurrentInputType] .. secondstring
		end
	end
	return txt
end

remotes.Framework.inpBegan.Event:Connect(function()
	if plrStatsModule.ButtonsTouching.Up == true then
		returnthis.ans = _G.c and returnthis.ans == 1 and 2 or 1
	elseif plrStatsModule.ButtonsTouching.Left == true then
		returnthis.ans = _G.c and returnthis.ans == 1 and 2 or 1
	elseif plrStatsModule.ButtonsTouching.Down == true then
		returnthis.ans = _G.c and returnthis.ans == 1 and 2 or 1
	elseif plrStatsModule.ButtonsTouching.Right == true then
		returnthis.ans = _G.c and returnthis.ans == 1 and 2 or 1
	elseif plrStatsModule.ButtonsTouching.X == true then
		if wai then
			wai = false
		end
	end
	if returnthis.ans == 2 then
		returnthis.ChatFrame.cur.Position = UDim2.new(0.5, 0, 0, -20)
	else
		returnthis.ChatFrame.cur.Position = UDim2.new(0, 30, 0, -20)
	end
end)

function returnthis.Chat(tx, o)
	if not _G.c then
		_G.c = true
		local txt = customTexts(tx.Value)

		returnthis.ChatFrame.Visible = true
		returnthis.ChatFrame.ans1.Visible = false
		returnthis.ChatFrame.ans2.Visible = false
		returnthis.ChatFrame.stop.Visible = false
		returnthis.ChatFrame.title.Text = o.Name
		if returnthis.ans == 2 then
			returnthis.ChatFrame.cur.Position = UDim2.new(0.5, 0, 0, -20)
		else
			returnthis.ChatFrame.cur.Position = UDim2.new(0, 30, 0, -20)
		end

		if tx:FindFirstChild("level") then
			SFX.level:Play()
		end

		if tx and txt ~= "SKIP" then
			if tx.Name == "po" or tx.Name == "po2" then
				returnthis.ChatFrame.title.Text = ""
				returnthis.ChatFrame.BackgroundColor3 = Color3.fromRGB(254, 169, 0)
				returnthis.ChatFrame.stop.ImageColor3 = Color3.fromRGB(255, 212, 133)
			elseif tx.Name == "pr" then
				returnthis.ChatFrame.title.Text = ""
				returnthis.ChatFrame.BackgroundColor3 = Color3.new(0, 1, 1)
				returnthis.ChatFrame.stop.ImageColor3 = Color3.fromRGB(133, 255, 255)
			else
				returnthis.ChatFrame.BackgroundColor3 = Color3.new(1, 1, 1)
				returnthis.ChatFrame.stop.ImageColor3 = Color3.fromRGB(255, 133, 237)
			end
			returnthis.ChatFrame.static.color.BackgroundColor3 = returnthis.ChatFrame.BackgroundColor3
			if tx.Name ~= "ans1" and tx.Name ~= "ans2" then
				returnthis.ChatFrame.Frame:ClearAllChildren()

				local sizeX, sizeY, openType, open = 0, 0, nil, nil

				for x = 1, #txt do
					local t = assets.Framework.GUI.t:Clone()
					local R = string.sub(txt, x, x)
					t.Parent = returnthis.ChatFrame.Frame
					t.Text = R

					if R == " " then
						local i = getWord(string.sub(txt, x + 1, -1))
						if i and sizeX + getBounds(i) > 425 then
							sizeX = 0
							sizeY = sizeY + t.TextSize
						end
					end

					if
						sizeX == 0 and R == " "
						or R == "@"
						or R == "#"
						or R == "$"
						or R == "%"
						or R == "^"
						or R == "&"
						or R == "*"
						or R == "_"
					then
					else
						sizeX = sizeX + t.TextBounds.X
					end
					if sizeX > 425 then
						sizeX = t.TextBounds.X
						sizeY = sizeY + t.TextSize
					end

					t.Position = UDim2.new(0, sizeX - t.TextBounds.X, 0, sizeY)

					if R == "@" or R == "#" or R == "$" or R == "%" or R == "^" or R == "&" or R == "*" or R == "_" then
						t:Destroy()
						open = not open
						openType = R
					end
					if open then --opex
						t.Name = "B" .. openType
						if openType == "@" then
							t.TextColor3 = Color3.new(1, 0.3, 0.3)
						elseif openType == "#" then
							t.TextColor3 = Color3.new(1, 0.85, 0)
						elseif openType == "$" then
							t.TextColor3 = Color3.new(0.3, 1, 0.7)
						elseif openType == "%" then
							t.TextColor3 = Color3.new(0.3, 0.7, 1)
							if hint == false and hintready == false then
								hint = true
							end
						elseif openType == "^" then
							Instance.new("NumberValue", t).Name = "n"
							Instance.new("IntValue", t).Name = "p"
							t.p.Value = t.Position.Y.Offset
						elseif openType == "&" then
							Instance.new("IntValue", t).Name = "x"
							t.x.Value = t.Position.X.Offset
							Instance.new("IntValue", t).Name = "y"
							t.y.Value = t.Position.Y.Offset
						elseif openType == "*" then
							t.FontSize = "Size18"
							t.Position = t.Position + UDim2.new(0, 0, 0, 10)
						elseif openType == "_" then
						end
					end

					if math.fmod(x, 4) == 0 then
						SFX.talk:Play()
						if o.Name == "Glitch the Eggstick" and tx and tx.Name ~= "po" then
							if o.b.b.Rotation == 0 then
								o.b.b.Rotation = math.random(-25, 25)
							elseif o.b.b.Rotation ~= 0 then
								o.b.b.Rotation = 0
							end
						end
						if
							o
							and (string.sub(o.Name, 1, 12) ~= "Mini-Fridge " and string.sub(o.Name, 1, 13) ~= "Skittle Pack " and o.Name ~= "Glitch the Eggstick" and o:FindFirstChild(
								"b"
							) and o.b:FindFirstChild("b"))
							and tx
							and tx.Name ~= "po"
						then
							if o.b.b.ImageRectOffset == Vector2.new(150, 0) and not o:FindFirstChild("diafix") then
								o.b.b.ImageRectOffset = Vector2.new(150, 50)
							elseif o.b.b.ImageRectOffset == Vector2.new(150, 50) and not o:FindFirstChild("diafix") then
								o.b.b.ImageRectOffset = Vector2.new(150, 0)
							elseif o.b.b.ImageRectOffset == Vector2.new(200, 0) and o:FindFirstChild("diafix") then
								o.b.b.ImageRectOffset = Vector2.new(0, 0)
							elseif o.b.b.ImageRectOffset == Vector2.new(0, 0) and o:FindFirstChild("diafix") then
								o.b.b.ImageRectOffset = Vector2.new(200, 0)
							end
						end
					end

					if math.fmod(x, 4) == 0 and hint == true and hintready == false and openType == "%" then
						hint = false
						hintready = true
					end
					if hintready == true and hint == false then
						hint = true
						SFX.hint:Play()
					end
					if math.fmod(x, 2) == 0 then
						task.wait(0.02)
					end
				end
				returnthis.ChatFrame.stop.Visible = true
				if
					o
					and string.sub(o.Name, 1, 12) ~= "Mini-Fridge "
					and string.sub(o.Name, 1, 13) ~= "Skittle Pack "
					and o.Name ~= "Glitch the Eggstick"
					and o:FindFirstChild("b")
					and o.b:FindFirstChild("b")
					and not o:FindFirstChild("diafix")
				then
					o.b.b.ImageRectOffset = Vector2.new(150, 0)
				elseif
					o
					and string.sub(o.Name, 1, 12) ~= "Mini-Fridge "
					and string.sub(o.Name, 1, 13) ~= "Skittle Pack "
					and o.Name ~= "Glitch the Eggstick"
					and o:FindFirstChild("b")
					and o.b:FindFirstChild("b")
					and o:FindFirstChild("diafix")
				then
					o.b.b.ImageRectOffset = Vector2.new(0, 0)
				elseif o and o.Name == "Glitch the Eggstick" then
					o.b.b.Rotation = 0
				end
				wai = true
				repeat
					RunService.RenderStepped:Wait()
				until not wai
			end

			hintready = false
			if tx:FindFirstChild("colorRed") then
				o.b.b.ImageColor3 = Color3.new(1, 0, 0)
			elseif tx:FindFirstChild("colorWhite") then
				o.b.b.ImageColor3 = Color3.new(1, 1, 1)
			end
		end

		if tx:FindFirstChild("myst") then
			SFX.mysterious:Play()
		end

		if tx:FindFirstChild("unlock") then
			SFX.unlock:Play()
		end

		if tx:FindFirstChild("tx") then
			_G.c = false --found tx
			returnthis.Chat(tx.tx, o)
		elseif tx:FindFirstChild("ans1") then --found ans1
			returnthis.ChatFrame.Frame:ClearAllChildren()
			returnthis.ChatFrame.stop.Visible = false
			returnthis.ChatFrame.ans1.Visible = true
			returnthis.ChatFrame.ans2.Visible = true
			returnthis.ChatFrame.cur.Visible = true
			returnthis.ChatFrame.ans1.Text = tx.ans1.Value
			returnthis.ChatFrame.ans2.Text = tx.ans2.Value

			returnthis.ChatFrame.BackgroundColor3 = Color3.new(0.996078, 0.662745, 0)
			returnthis.ChatFrame.static.color.BackgroundColor3 = Color3.new(1, 0.662745, 0)
			returnthis.ChatFrame.stop.BackgroundColor3 = Color3.new(1, 0.662745, 0)

			returnthis.ChatFrame.title.Text = ""
			returnthis.ans = 1
			wai = true
			if returnthis.ans == 2 then
				returnthis.ChatFrame.cur.Position = UDim2.new(0.5, 0, 0, -20)
			else
				returnthis.ChatFrame.cur.Position = UDim2.new(0, 30, 0, -20)
			end
			repeat
				RunService.RenderStepped:Wait()
			until not wai
			_G.c = false
			returnthis.ChatFrame.cur.Visible = false
			returnthis.Chat(tx["ans" .. returnthis.ans], o)
		elseif tx:FindFirstChild("BATTLE") then --found battle
			plrStatsModule.battling = true
			_G.c = false
			returnthis.ChatFrame.Visible = false
			OriginalPlrPos = plrStatsModule.plrChar.Position
			if plrStatsModule.room then
				plrStatsModule.room:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
			end

			local win, ran = BattleModule.BATTLE(
				nil,
				o.b.b,
				tx.BATTLE,
				plrStatsModule.f1,
				false,
				plrStatsModule.maps,
				tx.BATTLE:FindFirstChild("BT"):FindFirstChild("music") and tx.BATTLE.BT.music.Value
			)
			if plrStatsModule.room then
				plrStatsModule.room:SetPrimaryPartCFrame(CFrame.new(0, 100, 0))
			end
			plrStatsModule.plrChar.CFrame = CFrame.new(OriginalPlrPos)
			plrStatsModule.plrChar.p.Position = OriginalPlrPos
			plrStatsModule.battling = false
			Transitions.PixelTransition()
			if win then
				returnthis.Chat(tx.BATTLE.tx, o)
			elseif ran and plrStatsModule.stats["cool"] > 0 then
				if tx.BATTLE:FindFirstChild("runtx") then
					returnthis.Chat(tx.BATTLE.runtx, o)
				else
					returnthis.Chat(tx.BATTLE.tx2, o)
				end
			else
				returnthis.Chat(tx.BATTLE.tx2, o)
			end
		elseif tx:FindFirstChild("INT") then
			if tx.INT:FindFirstChild("save") then
				o.save.Value = tx.INT.save.Value
				SavingModule.npcsave[o.save.npc.Value] = o.save.Value
			end
			local r1, r2 = CustomEvents.customEvent(tx, o, {
				returnthis.ChatFrame,
				plrStatsModule.stats["cool"],
				plrStatsModule.stats["maxcool"],
			})
			if r1 then
				plrStatsModule.plrItems = r1
			end
			if r2 then
				plrStatsModule.stats["cool"] = r2
			end
		elseif tx:FindFirstChild("po") then
			_G.c = false
			returnthis.Chat(tx.po, o)
		elseif tx:FindFirstChild("pr") then
			_G.c = false
			returnthis.Chat(tx.pr, o)
		else
			_G.c = false
			returnthis.ChatFrame.Visible = false
		end
	end
end

remotes.Framework.Chat.OnInvoke = function(...)
	returnthis.Chat(...)
end

return returnthis