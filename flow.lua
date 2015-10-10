local class = require "libs.middleclass"
local Stateful = require "libs.stateful"
local cron = require "libs.cron"

local function resume(co)
    local ok, msg = coroutine.resume(co)

    if not ok then
        error(msg)
    end
end

local function makeContinue()
    local co = coroutine.running()

    local function continue()
        resume(co)
    end

    return continue, co
end

local Flow = class("Flow"):include(Stateful)

function Flow:initialize(chat)
    self.chat = chat

    self.speakers = {}
    self.timers = {}
end

function Flow:runCoroutine(body)
    local co = coroutine.create(body)
    resume(co)
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
    local continue, co = makeContinue()

    local timer = cron.after(duration, function ()
        self.timers[co] = nil
        continue()
    end)

    self.timers[co] = timer

    coroutine.yield()
end

function Flow:update(dt)
    for _, timer in pairs(self.timers) do
        timer:update(dt)
    end
end

return Flow
