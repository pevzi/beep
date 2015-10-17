local r = require "resources"
local u = require "useful"
local input = require "input"
local Chat = require "chat"
local Scenario = require "scenario"

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

local chatMargin = w / 15
local lineHeight = h / 15

local beep = r.sources.beep:clone()
beep:setLooping(true)
beep:setPitch(2.3)
beep:setVolume(0.3)

local Play = {}

function Play:enteredState()
    love.graphics.setBackgroundColor(r.colors.background)

    self.chat = Chat(chatMargin, chatMargin, w - chatMargin * 2, h - chatMargin * 2 - lineHeight)
    self.scenario = Scenario(self.chat)
end

function Play:update(dt)
    if input.beep:pressed() then
        beep:play()
    elseif input.beep:released() then
        beep:stop()
    end

    self.chat:update(dt)
    self.scenario:update(dt)
end

function Play:draw()
    self.chat:draw()
end

return Play
