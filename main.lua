setmetatable(_G, {
    __index = function (k) error('referenced an undefined variable', 2) end,
    __newindex = function (k, v) error('new global variables disabled', 2) end
})

local r = require "resources"
local input = require "input"
local Game = require "game"

local game

function love.load()
    love.graphics.setFont(r.fonts.main)

    game = Game()
end

function love.focus(f)
    game:focus(f)
end

function love.update(dt)
    input.update()

    game:update(dt)
end

function love.draw()
    game:draw()
end
