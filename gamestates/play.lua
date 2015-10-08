local r = require "resources"
local input = require "input"
local morse = require "morse"

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

local dahThreshold = 0.2
local letterThreshold = 0.2

local beep = r.sources.beep:clone()
beep:setLooping(true)
beep:setPitch(2.3)
beep:setVolume(0.3)

local pop = r.sources.pop:clone()

local Play = {}

function Play:enteredState()
    self.lastPressed = 0
    self.lastReleased = 0
    self.duration = 0

    self.code = ""
    self.buffer = ""
end

function Play:update(dt)
    if input.beep:pressed() then
        beep:play()
        self.duration = 0

    elseif input.beep:released() then
        beep:stop()
        self.code = self.code .. (self.duration > dahThreshold and "-" or ".")
        self.duration = 0
    end

    self.duration = self.duration + dt

    if not input.beep:isDown() and self.duration > letterThreshold and self.code ~= "" then
        local letter = morse[self.code]
        if letter then
            self.buffer = self.buffer .. letter
        end
        self.code = ""
    end

    if input.clear:pressed() then
        self.buffer = ""
    end
end

function Play:draw()
    love.graphics.setColor(200, 200, 200)
    love.graphics.line(w / 2, 0, w / 2, h)
    love.graphics.print(self.buffer)

    local threshold = input.beep:isDown() and dahThreshold or letterThreshold

    if self.duration > threshold then
        love.graphics.setColor(255, 100, 100)
    else
        love.graphics.setColor(255, 255, 255)
    end

    love.graphics.rectangle("fill", 0, h / 6, self.duration / (threshold * 2) * w, h * 4 / 6)
end

return Play
