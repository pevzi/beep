local r = require "resources"
local Flow = require "flow"

local Idle = {}

function Idle:enteredState()
    self:runCoroutine(function ()
        self:say(1, "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", 1)
        self:say(2, "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", 2)
        self:say(1, "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", 2)
    end)
end

local Scenario = Flow:subclass("Scenario")

function Scenario:initialize(chat)
    self.class.super.initialize(self, chat)

    self:registerSpeaker(1, r.colors.speaker1, "left", 1.5)
    self:registerSpeaker(2, r.colors.speaker2, "right")

    self:gotoState("Idle")
end

Scenario:addState("Idle", Idle)

return Scenario
