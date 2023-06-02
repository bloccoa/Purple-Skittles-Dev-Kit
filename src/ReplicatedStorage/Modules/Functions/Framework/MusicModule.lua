--!strict
-- // MUSIC MODULE
-- // Contains functions to play music n stuff
-- // lol
local returnthis = {}

local SoundService = game:GetService("SoundService")

local MUS = SoundService.mus
local musSound = SoundService.music
local musPlaying = SoundService.musicplaying

returnthis.music = "" --for the id sets

-- //THE MAIN THING
function returnthis.musicstop()
    musSound:Stop()
    if MUS:FindFirstChild(musPlaying.Value) then
        MUS[musPlaying.Value]:Stop()
    elseif MUS.battle:FindFirstChild(musPlaying.Value) then
        MUS.battle[musPlaying.Value]:Stop()
    end
end

function returnthis.musicplay(the:string)
    if MUS:FindFirstChild(the) then
        MUS[the]:Play()
        musPlaying.Value = the
    else
        if MUS.battle:FindFirstChild(the) then
            MUS.battle[the]:Play()
            musPlaying.Value = the
        else
            warn("Song" .. the .. " not found!, current song playing:" .. musPlaying.Value)
        end
    end
end

return returnthis
