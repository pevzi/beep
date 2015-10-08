local r = require "resources"
local input = require "input"

local class = require "libs.middleclass"
local flux = require "libs.flux"

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

function Chat:say(text, color, align)
    local message = {text = text, color = color, align = align, y = self.contentHeight}
    table.insert(self.messages, message)

    local _, lines = r.fonts.main:getWrap(text, self.width)
    local height = lines * r.fonts.main:getHeight()

    self.contentHeight = self.contentHeight + height + messageDistance

    if self.contentHeight > self.height then
        local newScroll = self.height - self.contentHeight
        self.tweens:to(self, scrollDuration, {scroll = newScroll}, scrollEasing)
    end

    pop:clone():play()
end

function Chat:update(dt)
    self.tweens:update(dt)
end

function Chat:draw()
    love.graphics.setScissor(self.x, self.y, self.width, self.height)

    love.graphics.push()

        love.graphics.translate(self.x, self.y + self.scroll)

        for i = #self.messages, 1, -1 do
            local message = self.messages[i]

            love.graphics.setColor(message.color)
            love.graphics.printf(message.text, 0, message.y, self.width, message.align)

            if message.y < self.contentHeight - self.height + self.scroll then
                break
            end
        end

    love.graphics.pop()

    love.graphics.setScissor()
end

return Chat
