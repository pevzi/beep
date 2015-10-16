local class = require "libs.middleclass"
local Stateful = require "libs.stateful"
local cron = require "libs.cron"

local Flow = class("Flow"):include(Stateful)

function Flow:initialize(chat)
    self.chat = chat
    self.speakers = {}

    self.continues = {}
    self.workers = {}
end

function Flow:getCurrentState()
    return self.__stateStack[#self.__stateStack]
end

function Flow:getCurrentWorker()
    return self.workers[self:getCurrentState()]
end

function Flow:setCurrentWorker(worker)
    self.workers[self:getCurrentState()] = worker
end

function Flow:getCurrentContinue()
    return self.continues[self:getCurrentState()]
end

function Flow:setCurrentContinue(continue)
    self.continues[self:getCurrentState()] = continue
end

function Flow:runCoroutine(body)
    local wrapped = coroutine.wrap(body)

    local function continue()
        self:setCurrentWorker()
        wrapped()
    end

    self:setCurrentContinue(continue)
    continue()
end

function Flow:resumeCoroutine()
    local continue = self:getCurrentContinue()

    if continue then
        local worker = self:getCurrentWorker()

        if not worker then
            continue()
        end

        return true
    end

    return false
end

function Flow:registerSpeaker(id, color, align, pitch)
    self.speakers[id] = {color = color, align = align, pitch = pitch}
end

function Flow:unregisterSpeaker(id)
    self.speakers[id] = nil
end

function Flow:say(id, text, delay)
    if delay then
        self:sleep(delay)
    end

    local speaker = self.speakers[id]
    self.chat:say(text, speaker.color, speaker.align, speaker.pitch)
end

function Flow:sleep(duration)
    local continue = self:getCurrentContinue()

    self:setCurrentWorker(cron.after(duration, continue))

    coroutine.yield()
end

function Flow:update(dt)
    if self.listen then
        self:listen(dt)
    end

    local worker = self:getCurrentWorker()

    if worker then
        worker:update(dt)
    end
end

return Flow
