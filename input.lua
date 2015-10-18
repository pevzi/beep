local tactile = require "libs.tactile"

local keySpace = tactile.key " "
local keyEscape = tactile.key "escape"
local keyS = tactile.key "s"
local keyR = tactile.key "r"

local beep = tactile.newButton(keySpace)
local quit = tactile.newButton(keyEscape)
local fast = tactile.newButton(keyS)
local reset = tactile.newButton(keyR)

local function update()
    beep:update()
    quit:update()
    fast:update()
    reset:update()
end

return {
    update = update,
    beep = beep,
    quit = quit,
    fast = fast,
    reset = reset
}
