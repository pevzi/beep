local input = require "input"
local morse = require "morse"

local class = require "libs.middleclass"

local MorseReader = class("MorseReader")

function MorseReader:initialize(dahThreshold, letterThreshold)
    self.dahThreshold = dahThreshold
    self.letterThreshold = letterThreshold

    self:reset()
end

function MorseReader:update(dt)
    self.duration = self.duration + dt

    if input.beep:pressed() then
        self.duration = 0

    elseif input.beep:released() then
        self.code = self.code .. (self.duration > self.dahThreshold and "-" or ".")
        self.duration = 0
    end

    local letter

    if not input.beep:isDown() and self.code ~= "" and self.duration > self.letterThreshold then
        letter = morse[self.code]
        self.buffer = self.buffer .. letter
        self.code = ""
    end

    local value = input.beep:isDown() and self.duration / self.dahThreshold or 0

    return letter, self.buffer, value
end

function MorseReader:reset()
    self.duration = 0
    self.code = ""
    self.buffer = ""
end

local MultiReader = class("MultiReader")

function MultiReader:initialize(multiThreshold)
    self.multiThreshold = multiThreshold

    self:reset()
end

function MultiReader:update(dt)
    self.duration = self.duration + dt

    if input.beep:pressed() then
        self.beeps = self.beeps + 1
        self.duration = 0

    elseif input.beep:released() then
        self.duration = 0
    end

    if self.duration > self.multiThreshold and self.beeps > 0 then
        local beeps = self.beeps
        self.beeps = 0

        if not input.beep:isDown() then
            return beeps
        end
    end
end

function MultiReader:reset()
    self.duration = 0
    self.beeps = 0
end

return {
    MorseReader = MorseReader,
    MultiReader = MultiReader
}
