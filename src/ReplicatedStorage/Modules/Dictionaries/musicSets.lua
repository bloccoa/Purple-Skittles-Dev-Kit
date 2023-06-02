--!strict
local musicSets = {}
musicSets.ids = {
	jammies = 9989217962,
    desert = 9989258061,
	house = 9989221410,
	water = 10019333189,
}

musicSets.translate = {
	s1 = "jammies",
    s2 = "desert",
	s11 = "water",
	sH = "house",
}

for x, v in pairs(musicSets.ids) do
	musicSets.ids[x] = "rbxassetid://" .. v
end

return musicSets
