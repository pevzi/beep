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

return {
    images = images,
    fonts = fonts,
    sources = sources
}
