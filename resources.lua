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
    speaker1 = {102, 217, 239},
    speaker2 = {253, 151, 31},
    background = {34, 40, 42},
    text = {208, 208, 208},
    indicatorDit = {208, 208, 208},
    indicatorDah = {249, 38, 114}
}

return {
    images = images,
    fonts = fonts,
    sources = sources,
    colors = colors
}
