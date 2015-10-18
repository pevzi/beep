local r = require "resources"
local input = require "input"

local class = require "libs.middleclass"
local flux = require "libs.flux"

local lg = love.graphics

local scrollDuration = 0.5
local scrollEasing = "quadout"
local messageDistance = 15

local pop = r.sources.pop:clone()

local Chat = class("Chat")

function Chat:initialize(l, t, w, h)
    self.x = l
    self.y = t
    self.width = w
    self.height = h

    self.messages = {}
    self.contentHeight = 0
    self.scroll = 0

    self.tweens = flux.group()
end

function Chat:say(text, color, align, pitch)
    local message = {text = text, color = color, align = align, y = self.contentHeight}
    table.insert(self.messages, message)

    local _, lines = r.fonts.main:getWrap(text, self.width)
    local height = lines * r.fonts.main:getHeight()

    self.contentHeight = self.contentHeight + height + messageDistance

    if self.contentHeight > self.height then
        local newScroll = self.height - self.contentHeight
        self.tweens:to(self, scrollDuration, {scroll = newScroll}, scrollEasing)
    end

    local pop = pop:clone()

    if pitch then
        pop:setPitch(pitch)
    end

    pop:play()
end

function Chat:update(dt)
    self.tweens:update(dt)
end

function Chat:draw()
    lg.setScissor(self.x, self.y, self.width, self.height)

    lg.push()

    lg.translate(self.x, self.y + self.scroll)

    for i = #self.messages, 1, -1 do
        local message = self.messages[i]

        lg.setColor(message.color)
        lg.printf(message.text, 0, message.y, self.width, message.align)

        if message.y < self.contentHeight - self.height + self.scroll then
            break
        end
    end

    lg.pop()

    lg.setScissor()
end

return Chat
