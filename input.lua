local tactile = require "libs.tactile"

local keySpace = tactile.key " "
local keyBackspace = tactile.key "backspace"

local beep = tactile.newButton(keySpace)
local clear = tactile.newButton(keyBackspace)

local function update()
    beep:update()
    clear:update()
end

return {
    update = update,
    beep = beep,
    clear = clear
}
