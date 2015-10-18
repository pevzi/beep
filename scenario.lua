local r = require "resources"
local readers = require "readers"
local Flow = require "flow"
local input = require "input"

local utf8 = require "utf8"

local multiThreshold = 0.7
local dahThreshold = 0.2
local letterThreshold = 0.2

local multiReader = readers.MultiReader(multiThreshold)
local morseReader = readers.MorseReader(dahThreshold, letterThreshold)

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
    self.noticed = true

    self:runCoroutine(function ()
        self:say(2, "Стой, что это было?", 0.5)
        self:say(1, "В каком смысле?", 1.5)
        self:say(2, "Ты не слышала?", 1.5)
        self:say(2, "Как будто пищало что-то.", 1)
        self:say(1, "Да что тут может пищать?", 2)

        self:gotoState("Alert")
    end)
end

local Alert = {}

function Alert:enteredState()
    self:runCoroutine(function ()
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
        self:sleep(1)

        self.game:achieve(self.noticed and "shy" or "missed")

        self:say(1, "О, а вон там случайно не то самое обещанное дерево?", 4)
        self:say(2, "Где?", 1)
        self:say(1, "В той стороне.", 2)
        self:say(2, "Хм, похоже на то.", 3)
        self:say(2, "Вот, я же тебе говорил, что волноваться не о чем!", 2)
        self:say(1, "Пф.", 1)
        self:say(2, "Пошли быстрей.", 2)

        self:sleep(3)

        self.game:endGame()
    end)
end

local Really = {}

function Really:enteredState()
    self:runCoroutine(function ()
        self:say(1, "Погоди, и правда что-то пищит.", 1)
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
        self:say(2, "Уважаемый робот, если ты нас понимаешь, пикни два раза.", 2)

        -- react to prolonged silence somehow?

        self:gotoState("Twice")
    end)
end

local Twice = {}

function Twice:enteredState()
    self.tries = 0
    self.beeped = false

    self:runCoroutine(function ()
        self:say(1, "Ну да, придумал тоже.", 1.5)
        self:sleep(3)

        if not self.beeped then -- if we beep once and then keep silence they shall react too
            self:say(1, "Видишь, не хочет он с тобой разговаривать.")
            self:say(1, "Пошли дальше.", 1.5)
            self:say(2, "Ну подожди!", 1)

            self:sleep(5)

            -- toy route? or just go away disappointed?
        end
    end)
end

function Twice:listen(dt)
    if not self.beeped and input.beep:isDown() then
        self.beeped = true
    end

    local beeps = multiReader:update(dt)

    if beeps then
        self.tries = self.tries + 1

        if beeps == 2 then
            self:gotoState("Sentient")
        else
            if self.tries < 4 then
                self:say(1, "...")
            else
                self:gotoState("Toy")
            end
        end
    end
end

local Sentient = {}

function Sentient:enteredState()
    self:runCoroutine(function ()
        self:say(2, "Слышала?!")
        self:say(2, "Два раза пикнул!", 1)

        if self.tries == 2 then
            self:say(1, "Ага, со второй попытки.", 2)
            self:say(1, "Похоже на простое совпадение.", 2)
            self:say(2, "Не думаю...", 2)
            self:say(2, "Можно попробовать пообщаться каким-нибудь ещё способом.", 2)

        elseif self.tries > 2 then
            self:say(1, ("Хах, с какой, с %d попытки?"):format(self.tries), 2)
            self:gotoState("Toy")

        else
            self:say(1, "Да слышала я, слышала.", 2)
            self:say(1, "Вероятно, им кто-то управляет по радиосвязи...", 2)
            self:say(1, "В разумных роботов я почему-то не верю.", 2)
            self:say(1, "У него вон две антеннки торчат.", 3)
            self:say(2, "А вдруг с этим роботом связано что-то важное?", 3)
            self:say(2, "Нужно как-то попытаться разузнать, кто он.", 2)
            self:say(1, "...", 1)
            self:say(2, "Только вот как...", 2)
        end

        self:say(2, "О, может, азбукой Морзе?", 2.5)
        self:say(1, "Пф, ты сам-то её знаешь?", 1.5)
        self:say(2, "Обижаешь! Меня отец ей обучал.", 1.5)
        self:say(2, "С год назад...", 1.5)
        self:say(1, "Ну что ж, попробуй.", 2)
        self:say(2, "Кхм-кхм.", 2)
        self:say(2, "Робот, знаешь ли ты азбуку Морзе?", 1.5)

        self:gotoState("Morse")
    end)
