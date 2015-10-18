local input = require "input"

local GameOver = {}

function GameOver:enteredState()
    self.hud:showMessage("[пробел] попробовать еще раз")
end

function GameOver:update(dt)
    if input.beep:pressed() then
        self:gotoState("Play")
    end

    if input.quit:pressed() then
        love.event.quit()
    end

    self.chat:update(dt)
    self.hud:update(dt)
    -- TODO: update achievements here
end

function GameOver:draw()
    self.chat:draw()
    self.hud:draw()
    -- TODO: draw achievements here
end

return GameOver
