local input = require "input"

local GameOver = {}

function GameOver:enteredState(final)
    self.achievements:show()

    local message

    if self.achievements:isComplete() then
        if final then
            message = "Спасибо за игру. [R] начать заново"
        else
            message = "[R] начать заново"
        end
    else
        message = "[пробел] попробовать ещё раз"
    end

    self.hud:showMessage(message)
end

function GameOver:update(dt)
    if input.beep:pressed() then
        self:gotoState("Play")
    end

    if input.reset:pressed() and self.achievements:isComplete() then
        self.achievements:clear()
        self:gotoState("Play")
    end

    if input.pause:pressed() or input.quit:pressed() then
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