end

local Morse = {}

function Morse:enteredState()
    self:runCoroutine(function ()
        morseReader:reset()
    end)
end

function Morse:listen(dt)
    local letter, buffer = morseReader:update(dt)

    -- TODO: make this better-looking?
    self.game.hud.morseBar = input.beep:isDown() and morseReader.duration / morseReader.dahThreshold or 0

    if letter then
        if letter == "" then
            self:say(2, "...")
        else
            self:say(2, ("\"%s\"..."):format(letter))
        end

        if buffer == "да" or buffer == "ага" or buffer == "угу" or buffer == "так" then
            self:gotoState("MorseYes")
        elseif buffer == "нет" or buffer == "неа" then
            self:gotoState("MorseNo")
        elseif buffer == "хуй" then
            self:gotoState("MorseEw")
        elseif utf8.len(buffer) >= 3 then
            self:gotoState("MorseGarbage")
        end
    end
end

local MorseYes = {}

function MorseYes:enteredState()
    self:runCoroutine(function ()
        self:say(2, ("Он сказал \"%s\"!"):format(morseReader.buffer), 1)

        self.game:achieve("telegraphist")
    end)
end

local MorseNo = {}

function MorseNo:enteredState()
    self:runCoroutine(function ()
        self:say(2, ("...%s?"):format(morseReader.buffer), 1)
        self:say(2, "Он сказал азбукой Морзе, что он не знает азбуку Морзе?", 2)

        self.game:achieve("haha")

        self:say(1, ("Ну, может он знает только, как ответить \"%s\"."):format(morseReader.buffer), 2)
        self:say(1, "Или, если им все-таки кто-то управляет, то просто подсмотрел только что.", 3)
        self:say(1, "Если так, то, чувствую, мы тут надолго застрянем.", 3)
    end)
end

local MorseEw = {}

function MorseEw:enteredState()
    self:runCoroutine(function ()
        self:say(2, ("..."):format(morseReader.buffer), 1)
        self:say(1, "Фи, как некультурно!", 1)

        self.game:achieve("ew")

        self:say(1, "Еще и при детях.", 2)
        self:say(2, "Хи-хи-хи.", 1.5)
        self:say(1, "По крайней мере, нам теперь известно, что он знает азбуку Морзе.", 2)
        self:say(1, "Ну, или только это слово.", 2)
    end)
end

local MorseGarbage = {}

function MorseGarbage:enteredState()
    self:runCoroutine(function ()
        self:say(2, ("...%s?"):format(morseReader.buffer), 1)
        self:say(1, "Пф.", 1)
        self:say(2, "Бессмыслица какая-то.", 2)
    end)
end

local Toy = {}

function Toy:enteredState()

end

local Flounder = {}

function Flounder:enteredState()
    self:runCoroutine(function ()
        self:say(2, "Ой, подожди.")
        self:say(1, "Что такое?", 1.5)
        self:say(2, "Да что-то я сбился.", 1.5)
    end)
end

local Scenario = Flow:subclass("Scenario")

function Scenario:initialize(chat)
    Scenario.super.initialize(self, chat)

    self:registerSpeaker(1, r.colors.speaker1, "left")
    self:registerSpeaker(2, r.colors.speaker2, "right", 1.5)

    self:gotoState("Intro")
end

function Scenario:update(dt)
    if input.fast:isDown() then
        dt = dt * 5
    end

    Scenario.super.update(self, dt)
end

Scenario:addState("Intro", Intro)
Scenario:addState("Near", Near)
Scenario:addState("Noticed", Noticed)
Scenario:addState("Alert", Alert)
Scenario:addState("Away", Away)
Scenario:addState("Really", Really)
Scenario:addState("Twice", Twice)
Scenario:addState("Sentient", Sentient)
Scenario:addState("Morse", Morse)
Scenario:addState("MorseYes", MorseYes)
Scenario:addState("MorseNo", MorseNo)
Scenario:addState("MorseEw", MorseEw)
Scenario:addState("MorseGarbage", MorseGarbage)
Scenario:addState("Toy", Toy)
Scenario:addState("Flounder", Flounder)

return Scenario
