local tactile = require "libs.tactile"

local keySpace = tactile.key " "
local keyEscape = tactile.key "escape"

local beep = tactile.newButton(keySpace)
local quit = tactile.newButton(keyEscape)

local function update()
    beep:update()
    quit:update()
end

return {
    update = update,
    beep = beep,
    quit = quit
}
