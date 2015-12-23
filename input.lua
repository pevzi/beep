local tactile = require "libs.tactile"

local keySpace = tactile.key "space"
local keyEscape = tactile.key "escape"
local keyQ = tactile.key "q"
local keyS = tactile.key "s"
local keyR = tactile.key "r"

local beep = tactile.newButton(keySpace)
local pause = tactile.newButton(keyEscape)
local quit = tactile.newButton(keyQ)
local fast = tactile.newButton(keyS)
local reset = tactile.newButton(keyR)

local function update()
    beep:update()
    pause:update()
    quit:update()
    fast:update()
    reset:update()
end

return {
    update = update,
    beep = beep,
    pause = pause,
    quit = quit,
    fast = fast,
    reset = reset
}
