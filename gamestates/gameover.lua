local input = require "input"

local GameOver = {}

function GameOver:enteredState()
    self.achievements:show()
    self.hud:showMessage(self.achievements:isComplete() and "Спасибо за игру." or "[пробел] попробовать еще раз")
end

function GameOver:update(dt)
    if input.beep:pressed() then
        if self.achievements:isComplete() then
            love.event.quit()
        else
            self:gotoState("Play")
        end
    end

    if input.quit:pressed() then
        love.event.quit()
    end

    self.chat:update(dt)
    self.hud:update(dt)
    self.achievements:update(dt)
end

function GameOver:draw()
    self.chat:draw()
    self.hud:draw()
    self.achievements:draw()
end

return GameOver
