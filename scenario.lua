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
        local _, left = self.game.achievements:isComplete()

        if left == 1 then
            self:gotoState("End")
        end

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
    self.beepTime = 0
    self.talker = false

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

        if self.beepTime == 0 then
            self:say(1, "Кстати, что-то он вдруг замолчал.", 2)
        end

        self:say(2, "А вдруг он разумен?!", 2)
        self:say(2, "И слышит всё, что мы говорим.", 1.5)
        self:say(1, "Пф, ты фильмов насмотрелся что ли?", 2)
        self:say(2, "Давай проверим.", 2)
        self:say(2, "Уважаемый робот, если ты нас понимаешь, пикни дважды.", 2)

        self:gotoState("Twice")
    end)
end

function Really:listen(dt)
    if input.beep:isDown() then
        self.beepTime = self.beepTime + dt

        if self.beepTime > 3 and not self.talker then
            self:say(1, "Да надоел уже пищать!")
            self.game:achieve("talker")
            self.talker = true
        end
    end
end

local Twice = {}

function Twice:enteredState()
    self.tries = 0
    self.waiting = 0

    self:runCoroutine(function ()
        self:say(1, "Ну да, придумал тоже.", 1.5)

        self:sleep()

        self:say(1, "Видишь, не хочет он с тобой разговаривать.")
        self:say(1, "Пошли дальше.", 1.5)
        self:say(2, "Ну подожди!", 1)

        self:sleep()

        self:gotoState("Toy")
    end)
end

function Twice:listen(dt)
    self.waiting = self.waiting + dt

    if input.beep:isDown() then
        self.waiting = 0
    elseif self.waiting > 5 then
        self.waiting = 0
        self:resumeCoroutine()
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
            self:say(2, "Ну, можно попробовать пообщаться каким-нибудь ещё способом.", 3)

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
        self:say(2, "Обижаешь! Меня батя ей обучал.", 1.5)
        self:say(2, "С год назад...", 1.5)
        self:say(1, "Ну что ж, попробуй.", 2)
        self:say(2, "Кхм-кхм.", 2)
        self:say(2, "Робот, знаешь ли ты азбуку Морзе?", 1.5)

        self:gotoState("Morse")
    end)
end

local Morse = {}

function Morse:enteredState()
    morseReader:reset()
end

function Morse:listen(dt)
    local letter, buffer, value = morseReader:update(dt)

    self.game.hud.morseBar = value

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

        self:say(1, "Действительно...", 2)
        self:say(2, "Это же замечательно!", 1)
        self:say(2, "Можно узнать, кто он такой и что он тут делает!", 1.5)
        self:say(1, "Теперь уже и мне интересно.", 2)
        self:say(2, "Уважаемый робот, как тебя зовут?", 2)

        self:gotoState("Name")
    end)
end

local MorseNo = {}

function MorseNo:enteredState()
    self:runCoroutine(function ()
        self:say(2, ("...%s?"):format(morseReader.buffer), 1)
        self:say(2, "Он сказал азбукой Морзе, что он не знает азбуку Морзе?", 2)

        self.game:achieve("haha")

        self:say(1, ("Ну, может, он знает только, как ответить \"%s\"."):format(morseReader.buffer), 2)
        self:say(1, "Или, если им всё-таки кто-то управляет, то просто подсмотрел только что.", 3)
        self:say(1, "Если так, то, чувствую, мы тут надолго застрянем.", 3)
        self:say(2, "Я думаю, всё равно стоит попробовать что-нибудь разузнать.", 2)
        self:say(2, "Например...", 2)
        self:say(2, "Робот, как тебя зовут?", 2)

        self:gotoState("Name")
    end)
end

local MorseEw = {}

