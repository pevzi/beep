local r = require "resources"
local u = require "useful"
local input = require "input"
local morse = require "morse"
local Chat = require "chat"
local Scenario = require "scenario"

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

local chatMargin = w / 15
local lineHeight = h / 15

local dahThreshold = 0.2
local letterThreshold = 0.2

local beep = r.sources.beep:clone()
beep:setLooping(true)
beep:setPitch(2.3)
beep:setVolume(0.3)

local Play = {}

function Play:enteredState()
    love.graphics.setBackgroundColor(r.colors.background)

    self.lastPressed = 0
    self.lastReleased = 0
    self.duration = 0

    self.code = ""
    self.buffer = ""

    if not self.chat then
        self.chat = Chat(chatMargin, chatMargin, w - chatMargin * 2, h - chatMargin * 2 - lineHeight)
        self.chat:say("Ожидаю код Морзе.", r.colors.speaker2, "right")
    end

    self.scenario = Scenario(self.chat)
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
            self.chat:say(("Прочитана буква \"%s\"."):format(letter), r.colors.speaker2, "right")
        else
            self.chat:say("Неизвестная последовательность сигналов.", r.colors.speaker2, "right")
        end

        self.code = ""
    end

    if input.clear:pressed() then
        self.chat:say(("Очищен буфер: \"%s\"."):format(self.buffer), r.colors.speaker1, "left")
        self.buffer = ""
    end

    self.chat:update(dt)

    self.scenario:update(dt)
end

function Play:draw()
    local threshold = input.beep:isDown() and dahThreshold or letterThreshold

    if self.duration > threshold then
        love.graphics.setColor(r.colors.indicatorDah)
    else
        love.graphics.setColor(r.colors.indicatorDit)
    end

    local lineWidth = u.clamp(self.duration / (threshold * 2) * w, 0, w)
    love.graphics.rectangle("fill", 0, h - lineHeight, lineWidth, h)

    love.graphics.setColor(r.colors.indicatorDit)
    love.graphics.line(w / 2, h - lineHeight, w / 2, h)

    love.graphics.setColor(r.colors.text)
    love.graphics.print(self.buffer)

    self.chat:draw()
end

return Play
