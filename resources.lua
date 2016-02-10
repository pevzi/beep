local fonts = {
    main = love.graphics.newFont("fonts/PTS75F.ttf", 20)
}

local sources = {
    beep = love.audio.newSource("sounds/beep.ogg", "static"),
    pop = love.audio.newSource("sounds/pop.ogg", "static")
}

local colors = {
    speaker1 = {82, 119, 68},
    speaker2 = {116, 120, 68},
    background = {30, 36, 21},
    message = {116, 120, 68},
    messageDark = {54, 79, 45},
    barDit = {208, 208, 208},
    barDah = {135, 164, 103},
    achievementsBackground = {15, 18, 10},
}

return {
    fonts = fonts,
    sources = sources,
    colors = colors
}