function MorseEw:enteredState()
    self:runCoroutine(function ()
        self:say(2, "...", 1)
        self:say(1, "Фи, как некультурно!", 1)

        self.game:achieve("ew")

        self:say(1, "Еще и при детях.", 2)
        self:say(2, "Хи-хи-хи.", 1.5)
        self:say(1, "По крайней мере, нам теперь известно, что он знает азбуку Морзе.", 2)
        self:say(1, "Ну, или только это слово.", 2)
        self:say(2, "Можно попробовать дальше.", 2)
        self:say(2, "Например, спросить, как его зовут.", 2)
        self:say(2, "Только это, слышишь, давай в этот раз серьёзно!", 1.5)
        self:say(2, "Как тебя зовут?", 1.5)

        self:gotoState("Name")
    end)
end

local MorseGarbage = {}

function MorseGarbage:enteredState()
    self:runCoroutine(function ()
        self:say(2, ("...%s?"):format(morseReader.buffer), 1)
        self:say(1, "Пф.", 1)
        self:say(2, "Бессмыслица какая-то.", 2)

        self:gotoState("Father")
    end)
end

local Name = {}

function Name:enteredState()
    morseReader:reset()
end

function Name:listen(dt)
    local letter, buffer, value = morseReader:update(dt)

    self.game.hud.morseBar = value

    if letter then
        if utf8.len(buffer) > 3 then
            self:gotoState("Flounder")
        elseif letter == "" then
            self:say(2, "...")
        else
            self:say(2, ("\"%s\"..."):format(letter))
        end

        if buffer == "хуй" then
            self:gotoState("NameEw")
        end
    end
end

local NameEw = {}

function NameEw:enteredState()
    self:runCoroutine(function ()
        if self.game.achievements.got["ew"] then
            self:say(2, "Эй, ну это уже не смешно!", 1)
            self:say(1, "Видимо, он только это слово и знает.", 2)
            self:say(1, "Всё ещё хочешь продолжить общение с ним?", 2)

            self:gotoState("Father")

        else
            self:say(2, "...", 1)
            self:say(1, "Фи, как некультурно!", 1)

            self.game:achieve("ew")

            self:say(1, "Еще и при детях.", 2)
            self:say(2, "Хи-хи-хи, это твоё имя что ли?", 2)
            self:say(2, "Нет, давай еще раз, теперь уже серьёзно.", 2)
            self:say(2, "Как тебя зовут?", 1.5)

            self:gotoState("Name")
        end
    end)
end

local Toy = {}

function Toy:enteredState()
    self:runCoroutine(function ()
        self:say(1, "Что-то мне подсказывает, что это просто тупо игрушка какая-нибудь.", 2)
        self:say(1, "Он нам еще ни разу вразумительно не ответил.", 2)

        self.game:achieve("toy")

        self:say(2, "Ну, не знаю...", 2)
        self:say(1, "С другой стороны, что бы он тогда тут делал, в лесу?", 3)
        self:say(2, "Скорее всего, его сигналы что-то значат, просто мы их не понимаем...", 2)

        self:gotoState("Father")
    end)
end

local Flounder = {}

function Flounder:enteredState()
    self:runCoroutine(function ()
        self:say(2, "Ой, подожди.")
        self:say(1, "Что такое?", 1.5)
        self:say(2, "Да что-то я сбился.", 1.5)
        self:say(1, "Мда, радист из тебя так себе.", 2)

        self:gotoState("Father")
    end)
end

local Father = {}

