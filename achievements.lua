local r = require "resources"

local class = require "libs.middleclass"
local flux = require "libs.flux"

local lg = love.graphics
local w = lg.getWidth()
local h = lg.getHeight()

local Achievements = class("Achievements")

function Achievements:initialize(height)
    self.height = height or h
    self.y = -self.height
    self.got = {}

    self:load()

    self.tweens = flux.group()
end

function Achievements:setList(list, titles)
    self.list = list
    self.titles = titles
end

function Achievements:load()
    local file = love.filesystem.newFile("achievements", "r")

    if file then
        for line in file:lines() do
            self.got[line] = true
        end

        file:close()
    end
end

function Achievements:save()
    local file = love.filesystem.newFile("achievements", "w")

    if file then
        for k in pairs(self.got) do
            file:write(k .. "\n")
        end

        file:close()
    end
end

function Achievements:clear()
    love.filesystem.remove("achievements")
    self.got = {}
end

function Achievements:achieve(id)
    if not self.got[id] then
        self.got[id] = true
        self:save()
        return true, self.titles[id]
    else
        return false, self.titles[id]
    end
end

function Achievements:isComplete()
    local left = 0

    for _, v in ipairs(self.list) do
        if not self.got[v] then
            left = left + 1
        end
    end

    return left == 0, left
end

function Achievements:show()
    self.tweens:to(self, 0.7, {y = 0}):ease("quadinout")
end

function Achievements:hide()
    self.tweens:to(self, 0.7, {y = -self.height}):ease("quadinout")
end

function Achievements:update(dt)
    self.tweens:update(dt)
end

function Achievements:draw()
    if self.y > -self.height then
        lg.push()

        lg.translate(0, self.y)

        lg.setColor(r.colors.achievementsBackground)
        lg.rectangle("fill", 0, 0, w, self.height)

        for i, v in ipairs(self.list) do
            local got = self.got[v]

            lg.setColor(got and r.colors.message or r.colors.messageDark)
            lg.print(("%d: %s"):format(i, got and self.titles[v] or "???"), 20, i * 50)
        end

        lg.pop()
    end
end

return Achievements
