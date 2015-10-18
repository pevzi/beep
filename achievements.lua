local r = require "resources"

local class = require "libs.middleclass"
local flux = require "libs.flux"

local lg = love.graphics
local w = lg.getWidth()
local h = lg.getHeight()

local list = {
    "missed",
    "shy",
    "telegraphist",
    "haha",
    "ew"
}

local titles = {
    missed = "Упущенные возможности",
    shy = "Скромняша",
    telegraphist = "Радист",
    haha = "Ха-ха",
    ew = "Фи"
}

local Achievements = class("Achievements")

function Achievements:initialize(height, achieved)
    self.height = height or h
    self.achieved = achieved or {}
    self.y = -self.height

    self.tweens = flux.group()
end

function Achievements:achieve(id)
    if not self.achieved[id] then
        self.achieved[id] = true
        return true, titles[id]
    else
        return false, titles[id]
    end
end

function Achievements:isComplete()
    local complete = true

    for _, v in ipairs(list) do
        if not self.achieved[v] then
            complete = false
            break
        end
    end

    return complete
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

        lg.setColor(r.colors.message)

        for i, v in ipairs(list) do
            lg.print(("%d: %s"):format(i, self.achieved[v] and titles[v] or "???"), 20, i * 40)
        end

        lg.pop()
    end
end

return Achievements
