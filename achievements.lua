local r = require "resources"

local class = require "libs.middleclass"
local flux = require "libs.flux"

local lg = love.graphics
local w = lg.getWidth()
local h = lg.getHeight()

local list = {
    "missed",
    "shy",
    "talker",
    "toy",
    "telegraphist",
    "haha",
    "ew",
    "poweroff",
    "final"
}

local titles = {
    missed = "Упущенные возможности",
    shy = "Скромняша",
    talker = "Болтун",
    toy = "Игрушка",
    telegraphist = ".-. .- -.. .. ... -",
    haha = "Ха-ха",
    ew = "Фи",
    poweroff = "Кина не будет",
    final = "Добро пожаловать домой"
}

local Achievements = class("Achievements")

function Achievements:initialize(height, got)
    self.height = height or h
    self.got = got or {}
    self.y = -self.height

    self.tweens = flux.group()
end

function Achievements:achieve(id)
    if not self.got[id] then
        self.got[id] = true
        return true, titles[id]
    else
        return false, titles[id]
    end
end

function Achievements:isComplete()
    local left = 0

    for _, v in ipairs(list) do
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

        for i, v in ipairs(list) do
            local got = self.got[v]

            lg.setColor(got and r.colors.message or r.colors.messageDark)
            lg.print(("%d: %s"):format(i, got and titles[v] or "???"), 20, i * 40)
        end

        lg.pop()
    end
end

return Achievements
