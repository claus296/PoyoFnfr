local conductor = {}

function conductor:load(self)
    conductor.bpm = bpm or 120
    conductor.crochet = ((60/conductor.bpm) * 1000) -- Beats in milliseconds
    conductor.stepCrochet = conductor.crochet / 4 -- Steps in milliseconds
    conductor.songPositon = 0 -- Song position in milliseconds
    conductor.lastSongPosition = 0 -- Last song position in milliseconds
    conductor.offset = 0
    conductor.safeZoneOffset = (10 / 60) * 1000

    conductor.lateHitMult =1
    conductor.earlyHitMulti = 1
end

function conductor:update(self, dt)
    self.lastSongPosition = self.songPosition
    self.songPosition = musicTime
end

function conductor:getCrochetAtTime(self, time)
    self.lastChange = getBPMFromSeconds(time)
    return self.lastChange.stepCrochet * 4
end
local function getBPMFromSeconds(time)
    lastChange = {
        stepTime = 0,
        songTime = 0,
        bpm = self.bpm,
        stepCrochet = self.stepCrochet
    }
    for i, change in ipairs(bpmChanges) do
        if time >= self.bpmChangeMap[i].songTime then
            lastChange = self.bpmChangeMap[i]
        end
    end

    return lastChange
end

local function getBPMFromStep(step)
    lastChange = {
        stepTime = 0,
        songTime = 0,
        bpm = self.bpm,
        stepCrochet = self.stepCrochet
    }
    for i, change in ipairs(bpmChanges) do
        if self.bpmChangeMap[i].stepTime <= step then
            lastChange = self.bpmChangeMap[i]
        end
    end

    return lastChange
end

local function beatToSeconds(beat)
    local step = beat * 4
    local lastChange = getBPMFromStep(step)
    return lastChange.songTime + ((step - lastChange.stepTime) / (lastChange.bpm / 60)/4) * 1000
end

local function getStep(time)
    local lastChange = getBPMFromSeconds(time)
    return lastChange.stepTime + (time - lastChange.songTime) / lastChange.stepCrochet
end

local function getStepRounded(time)
    local lastChange = getBPMFromSeconds(time)
    return lastChange.stepTime + math.floor(time - lastChange.songTime) / lastChange.stepCrochet
end

local function getBeat(time)
    return getStep(time) / 4
end

local function getBeatRounded(time)
    return math.floor(getStepRounded(time) / 4)
end

local function getSectionBeats(song, section)
    local val = nil
    if song.sections[section] then
        val = song.sections[section].beats
    end
    return val or 4
end

local function calculateCrochet(bpm)
    return ((60/bpm) * 1000)
end

function conductor:changeBPM(self, newBPM)
    self.bpm = newBPM

    crochet = calculateCrochet(self.bpm)
    stepCrochet = crochet / 4
end

return conductor