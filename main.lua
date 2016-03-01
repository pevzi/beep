setmetatable(_G, {
    __index = function (t, k)
        error(("attempt to access an undefined global variable '%s'"):format(k), 2)
    end,

    __newindex = function (t, k, v)
        error(("attempt to assign to an undefined global variable '%s'"):format(k), 2)
    end
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
