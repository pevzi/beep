local class = require "libs.middleclass"
local Stateful = require "libs.stateful"
local cron = require "libs.cron"

local Flow = class("Flow"):include(Stateful)

function Flow:initialize(game)
    self.game = game
    self.speakers = {} -- TODO: move speaker registration to Chat

    self.continues = {}
    self.workers = {}
end

local orig_gotoState = Flow.gotoState

function Flow:gotoState(stateName, ...)
    self.currentState = stateName

    orig_gotoState(self, stateName, ...)

    if coroutine.running() then
        coroutine.yield() -- TODO: probably not the brightest idea
    end
end

function Flow:getCurrentWorker()
    return self.workers[self.currentState]
end

function Flow:setCurrentWorker(worker)
    self.workers[self.currentState] = worker
end

function Flow:getCurrentContinue()
    return self.continues[self.currentState]
end

function Flow:setCurrentContinue(continue)
    self.continues[self.currentState] = continue
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
    self.game.chat:say(text, speaker.color, speaker.align, speaker.pitch)
end

function Flow:sleep(duration)
    assert(coroutine.running(), "cannot sleep outside a coroutine")

    if duration then
        local continue = self:getCurrentContinue()
        self:setCurrentWorker(cron.after(duration, continue))
    end

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
