local input = require "input"
local morse = require "morse"

local class = require "libs.middleclass"

local dahThreshold = 0.3
local letterThreshold = 0.6
local multiThreshold = 0.7

local MorseReader = class("MorseReader")

function MorseReader:initialize()
    self:reset()
end

function MorseReader:reset()
    self.value = 0
    self.duration = 0
    self.code = ""
    self.buffer = ""
end

function MorseReader:update(dt)
    self.duration = self.duration + dt

    if input.beep:pressed() then
        self.duration = 0

    elseif input.beep:released() then
        self.code = self.code .. (self.duration > dahThreshold and "-" or ".")
        self.duration = 0
    end

    local letter

    if not input.beep:isDown() and self.code ~= "" and self.duration > letterThreshold then
        letter = morse[self.code] or ""
        self.buffer = self.buffer .. letter
        self.code = ""
    end

    self.value = input.beep:isDown() and self.duration / dahThreshold or 0

    return letter, self.buffer
end

local MultiReader = class("MultiReader")

function MultiReader:initialize()
    self:reset()
end

function MultiReader:reset()
    self.duration = 0
    self.beeps = 0
end

function MultiReader:update(dt)
    self.duration = self.duration + dt

    if input.beep:pressed() then
        self.beeps = self.beeps + 1
        self.duration = 0

    elseif input.beep:released() then
        self.duration = 0
    end

    if self.duration > multiThreshold and self.beeps > 0 then
        local beeps = self.beeps
        self.beeps = 0

        if not input.beep:isDown() then
            return true, beeps
        end
    end

    return false, self.beeps
end

return {
    MorseReader = MorseReader,
    MultiReader = MultiReader
}
