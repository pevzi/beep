local class = require "libs.middleclass"
local Stateful = require "libs.stateful"

local r = require "resources"
local readers = require "readers"
local input = require "input"

local utf8 = require "utf8"

local multiThreshold = 0.7
local dahThreshold = 0.3
local letterThreshold = 0.6

local multiReader = readers.MultiReader(multiThreshold)
local morseReader = readers.MorseReader(dahThreshold, letterThreshold)

local initialState = "Intro"

local Scenario = class("Scenario"):include(Stateful)

------------------------------------------

local Intro = Scenario:addState("Intro")

function Intro:act()
    local _, left = self.game.achievements:isComplete()

    if left == 1 then
        self:runState("End")
    end

    self:say(1, "...вот я же говорила, что не надо было нам заходить так глубоко в этот лес!", 1)
    self:say(2, "Да не паникуй ты, всё под контролем.", 2)
    self:say(2, "Сейчас заберёмся вон на тот холмик, и там за ним будет поваленное дерево.", 3)
    self:say(2, "Вроде.", 2)
    self:say(1, "Угу, очень обнадёживающе.", 2)

    self:runState("Near")
end

local Near = Scenario:addState("Near")

function Near:act()
    self:say(1, "Хоть компас бы с собой взял.", 4)
    self:say(1, "Путешественник, блин.", 2)
    self:say(2, "Да ладно тебе уже.", 1)
    self:say(2, "Зато смотри, как тут живописно!", 3)
    self:say(1, "Обычный лес, ничего особенного.", 2)
    self:say(2, "Ничего ты не понимаешь.", 2)
    self:say(1, "Ну да, куда уж мне.", 2)

    self:runState("Away")
end

function Near:listen(dt)
    if self.game.beeping then
        self:runState("Noticed")
    end
end

local Noticed = Scenario:addState("Noticed")

function Noticed:act()
    self.noticed = true

    self:say(2, "Стой, что это было?", 0.5)
    self:say(1, "В каком смысле?", 1.5)
    self:say(2, "Ты не слышала?", 1.5)
    self:say(2, "Как будто пищало что-то.", 1)
    self:say(1, "Да что тут может пищать?", 2)

    self:runState("Alert")
end

local Alert = Scenario:addState("Alert")

function Alert:act()
    self:say(1, "У тебя глюки просто.", 2)
    self:say(2, "Может, действительно показалось...", 3)
    self:say(2, "Ладно, пошли дальше.", 3)

    self:runState("Away")
end

function Alert:listen(dt)
    if self.game.beeping then
        self:runState("Really")
    end
end

local Away = Scenario:addState("Away")

function Away:act()
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
end

local Really = Scenario:addState("Really")

function Really:act()
    self.beepTime = 0
    self.talker = false

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
    self:say(2, "Я его уже нашёл.", 1.5)
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
    self:say(1, "Пф, ты фильмов пересмотрел, что ли?", 2)
    self:say(2, "Давай проверим.", 2)
    self:say(2, "Уважаемый робот, если ты нас понимаешь, пикни дважды.", 2)

    self:runState("Twice")
end

function Really:listen(dt)
    if self.game.beeping then
        self.beepTime = self.beepTime + dt

        if self.beepTime > 4 and not self.talker then
            self:say(1, "Да надоел уже пищать!")
            self.game:achieve("talker")
            self.talker = true
        end
    end
end

local Twice = Scenario:addState("Twice")

function Twice:act()
    self.tries = 0
    self.waiting = 0

    self:say(1, "Ну да, придумал тоже.", 1.5)

    self:sleep(5)

    self:say(1, "Видишь, не хочет он с тобой разговаривать.")
    self:say(1, "Пошли дальше.", 1.5)
    self:say(2, "Ну подожди!", 1)

    self:sleep(5)

    self:runState("Toy")
end

function Twice:listen(dt)
    if self.game.beeping then
        self.timer:set(5)
    end

    local beeps = multiReader:update(dt)

    if beeps then
        self.tries = self.tries + 1

        if beeps == 2 then
            self:runState("Sentient")
        else
            if self.tries < 4 then
                self:say(1, "...")
            else
                self:runState("Toy")
            end
        end
    end
end

local Sentient = Scenario:addState("Sentient")

