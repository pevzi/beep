local Play = require "gamestates.play"
local GameOver = require "gamestates.gameover"
local Pause = require "gamestates.pause"

local class = require "libs.middleclass"
local Stateful = require "libs.stateful"

local Game = class("Game"):include(Stateful)

function Game:initialize()
    self:gotoState("Play")
end

Game:addState("Play", Play)
Game:addState("GameOver", GameOver)
Game:addState("Pause", Pause)

return Game