function Father:enteredState()
    self.beepTime = 0

    self:runCoroutine(function ()
        self:say(2, "О!", 3)
        self:say(2, "У меня идея.", 1)
        self:say(1, "Такая же удачная, как предыдущие?", 2)
        self:say(2, "Бе-бе-бе.", 2)
        self:say(2, "Отнесу я его своему бате!", 2)
        self:say(1, "Ещё чего выдумал!", 1)
        self:say(2, "Не ну, а что?", 2)
        self:say(2, "Он любит всякие странные электронные штуки.", 2)
        self:say(2, "Пусть разберётся, что это за робот такой.", 2)
        -- TODO: ...?
        self:say(1, "Я всё ещё боюсь, что он какой-нибудь опасный.", 3)
        self:say(1, "Принесёшь его домой, а он взорвётся ещё.", 2)
        self:say(2, "Да нечему тут взрываться!", 1.5)
        self:say(2, "Вон, смотри, тут как раз крышка корпуса отвалилась, все внутренности видно.", 2)
        self:say(1, "Эй-эй-эй!", 1)
        self:say(2, "Тут вот только одна плата и всё...", 2)
        self:say(2, "Хм, а вот это похоже на камеру.", 2)
        self:say(2, "Только она, походу, разбилась.", 2)
        self:say(1, "Ну хорошо, пусть даже не взрывается.", 4)
        self:say(1, "Но меня совсем не устраивает, что он за нами будет подслушивать.", 2)

        if self.beepTime > 2 then
            self:say(1, "Он еще и пищит, надоел уже!", 2)
        end

        self:say(2, "А, это можно исправить.", 2)
        self:say(2, "Просто сейчас аккумулятор вытащу.", 3)
        self:say(2, "Вот так...", 3)
        self:say(2, "Хоп!", 1)

        self.game:achieve("poweroff")

        self:sleep(3)

        self.game:endGame()
    end)
end

function Father:listen(dt)
    if input.beep:isDown() then
        self.beepTime = self.beepTime + dt
    end
end

local End = {}

function End:enteredState()
    self.beepTime = 0

    self:runCoroutine(function ()
        self:say(1, "Если верить радару, то он где-то неподалеку.", 2)
        self:say(2, "И угораздило же его сюда свалиться...", 2)
        self:say(1, "Скажи спасибо, что не в океан куда-нибудь.", 2)
        self:say(2, "О, вот же он!", 3)
        self:say(1, "Ох, как беднягу помяло-то...", 2)
        self:say(1, "И камера разбилась.", 2)

        if self.beepTime > 1 then
            self:say(1, "Ну, судя по писку, электроника вроде бы в порядке.", 2)
            self:say(1, "И даже аккумулятор еще не сел.", 2)
        end

        self:say(1, "Что ж, дружище, пойдём домой?", 2)
        self:say(2, "Хм, а как вы считаете, его кто-нибудь уже находил?", 3)
        self:say(1, "Ты имеешь в виду, не в этот раз?", 2)
        self:say(2, "Ну, в том числе, да.", 2)
        self:say(1, "Конечно.", 1.5)
        self:say(1, "Все, что могло произойти, обязательно когда-то произошло.", 2)
        self:say(1, "Пусть и не в этот раз.", 1.5)
        self:say(2, "Думаете, кто-то мог именно сегодня забраться так глубоко в этот лес?", 2)
        self:say(1, "Не исключаю такой возможности.", 2)
        self:say(1, "К тому же...", 3)
        self:say(1, "Вон, гляди.", 1)
        self:say(1, "Как раз какие-то ребятишки идут.", 2)
        self:say(2, "Походу, они нас напугались...", 2)
        self:say(2, "Развернулись и обратно пошли.", 2)
        self:say(1, "Хех, я бы на их месте сам напугался.", 2)
        self:say(1, "Вот видишь, а если б ты перед нашим походом все-таки решил заскочить к своей ненаглядной, то мы могли бы и не успеть.", 4)
        self:say(2, "И то верно.", 4)

        self:sleep(1)

        self.game:achieve("final")

        self:sleep(3)

        self.game:endGame()
    end)
end

function End:listen(dt)
    if input.beep:isDown() then
        self.beepTime = self.beepTime + dt
    end
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
Scenario:addState("Name", Name)
Scenario:addState("NameEw", NameEw)
Scenario:addState("Toy", Toy)
Scenario:addState("Flounder", Flounder)
Scenario:addState("Father", Father)
Scenario:addState("End", End)

return Scenario
