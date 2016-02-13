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

    self.speakers = {}

    self.tweens = flux.group()
end

function Chat:registerSpeaker(id, color, align, pitch)
    self.speakers[id] = {color = color, align = align, pitch = pitch}
end

function Chat:unregisterSpeaker(id)
    self.speakers[id] = nil
end

function Chat:say(id, text)
    local speaker = self.speakers[id]
    self:sayCustom(text, speaker.color, speaker.align, speaker.pitch)
end

function Chat:sayCustom(textstring, color, align, pitch)
    local text = lg.newText(r.fonts.main)
    text:setf(textstring, self.width, align)

    local message = {text = text, color = color, y = self.contentHeight}
    table.insert(self.messages, message)

    self.contentHeight = self.contentHeight + text:getHeight() + messageDistance

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
        lg.draw(message.text, 0, message.y)

        if message.y < self.contentHeight - self.height + self.scroll then
            break
        end
    end

    lg.pop()

    lg.setScissor()
end

return Chat
