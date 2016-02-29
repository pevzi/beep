local r = require "resources"

local class = require "libs.middleclass"
local flux = require "libs.flux"

local lg = love.graphics

local function clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

local HUD = class("HUD")

function HUD:initialize(game, height)
    self.game = game

    self.x = 0
    self.y = lg.getHeight() - height
    self.width = lg.getWidth()
    self.height = height

    self.message = {x = self.width * 0.05, y = self.height, text = ""}
    self.morseBar = 0

    self.tweens = flux.group()
end

function HUD:showMessage(text)
    self.message.text = text
    self.message.y = self.height

    self.tweens:to(self.message, 0.5, {y = self.height * 0.25}):ease("quadout")
            :after(self.message, 0.5, {y = self.height}):ease("quadin"):delay(2)
end

function HUD:update(dt)
    self.tweens:update(dt)
end

function HUD:draw()
    local w = self.width
    local h = self.height

    lg.push()

    lg.translate(self.x, self.y)

    -- message

    lg.setColor(r.colors.message)
    lg.print(self.message.text, self.message.x, self.message.y)

    -- morse

    if self.game.morseReader.value > 0 then
        if self.game.morseReader.value < 1 then
            lg.setColor(r.colors.barDit)
            lg.circle("fill", w * 0.6, h * 0.5, 2)
        else
            lg.setColor(r.colors.barDah)
            lg.setLineWidth(4)
            lg.line(w * 0.6, h * 0.5, w * 0.63, h * 0.5)
        end

        lg.arc("fill", w * 0.5, h * 0.5, h * 0.4, 0, clamp(self.game.morseReader.value, 0, 1) * math.pi * 2)
    end

    -- fast-forward

    if self.game.fast then
        lg.setColor(r.colors.message)

        local x = w * 0.9
        local y = h * 0.5
        local r = self.height * 0.18

        lg.circle("fill", x,           y, r, 3)
        lg.circle("fill", x + r * 1.3, y, r, 3)
    end

    lg.pop()
end

return HUD
