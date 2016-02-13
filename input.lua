local tactile = require "libs.tactile"

local actions = {
    beep = tactile.newButton(tactile.key "space"),
    pause = tactile.newButton(tactile.key "escape"),
    quit = tactile.newButton(tactile.key "q"),
    fast = tactile.newButton(tactile.key "s"),
    reset = tactile.newButton(tactile.key "r")
}

local function update()
    for _, action in pairs(actions) do
        action:update()
    end
end

return setmetatable({
    update = update,
    actions = actions
}, {__index = actions})
