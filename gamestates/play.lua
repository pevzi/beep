local r = require "resources"
local u = require "useful"
local input = require "input"
local Chat = require "chat"
local HUD = require "hud"
local Scenario = require "scenario"

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

local chatMargin = w * 0.05
local hudHeight = h * 0.1

local beep = r.sources.beep:clone()
beep:setLooping(true)
beep:setPitch(2.3)
beep:setVolume(0.2)

local Play = {}

function Play:enteredState()
    love.graphics.setBackgroundColor(r.colors.background)

    self.chat = Chat(chatMargin, chatMargin, w - chatMargin * 2, h - chatMargin * 2 - hudHeight)
    self.hud = HUD(0, h - hudHeight, w, hudHeight)
    self.scenario = Scenario(self.chat)

    self.hud:showMessage("[пробел] пищать")
end

function Play:endGame()
    self:gotoState("GameOver")
end

function Play:update(dt)
    if input.beep:pressed() then
        beep:play()
    elseif input.beep:released() then
        beep:stop()
    end

    if input.quit:pressed() then
        self:endGame()
    end

    self.chat:update(dt)
    self.hud:update(dt)
    self.scenario:update(dt)
end

function Play:draw()
    self.chat:draw()
    self.hud:draw()
end

return Play
