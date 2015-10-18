local r = require "resources"
local u = require "useful"

local class = require "libs.middleclass"
local flux = require "libs.flux"

local lg = love.graphics

local HUD = class("HUD")

function HUD:initialize(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.message = {x = width * 0.05, y = height, text = ""}
    self.morseBar = 0

    self.tweens = flux.group()
end

function HUD:showMessage(text)
    self.message.text = text
    self.tweens:to(self.message, 0.5, {y = self.height * 0.3}):ease("quadout")
            :after(self.message, 1,   {y = self.height}):delay(2)
end

function HUD:update(dt)
    self.tweens:update(dt)
end

function HUD:draw()
    local w = self.width
    local h = self.height

    lg.push()

    lg.translate(self.x, self.y)

    lg.setColor(r.colors.message)
    lg.print(self.message.text, self.message.x, self.message.y)

    if self.morseBar > 0 then
        lg.setLineWidth(4)

        if self.morseBar < 1 then
            lg.setColor(r.colors.barDit)
            lg.circle("fill", w * 0.6, h * 0.5, 2)
        else
            lg.setColor(r.colors.barDah)
            lg.line(w * 0.6, h * 0.5, w * 0.63, h * 0.5)
        end

        lg.arc("fill", w * 0.5, h * 0.5, h * 0.4, 0, u.clamp(self.morseBar, 0, 1) * math.pi * 2)

    end

    lg.pop()
end

return HUD
