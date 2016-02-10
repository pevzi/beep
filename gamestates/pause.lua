local flux = require "libs.flux"
local class = require "libs.middleclass"

local input = require "input"
local r = require "resources"

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

local height = r.fonts.main:getHeight() * 3

local text = {r.colors.speaker1, "Пауза\n", r.colors.speaker2, "[esc] продолжить\n[q] выход"}
local x = 0
local y = h / 2 - height / 2
local width = w
local align = "center"

local padding = height / 2

local duration = 0.2

local PauseWindow = class("PauseWindow")

function PauseWindow:initialize()
    self.tweens = flux.group()

    self.x = x
    self.y = h / 2
    self.width = width
    self.height = 0

    self.alpha = 0
end

function PauseWindow:open()
    return self.tweens:to(self, duration, {y = h / 2 - height / 2 - padding,
                                           height = height + padding * 2,
                                           alpha = 150}
    ):ease("quadout")
end

function PauseWindow:close()
    return self.tweens:to(self, duration, {y = h / 2,
                                           height = 0,
                                           alpha = 0}
    ):ease("quadout")
end

function PauseWindow:update(dt)
    self.tweens:update(dt)
end

function PauseWindow:draw()
    love.graphics.setColor(0, 0, 0, self.alpha)
    love.graphics.rectangle("fill", 0, 0, w, h)

    love.graphics.setColor(255, 255, 255)
    love.graphics.setScissor(self.x, self.y, self.width, self.height)

        love.graphics.setColor(r.colors.background)
        love.graphics.rectangle("fill", 0, 0, w, h)

        love.graphics.setColor(255, 255, 255)
        love.graphics.printf(text, x, y, width, align)

    love.graphics.setScissor()
end

local Pause = {}

function Pause:enteredState()
    self.pauseWindow = PauseWindow()
    self.pauseWindow:open()
end

function Pause:focus(f)
    -- overriding the Play's focus callback so that it doesn't push another Pause state
end

function Pause:update(dt)
    if input.pause:pressed() then
        self.pauseWindow:close():oncomplete(function () self:popState() end)
    elseif input.quit:pressed() then
        self.pauseWindow:close():oncomplete(function () self:gotoState("GameOver") end)
    end

    self.pauseWindow:update(dt)
end

function Pause:draw()
    self.chat:draw()
    self.hud:draw()
    self.achievements:draw()
    self.pauseWindow:draw()
end

return Pause