function Sentient:act()
    self:say(2, "Слышала?!")
    self:say(2, "Два раза пикнул!", 1)

    if self.tries == 2 then
        self:say(1, "Ага, со второй попытки.", 2)
        self:say(1, "Похоже на простое совпадение.", 2)
        self:say(2, "Ну, можно попробовать пообщаться каким-нибудь ещё способом.", 3)

    elseif self.tries > 2 then
        self:say(1, ("Хах, с какой, с %d попытки?"):format(self.tries), 2)
        self:runState("Toy")

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

    self:runState("Morse")
end

local Morse = Scenario:addState("Morse")

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
            self:runState("MorseYes")
        elseif buffer == "нет" or buffer == "неа" then
            self:runState("MorseNo")
        elseif utf8.len(buffer) >= 3 then
            self:runState("MorseGarbage")
        end
    end
end

local MorseYes = Scenario:addState("MorseYes")

function MorseYes:act()
    self:say(2, ("Он сказал \"%s\"!"):format(morseReader.buffer), 1)

    self.game:achieve("telegraphist")

    self:say(1, "Действительно...", 2)
    self:say(2, "Это же замечательно!", 1)
    self:say(2, "Можно узнать, кто он такой и что он тут делает!", 1.5)
    self:say(1, "Теперь уже и мне интересно.", 2)
    self:say(2, "Уважаемый робот, как тебя зовут?", 2)

    self:runState("Name")
end

local MorseNo = Scenario:addState("MorseNo")

function MorseNo:act()
    self:say(2, ("...%s?"):format(morseReader.buffer), 1)
    self:say(2, "Он сказал азбукой Морзе, что он не знает азбуку Морзе?", 2)

    self.game:achieve("haha")

    self:say(1, ("Ну, может, он знает только, как ответить \"%s\"."):format(morseReader.buffer), 2)
    self:say(1, "Или, если им всё-таки кто-то управляет, то просто подсмотрел только что.", 3)
    self:say(1, "Если так, то, чувствую, мы тут надолго застрянем.", 3)
    self:say(2, "Я думаю, всё равно стоит попробовать что-нибудь разузнать.", 2)
    self:say(2, "Например...", 2)
    self:say(2, "Робот, как тебя зовут?", 2)

    self:runState("Name")
end

local MorseGarbage = Scenario:addState("MorseGarbage")

function MorseGarbage:act()
    self:say(2, ("...%s?"):format(morseReader.buffer), 1)
    self:say(1, "Пф.", 1)
    self:say(2, "Бессмыслица какая-то.", 2)

    self:runState("Father")
end

local Name = Scenario:addState("Name")

function Name:enteredState()
    morseReader:reset()
end

function Name:listen(dt)
    local letter, buffer, value = morseReader:update(dt)

    self.game.hud.morseBar = value

    if letter then
        if utf8.len(buffer) > 3 then
            self:runState("Flounder")
        elseif letter == "" then
            self:say(2, "...")
        else
            self:say(2, ("\"%s\"..."):format(letter))
        end
    end
end

local Toy = Scenario:addState("Toy")

function Toy:act()
    self:say(1, "Что-то мне подсказывает, что это просто тупо игрушка какая-нибудь.", 2)
    self:say(1, "Он нам ещё ни разу вразумительно не ответил.", 2)

    self.game:achieve("toy")

    self:say(2, "Ну, не знаю...", 2)
    self:say(1, "С другой стороны, что бы он тогда тут делал, в лесу?", 3)
    self:say(2, "Скорее всего, его сигналы что-то значат, просто мы их не понимаем...", 2)

    self:runState("Father")
end

local Flounder = Scenario:addState("Flounder")

function Flounder:act()
    self:say(2, "Ой, подожди.")
    self:say(1, "Что такое?", 1.5)
    self:say(2, "Да что-то я сбился.", 1.5)
    self:say(1, "Мда, радист из тебя так себе.", 2)

    self:runState("Father")
end

local Father = Scenario:addState("Father")

function Father:act()
    self.beepTime = 0

    self:say(2, "О!", 3)
    self:say(2, "У меня идея.", 1)
    self:say(1, "Такая же удачная, как предыдущие?", 2)
    self:say(2, "Бе-бе-бе.", 2)
    self:say(2, "Отнесу я его своему бате!", 2)
    self:say(1, "Ещё чего выдумал!", 1)
    self:say(2, "Не, ну а что?", 2)
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
        self:say(1, "Он ещё и пищит, надоел уже!", 2)
    end

    self:say(2, "А, это можно исправить.", 2)
    self:say(2, "Просто сейчас аккумулятор вытащу.", 3)
    self:say(2, "Вот так...", 3)
    self:say(2, "Хоп!", 1)

    self.game:achieve("poweroff")

    self:sleep(3)

    self.game:endGame()
