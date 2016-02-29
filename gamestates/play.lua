local r = require "resources"
local input = require "input"
local Chat = require "chat"
local HUD = require "hud"
local Scenario = require "scenario"
local Achievements = require "achievements"
local readers = require "readers"

local w = love.graphics.getWidth()
local h = love.graphics.getHeight()

local chatMargin = w * 0.05
local hudHeight = h * 0.1

local beep = r.sources.beep:clone()
beep:setLooping(true)
beep:setPitch(2.3)
beep:setVolume(0.2)

local Play = {}

function Play:enteredState()
    love.graphics.setBackgroundColor(r.colors.background)

    self.morseReader = readers.MorseReader()
    self.multiReader = readers.MultiReader()

    if self.achievements then
        self.achievements:hide()
    else
        self.achievements = Achievements(h - hudHeight)
    end

    self.chat = Chat(chatMargin, chatMargin, w - chatMargin * 2, h - chatMargin * 2 - hudHeight)
    self.hud = HUD(self, hudHeight)
    self.scenario = Scenario(self)

    self.try = (self.try or 0) + 1

    if self.try == 1 then
        self.hud:showMessage("[пробел] пищать")
    elseif self.try == 2 then
        self.hud:showMessage("[s] ускорить текст")
    end

    self.beeping = false
end

function Play:achieve(id)
    local ok, title = self.achievements:achieve(id)

    if ok then
        self.hud:showMessage(("Достижение: %s"):format(title))
    end
end

function Play:exitedState()
    beep:stop()
end

function Play:pausedState()
    beep:stop()
end

function Play:endGame()
    self:gotoState("GameOver")
end

function Play:pauseGame()
    self:pushState("Pause")
end

function Play:focus(f)
    if not f then
        self:pauseGame()
    end
end

function Play:update(dt)
    self.fast = input.fast:isDown()

    if input.beep:pressed() then
        self.beeping = true
    end

    if not input.beep:isDown() or self.fast then
        self.beeping = false
    end

    if self.beeping then
        beep:play()
    else
        beep:stop()
    end

    if input.pause:pressed() then
        self:pauseGame()
    end

    self.chat:update(dt)
    self.hud:update(dt)
    self.scenario:update(self.fast and dt * 10 or dt)
    self.achievements:update(dt)
end

function Play:draw()
    self.chat:draw()
    self.hud:draw()
    self.achievements:draw()
end

return Play
