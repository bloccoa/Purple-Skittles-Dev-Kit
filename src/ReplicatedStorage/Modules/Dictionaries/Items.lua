--!nocheck
--//ITEMS
--// Module used for items. This stores most of everything
--// HOW TO USE:
--// [itemNum] = name,description,what text is written when the item's used
-- this module was supposed to be cleaned up but    i got lazy have fun

local returnthis = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local modules = ReplicatedStorage.Modules
local remotes = ReplicatedStorage.Remotes
local assets = ReplicatedStorage.Assets

local plrStatsModule = require(modules.Dictionaries:WaitForChild("PlrStats"))
local skinsModule = require(modules.Dictionaries:WaitForChild("Skins"))

local plrLocalName: string = plrStatsModule.plrLocalName

local cam: Camera = workspace.CurrentCamera

local SFX = SoundService.sfx

local assetid: string = "http://www.roblox.com/asset/?id="

local items = { --[item id] = {item name, item description, item use text},
	["000"] = { "Empty", "", {} },
	["002"] = { "Regular Suit", "The classic.", { plrLocalName .. " wore the Regular Suit." } },
	["003"] = {
		"Kevin Disguise",
		"we are dirt and they are special dirt.",
		{ plrLocalName .. " wore some weirdo's attire." },
	},
	["004"] = { "Pizza", "Gives 70 cool.", { plrLocalName .. " ate the pizza.", plrLocalName .. " got 70 cool." } },
	["007"] = { "Sleek Suit", "Sleekest of all.", { plrLocalName .. " wore the Sleek Suit." } },
	["008"] = { "Bee Suit", "Smells used.", { plrLocalName .. " converted into bubblism." } },
	["028"] = {
		"Choco Bar",
		"Gives 35 cool.",
		{ plrLocalName .. " ate the Choco Bar.", plrLocalName .. " got 35 cool." },
	},
	["107"] = { "Viridian Suit", "no you cannot flip", { plrLocalName .. " became an obscure indie reference." } },
	["118"] = { "Odd Uniform", "Unknown origins.", { plrLocalName .. " put on the uniform." } },
}

local function skin(x)
	return skinsModule.find(x)
end

function returnthis.itemget(num)
	if num == tonumber(num) then
		num = num < 10 and "00" .. tostring(num) or num < 100 and "0" .. tostring(num) or tostring(num)
	end

	if items[num] ~= nil then
		return items[num]
	else
		warn("Request to get item " .. num .. " failed! Reason: not found")
		return items["000"]
	end
end

