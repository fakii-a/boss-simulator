function love.conf(t)
    t.identity = "gla-boss-fight-simulator"
    t.version = "11.5"
    t.console = false
    t.window.title = "GLA Boss Fight Simulator"
    t.window.width = 1280
    t.window.height = 820
    t.window.resizable = true
    t.window.minwidth = 960
    t.window.minheight = 615
    t.window.vsync = 1
    t.modules.physics = false
    t.modules.joystick = false
end
