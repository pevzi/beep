function love.conf(t)
    t.identity = "beep"
    t.version = "0.10.0"

    t.window.width = 600
    t.window.height = 600
    t.window.title = "beep"
    t.window.msaa = 4

    t.modules.physics = false
end
