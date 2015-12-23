local input = require "input"
local r = require "resources"

local height = r.fonts.main:getHeight() * 3

local text = {r.colors.speaker1, "Пауза\n", r.colors.speaker2, "[esc] продолжить\n[q] выход"}
local x = 0
local y = love.graphics.getHeight() / 2 - height / 2
local width = love.graphics.getWidth()
local align = "center"

local padding = height / 2

local rectx = x
local recty = y - padding
local rectwidth = width
local rectheight = height + padding * 2

local Pause = {}

function Pause:focus(f)
    -- overriding the Play's focus callback so that it doesn't push another Pause state
end

function Pause:update(dt)
    if input.pause:pressed() then
        self:popState()
    elseif input.quit:pressed() then
        self:gotoState("GameOver")
    end
end

function Pause:draw()
    self.chat:draw()
    self.hud:draw()
    self.achievements:draw()

    love.graphics.setColor(r.colors.pauseOverlay)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(r.colors.background)
    love.graphics.rectangle("fill", rectx, recty, rectwidth, rectheight)

    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(text, x, y, width, align)
end

return Pause
