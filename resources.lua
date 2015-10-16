local images = {

}

for k, v in pairs(images) do
    images[k] = love.graphics.newImage("images/"..v)
end

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
    text = {208, 208, 208},
    indicatorDit = {208, 208, 208},
    indicatorDah = {135, 164, 103}
}

return {
    images = images,
    fonts = fonts,
    sources = sources,
    colors = colors
}