function returnthis.useitem(x, toss, items, mhp, p, cool, dt3)
	if x then --uses the item
		local data3
		local num = items[x]
		local ret = "000"
		local no = _G.canItem(num)
		local skins = {
			2,
			3,
			7,
			8,
			107,
			118,
		}
		local bro
		if _G.get("broat") then
			for _, v in pairs(skins) do
				if tonumber(num) == v then
					bro = true
					no = true
				end
			end
		end
		local maxi = false

		if not toss and not bro then
			if num == "000" then
			elseif num == "001" then
				cool = math.min(mhp, cool + 25)
				maxi = true
			elseif num == "002" then
				p.b.b.Image = assetid .. skin("00")
				_, ret = skin(dt3)
				data3 = "00"
			elseif num == "003" then
				p.b.b.Image = assetid .. skin("01")
				_, ret = skin(dt3)
				data3 = "01"
			elseif num == "004" then
				cool = math.min(mhp, cool + 70)
				maxi = true
			elseif num == "005" then
				cool = math.min(mhp, cool + 150)
				maxi = true
			elseif num == "006" then
				cool = mhp --math.min(mhp,cool+9999)
			elseif num == "007" then
				p.b.b.Image = assetid .. skin("02")
				_, ret = skin(dt3)
				data3 = "02"
			elseif num == "008" then
				p.b.b.Image = assetid .. skin("03")
				_, ret = skin(dt3)
				data3 = "03"
				remotes.badge:FireServer(401503389) --A Mysterious Challenger!
			elseif num == "009" then
				p.b.b.Image = assetid .. skin("04")
				_, ret = skin(dt3)
				data3 = "04"
			elseif num == "010" then
				cool = math.min(mhp, cool + 80)
				maxi = true
			elseif num == "011" then
				p.b.b.Image = assetid .. skin("05")
				_, ret = skin(dt3)
				data3 = "05"
				remotes.badge:FireServer(387403867) --Bed murderer!
			elseif num == "012" then
				cool = math.min(mhp, cool + 100)
				maxi = true
			elseif num == "022" then
				cool = math.min(mhp, cool + 5)
				maxi = true
			elseif num == "023" then
			elseif num == "024" then
				cool = cool - 20
			elseif num == "025" then
				cool = cool - 80
			elseif num == "026" then
				p.b.b.Image = assetid .. skin("07")
				_, ret = skin(dt3)
				data3 = "07"
				remotes.badge:FireServer(394005951) --True Alpha!
			elseif num == "027" then
			elseif num == "028" then
				cool = math.min(mhp, cool + 35)
				maxi = true
			elseif num == "029" then
				cool = cool - 50
			elseif num == "030" then
				cool = math.min(mhp, cool + 400)
				maxi = true
			elseif num == "031" then
			elseif num == "032" then
				p.b.b.Image = assetid .. skin("08")
				_, ret = skin(dt3)
				data3 = "08"
			elseif num == "033" then
				p.b.b.Image = assetid .. skin("09")
				_, ret = skin(dt3)
				data3 = "09"
			elseif num == "034" then
				p.b.b.Image = assetid .. skin("10")
				_, ret = skin(dt3)
				data3 = "10"
			elseif num == "035" then
				p.b.b.Image = assetid .. skin("11")
				_, ret = skin(dt3)
				data3 = "11"
			elseif num == "036" then
				p.b.b.Image = assetid .. skin("12")
				_, ret = skin(dt3)
				data3 = "12"
			elseif num == "037" then
				p.b.b.Image = assetid .. skin("13")
				_, ret = skin(dt3)
				data3 = "13"
			elseif num == "038" then
				p.b.b.Image = assetid .. skin("14")
				_, ret = skin(dt3)
				data3 = "14"
			elseif num == "039" then
				cool = cool - 420
			elseif num == "040" then
			elseif num == "041" then
			elseif num == "042" then
				cool = cool + 50 + math.min(mhp, math.random(50))
				maxi = true
			elseif num == "043" then
			elseif num == "044" then
				_G.set("speed", _G.get("speed"))
			elseif num == "045" then
				_G.set("attack", _G.get("attack"))
			elseif num == "046" then
				p.b.b.Image = assetid .. skin("15")
				_, ret = skin(dt3)
				data3 = "15"
			elseif num == "047" then
				_G.set("runn", true)
			elseif num == "048" then
				p.b.b.Rotation = p.b.b.Rotation == 0 and 180 or 0
			elseif num == "049" then
				local b = Instance.new("ColorCorrectionEffect", cam)
				b.Saturation = -100
				b.Name = "cake"
			elseif num == "057" then
				local tweeninf = TweenInfo.new(0.2, Enum.EasingStyle.Linear)
				p.Anchored = true
				TweenService:Create(p, tweeninf, { Position = p.Position + Vector3.new(0, 3, 0) }):Play()
				task.wait(1.2)
				TweenService:Create(p, tweeninf, { Position = p.Position + Vector3.new(0, -3, 0) }):Play()
				task.wait(0.2)
				p.Anchored = false
			elseif num == "058" then
			elseif num == "059" then
				p.b.b.Image = assetid .. skin("16")
				_, ret = skin(dt3)
				data3 = "16"
				--remotes.badge:FireServer(425241532)--podayto
			elseif num == "060" then
				p.b.b.Image = assetid .. skin("22")
				_, ret = skin(dt3)
				data3 = "22"
			elseif num == "061" then
				p.b.b.Image = assetid .. skin("17")
				_, ret = skin(dt3)
				data3 = "17"
			elseif num == "062" then
				p.b.b.Image = assetid .. skin("18")
				_, ret = skin(dt3)
				data3 = "18"
			elseif num == "063" then
				p.b.b.Image = assetid .. skin("19")
				_, ret = skin(dt3)
				data3 = "19"
			elseif num == "064" then
				p.b.b.Image = assetid .. skin("20")
				_, ret = skin(dt3)
				data3 = "20"
			elseif num == "065" then
				p.b.b.Image = assetid .. skin("21")
				_, ret = skin(dt3)
				data3 = "21"
			elseif num == "066" then
				cool = math.min(mhp, cool + 160)
				maxi = true
			elseif num == "068" then
				cool = math.min(mhp, cool + 130)
				maxi = true
			elseif num == "069" then
				p.b.b.Image = assetid .. skin("23")
				_, ret = skin(dt3)
				data3 = "23"
			elseif num == "070" then
				p.b.b.Image = assetid .. skin("24")
				_, ret = skin(dt3)
				data3 = "24"
			elseif num == "071" then
				cool = math.min(mhp, cool + 50)
				maxi = true
			elseif num == "072" then
				cool = math.min(mhp, cool + 50)
				maxi = true
			elseif num == "073" then
				cool = math.min(mhp, cool + 50)
				maxi = true
			elseif num == "074" then
				cool = math.min(mhp, cool + 50)
				maxi = true
			elseif num == "075" then
				cool = math.min(mhp, cool + 50)
				maxi = true
			elseif num == "076" then
				p.b.b.Image = assetid .. skin("25")
				_, ret = skin(dt3)
				data3 = "25"
			elseif num == "077" then
				p.b.b.Image = assetid .. skin("26")
				_, ret = skin(dt3)
				data3 = "26"
			elseif num == "078" then
				p.b.b.Image = assetid .. skin("27")
				_, ret = skin(dt3)
				data3 = "27"
			elseif num == "079" then
				p.b.b.Image = assetid .. skin("28")
				_, ret = skin(dt3)
				data3 = "28"
			elseif num == "080" then
				p.b.b.Image = assetid .. skin("29")
				_, ret = skin(dt3)
				data3 = "29"
			elseif num == "081" then
				p.b.b.Image = assetid .. skin("30")
				_, ret = skin(dt3)
				data3 = "30"
			elseif num == "082" then
				p.b.b.Image = assetid .. skin("31")
				_, ret = skin(dt3)
				data3 = "31"
			elseif num == "083" then
				p.b.b.Image = assetid .. skin("32")
				_, ret = skin(dt3)
				data3 = "32"
			elseif num == "084" then
				p.b.b.Image = assetid .. skin("33")
				_, ret = skin(dt3)
				data3 = "33"
			elseif num == "085" then
				p.b.b.Image = assetid .. skin("34")
				_, ret = skin(dt3)
				data3 = "34"
			elseif num == "086" then
				p.b.b.Image = assetid .. skin("35")
				_, ret = skin(dt3)
				data3 = "35"
			elseif num == "087" then
				p.b.b.Image = assetid .. skin("36")
				_, ret = skin(dt3)
				data3 = "36"
			elseif num == "088" then
				p.b.b.Image = assetid .. skin("37")
				_, ret = skin(dt3)
				data3 = "37"
			elseif num == "089" then
				p.b.b.Image = assetid .. skin("38")
				_, ret = skin(dt3)
				data3 = "38"
			elseif num == "090" then
				cool = math.min(mhp, cool + 20)
				maxi = true
			elseif num == "091" then
				p.b.b.Image = assetid .. skin("39")
				_, ret = skin(dt3)
				data3 = "39"
			elseif num == "092" then
				p.b.b.Image = assetid .. skin("40")
				_, ret = skin(dt3)
				data3 = "40"
			elseif num == "093" then
				p.b.b.Image = assetid .. skin("41")
				_, ret = skin(dt3)
				data3 = "41"
			elseif num == "094" then
				p.b.b.Image = assetid .. skin("42")
				_, ret = skin(dt3)
				data3 = "42"
			elseif num == "095" then --key thing someone didnt add lol
			elseif num == "096" then
				p.b.b.Image = assetid .. skin("43")
				_, ret = skin(dt3)
				data3 = "43"
			elseif num == "097" then
				p.b.b.Image = assetid .. skin("44")
				_, ret = skin(dt3)
				data3 = "44"
			elseif num == "098" then
				p.b.b.Image = assetid .. skin("45")
				_, ret = skin(dt3)
				data3 = "45"
			elseif num == "099" then
				_G.set("speedattack", _G.get("speedattack"))
			elseif num == "100" then --purple skittle :O
			elseif num == "101" then
				cool = 0 / cool + ((1000000 / 1000000 - 1) * (-math.cos(math.pi)))
			elseif num == "102" then
				p.b.b.Image = assetid .. skin("46")
				_, ret = skin(dt3)
				data3 = "46"
			elseif num == "103" then
				p.b.b.Image = assetid .. skin("47")
				_, ret = skin(dt3)
				data3 = "47"
				SFX.ohno:Play()
			elseif num == "104" then
				for x = 1, 5 do
					_G.set("attack", _G.get("attack"))
				end
				cool = mhp
				maxi = true
			elseif num == "105" then
				p.b.b.Image = assetid .. skin("48")
				_, ret = skin(dt3)
				data3 = "48"
			elseif num == "106" then
				p.b.b.Image = assetid .. skin("49")
				_, ret = skin(dt3)
				data3 = "49"
			elseif num == "107" then
				p.b.b.Image = assetid .. skin("50")
				_, ret = skin(dt3)
				data3 = "50"
			elseif num == "108" then
				p.b.b.Image = assetid .. skin("51")
				_, ret = skin(dt3)
				data3 = "51"
			elseif num == "109" then
				p.b.b.Image = assetid .. skin("52")
				_, ret = skin(dt3)
				data3 = "52"
			elseif num == "110" then
				p.b.b.Image = assetid .. skin("53")
				_, ret = skin(dt3)
				data3 = "53"
			elseif num == "111" then
				p.b.b.Image = assetid .. skin("54")
				_, ret = skin(dt3)
				data3 = "54"
			elseif num == "112" then
				p.b.b.Image = assetid .. skin("55")
				_, ret = skin(dt3)
				data3 = "55"
			elseif num == "113" then
				p.b.b.Image = assetid .. skin("56")
				_, ret = skin(dt3)
				data3 = "56"
			elseif num == "114" then
				p.b.b.Image = assetid .. skin("57")
				_, ret = skin(dt3)
				data3 = "57"
			elseif num == "115" then
				p.b.b.Image = assetid .. skin("58")
				_, ret = skin(dt3)
				data3 = "58"
			elseif num == "116" then
				p.b.b.Image = assetid .. skin("59")
				_, ret = skin(dt3)
				data3 = "59"
			elseif num == "117" then
				p.b.b.Image = assetid .. skin("60")
				_, ret = skin(dt3)
				data3 = "60"
			elseif num == "118" then
				p.b.b.Image = assetid .. skin("61")
				_, ret = skin(dt3)
				data3 = "61"
			end
		end
		if not no then
			items[x] = ret
		end
		_G.c = false
		local item = returnthis.itemget(num)
		local bott = {}
		if bro then
			bott = { "You can't switch outfits in a boat." }
		else
			if maxi and cool == mhp then
				bott[#bott + 1] = plrLocalName .. "'s cool was maxed out!"
			end
			if toss and not no then
				SFX.toss:Play()
				bott[#bott + 1] = plrLocalName .. " threw the " .. item[1] .. " away."
			elseif toss and no then
				bott[#bott + 1] = "This can't be tossed."
			elseif not toss then
				if no then
					bott[#bott + 1] = "This stayed in " .. plrLocalName .. "'s inventory."
				end
				if item[3] then
					for i = #item[3], 1, -1 do
						table.insert(bott, 1, item[3][i])
					end
				end
			end
		end

		assets.Framework.ItemUse:ClearAllChildren()
		local last = assets.Framework.ItemUse
		for _, v in pairs(bott) do
			local r = Instance.new("StringValue", last)
			r.Value = v
			r.Name = "po"
			last = r
		end
		remotes.Framework.Chat:Invoke(assets.Framework.ItemUse, assets.Framework.ItemUse)
		return items, cool, data3
	end
end

return returnthis