end

function Father:listen(dt)
    if self.game.beeping then
        self.beepTime = self.beepTime + dt
    end
end

local End = Scenario:addState("End")

function End:act()
    self.beepTime = 0

    self:say(1, "Если верить радару, то он где-то неподалёку.", 2)
    self:say(2, "И угораздило же его сюда свалиться...", 2)
    self:say(1, "Скажи спасибо, что не в океан куда-нибудь.", 2)
    self:say(2, "О, вот же он!", 3)
    self:say(1, "Ох, как беднягу помяло-то...", 2)
    self:say(1, "И камера разбилась.", 2)

    if self.beepTime > 1 then
        self:say(1, "Ну, судя по писку, электроника вроде бы в порядке.", 2)
        self:say(1, "И даже аккумулятор ещё не сел.", 2)
    end

    self:say(1, "Что ж, дружище, пойдём домой?", 2)
    self:say(2, "Хм, а как вы считаете, его кто-нибудь уже находил?", 3)
    self:say(1, "Ты имеешь в виду, не в этот раз?", 2)
    self:say(2, "Ну, в том числе, да.", 2)
    self:say(1, "Конечно.", 1.5)
    self:say(1, "Всё, что могло произойти, обязательно когда-то произошло.", 2)
    self:say(1, "Пусть и не в этот раз.", 1.5)
    self:say(2, "Думаете, кто-то мог именно сегодня забраться так глубоко в этот лес?", 2)
    self:say(1, "Не исключаю такой возможности.", 2)
    self:say(1, "К тому же...", 3)
    self:say(1, "Вон, гляди.", 1)
    self:say(1, "Как раз какие-то ребятишки идут.", 2)
    self:say(2, "Походу, они нас напугались...", 2)
    self:say(2, "Развернулись и обратно пошли.", 2)
    self:say(1, "Хех, я бы на их месте сам напугался.", 2)
    self:say(1, "Вот видишь, а если б ты перед нашим походом всё-таки решил заскочить к своей ненаглядной, то мы могли бы и не успеть.", 4)
    self:say(2, "И то верно.", 4)

    self:sleep(1)

    self.game:achieve("final")

    self:sleep(3)

    self.game:endGame()
end

function End:listen(dt)
    if self.game.beeping then
        self.beepTime = self.beepTime + dt
    end
end

------------------------------------------

local achievementList = {
    "missed",
    "shy",
    "talker",
    "toy",
    "telegraphist",
    "haha",
    "poweroff",
    "final"
}

local achievementTitles = {
    missed = "Упущенные возможности",
    shy = "Скромняша",
    talker = "Болтун",
    toy = "Игрушка",
    telegraphist = ".-. .- -.. .. ... -",
    haha = "Ха-ха",
    poweroff = "Кина не будет",
    final = "Добро пожаловать домой"
}

------------------------------------------

local function resume(co, ...)
    local ok, msg = coroutine.resume(co, ...)

    if not ok then
        error(msg)
    end
end

local Timer = class("Timer")

function Timer:initialize(t)
    self.t = t or 0
end

function Timer:set(t)
    self.t = t
end

function Timer:update(dt)
    self.t = self.t - dt
    return self.t <= 0
end

function Scenario:initialize(game)
    self.game = game

    self.game.chat:registerSpeaker(1, r.colors.speaker1, "left")
    self.game.chat:registerSpeaker(2, r.colors.speaker2, "right", 1.5)

    self.game.achievements:setList(achievementList, achievementTitles)

    self.timer = Timer()

    self:runState(initialState)
end

function Scenario:runState(stateName, ...)
    self:gotoState(stateName, ...)

    if self.act then
        if self.co and coroutine.running() == self.co then
            self:act(...)
        else
            self.co = coroutine.create(self.act)
            resume(self.co, self, ...)
        end
    end
end

function Scenario:wait(worker)
    self.worker = worker
    coroutine.yield()
end

function Scenario:sleep(duration)
    if duration then
        self.timer:set(duration)
        self:wait(self.timer)
    else
        self:wait()
    end
end

function Scenario:say(id, text, delay)
    if delay then
        self:sleep(delay)
    end

    self.game.chat:say(id, text)
end

function Scenario:update(dt)
    if self.worker and self.worker:update(dt) then
        self.worker = nil
        resume(self.co)
    end

    if self.listen then
        self:listen(dt)
    end
end

return Scenario
