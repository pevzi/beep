local r = require "resources"
local Flow = require "flow"
local input = require "input"

local Intro = {}

function Intro:enteredState()
    self:runCoroutine(function ()
        self:say(1, "...вот я же говорила, что не надо было нам заходить так глубоко в этот лес!", 1)
        self:say(2, "Да не паникуй ты, всё под контролем.", 2)
        self:say(2, "Сейчас заберёмся вон на тот холмик, и там за ним будет поваленное дерево.", 3)
        self:say(2, "Вроде.", 2)
        self:say(1, "Угу, очень обнадёживающе.", 2)

        self:gotoState("Near")
    end)
end

local Near = {}

function Near:enteredState()
    self:runCoroutine(function ()
        self:say(1, "Хоть компас бы с собой взял.", 4)
        self:say(1, "Путешественник, блин.", 2)
        self:say(2, "Да ладно тебе уже.", 1)
        self:say(2, "Зато смотри, как тут живописно!", 3)
        self:say(1, "Обычный лес, ничего особенного.", 2)
        self:say(2, "Ничего ты не понимаешь.", 2)
        self:say(1, "Ну да, куда уж мне.", 2)

        self:gotoState("Away")
    end)
end

function Near:listen(dt)
    if input.beep:isDown() then
        self:gotoState("Noticed")
    end
end

local Noticed = {}

function Noticed:enteredState()
    self:runCoroutine(function ()
        self:say(2, "Стой, что это было?", 0.5)
        self:say(1, "В каком смысле?", 1.5)
        self:say(2, "Ты не слышала?", 1.5)
        self:say(2, "Как будто пищало что-то.", 1)

        self:gotoState("Alert")
    end)
end

local Alert = {}

function Alert:enteredState()
    self:runCoroutine(function ()
        self:say(1, "Да что тут может пищать?", 3)
        self:say(1, "У тебя глюки просто.", 2)
        self:say(2, "Может, действительно показалось...", 3)
        self:say(2, "Ладно, пошли дальше.", 3)

        self:gotoState("Away")
    end)
end

function Alert:listen(dt)
    if input.beep:isDown() then
        self:gotoState("Really")
    end
end

local Away = {}

function Away:enteredState()
    self:runCoroutine(function ()
        self:say(1, "О, а вон там случайно не то самое обещанное дерево?", 5)
        self:say(2, "Где?", 1)
        self:say(1, "В той стороне.", 2)
        self:say(2, "Хм, похоже на то.", 3)
        self:say(2, "Вот, я же тебе говорил, что волноваться не о чем!", 2)
        self:say(1, "Пф.", 1)
        self:say(2, "Пошли быстрей.", 2)

        self:sleep(3)

        -- give an achievement
        -- end the game
    end)
end

local Really = {}

function Really:enteredState()
    self:runCoroutine(function ()
        self:say(1, "Погоди, и правда что-то пищит.", 0.5)
        self:say(2, "Сказал же.", 1.5)
        self:say(1, "Что это может быть вообще, в такой-то глуши?", 2.5)
        self:say(2, "Понятия не имею...", 2)
        self:say(2, "Звук вроде оттуда.", 2)
        self:say(1, "Эй, ты куда?", 1.5)
        self:say(1, "Собрался искать источник звука, что ли?", 1.5)
        self:say(2, "Конечно!", 1)
        self:say(1, "Я бы на твоём месте наоборот подальше от него держалась.", 2.5)
        self:say(1, "Да и на своём...", 1.5)
        self:say(2, "Да всё нормально!", 1)
        self:say(2, "Я его уже нашел.", 1.5)
        self:say(2, "Железяка какая-то...", 1)
        self:say(2, "Иди сюда, глянь.", 1.5)
        self:say(1, "Ты это, осторожнее там!", 1.5)
        self:say(1, "Мало ли, вдруг это бомба какая-нибудь.", 2)
        self:say(2, "Да ну, не похоже.", 2)
        self:say(1, "Бомбы как раз таки обычно не похожи на бомбы...", 2)
        self:say(2, "Выглядит как... робот.", 3)
        self:say(2, "Только весь покорёженный.", 2)
        self:say(2, "Как будто с большой высоты упал.", 2)
        self:say(1, "Хм, и правда...", 3)
        self:say(2, "А вдруг он разумен?!", 2)
        self:say(2, "И слышит всё, что мы говорим.", 1.5)
        self:say(1, "Пф, насмотрелся фильмов что ли?", 2)
        self:say(2, "Давай проверим.", 2)
        self:say(2, "Робот, если ты нас понимаешь, пикни два раза.", 2)

        -- react to prolonged silence somehow?

        self:gotoState("Twice")
    end)
end

local Twice = {}

function Twice:enteredState()
    self:runCoroutine(function ()
        self:say(1, "Ну да, придумал тоже.", 3)
    end)
end

function Twice:listen(dt)

end

local Scenario = Flow:subclass("Scenario")

function Scenario:initialize(chat)
    Scenario.super.initialize(self, chat)

    self:registerSpeaker(1, r.colors.speaker1, "left")
    self:registerSpeaker(2, r.colors.speaker2, "right", 1.5)

    self:gotoState("Intro")
end

Scenario:addState("Intro", Intro)
Scenario:addState("Near", Near)
Scenario:addState("Noticed", Noticed)
Scenario:addState("Alert", Alert)
Scenario:addState("Away", Away)
Scenario:addState("Really", Really)
Scenario:addState("Twice", Twice)

return Scenario
