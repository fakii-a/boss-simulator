local Game=require("src.game")
local Hud=require("src.hud")
local Renderer=require("src.renderer")
local U=require("src.util")
local world,hud,renderer,screenScale,offsetX,offsetY
local testMode,captureMode,captureFrames=false,false,0
local function loadConfig(saved)
    package.loaded.config=nil
    local c=require("config")
    if saved and love.filesystem.getInfo("settings.lua") then
        local ok,p=pcall(function() return love.filesystem.load("settings.lua")() end)
        if ok and type(p)=="table" then
            c.training=p.training or c.training;c.movement=p.movement or c.movement
            c.controls=p.controls or c.controls;c.arena.sqm=p.sqm or c.arena.sqm
            for key,value in pairs(p.camera or {}) do c.camera[key]=value end
            c.bossSkills=p.bossSkills or c.bossSkills
        end
    end
    assert(c.simulation.tick>0 and c.simulation.tick<=1/30,"tick inválido")
    assert(c.movement.straightStep>0 and c.movement.diagonalStep>0,"tempo de passo deve ser positivo")
    assert(c.training.frequency>0 and c.training.speed>0,"frequência/velocidade devem ser positivas")
    assert(c.training.difficultyPresets[c.training.difficulty],"dificuldade inválida")
    assert(c.arena.sqm>0 and c.window.scale>0,"SQM e escala devem ser positivos")
    assert(c.camera.zoom>0,"zoom deve ser positivo")
    return c
end
local function reload()
    local ok,c=pcall(loadConfig,false)
    if not ok then world.training:feedback("Erro de config: "..tostring(c));return end
    world:stop("Recalibração")
    local previous=world.training
    world=Game.new(c,U.copy(c.training))
    world.training.deaths=previous.deaths;world.training.history=previous.history
    world.training.attempt=previous.attempt+1
    world.training:feedback("config.lua recarregado")
end
function love.load(args)
    love.graphics.setDefaultFilter("nearest","nearest")
    for _,arg in ipairs(args or {}) do
        if arg=="--test" then testMode=true end
        if arg=="--capture" then captureMode=true end
    end
    if testMode then
        local ok,report=pcall(function() return require("tests.run").run() end)
        local reportText=ok and report or ("FAIL\n"..tostring(report))
        print(reportText)
        local saved,saveError=love.filesystem.write("test-results.txt",reportText)
        print("Report directory: "..love.filesystem.getSaveDirectory())
        if not saved then print("Could not save report: "..tostring(saveError)) end
        love.event.quit(ok and 0 or 1);return
    end
    local ok,c=pcall(loadConfig,not captureMode)
    if not ok then c=loadConfig(false) end
    love.window.setMode(c.window.width,c.window.height,{resizable=true,minwidth=960,minheight=615,vsync=1})
    world=Game.new(c,U.copy(c.training));hud=Hud.new();renderer=Renderer.new()
    if captureMode then
        world.settings.mode="practice";world.settings.practiceSkill="fan"
        require("src.movement").initialize(world.player,6,9)
        require("src.movement").initialize(world.boss,10,8)
        world.boss:begin(world,"fan")
    end
    love.resize(love.graphics.getDimensions())
end
function love.resize(w,h)
    screenScale=math.min(w/1280,h/820)
    offsetX,offsetY=(w-1280*screenScale)/2,(h-820*screenScale)/2
end
function love.update(dt)
    if testMode then return end
    world:update(dt)
    if captureMode then
        captureFrames=captureFrames+1
        if captureFrames==4 then
            love.graphics.captureScreenshot(function(data)
                local png=data:encode("png")
                local file=assert(io.open(love.filesystem.getSource().."/docs/preview.png","wb"))
                file:write(png:getString());file:close();love.event.quit()
            end)
        end
    end
end
function love.keypressed(key,scancode,isrepeat)
    if testMode or isrepeat then return end
    if hud:rebind(key,world) then return end
    local ui=({f1="mode:fight",f2="mode:practice",f4="mode:endless",f7="mode:slow",f6="restart",tab="menu"})[key]
    if ui then hud:execute(ui,world,reload);return end
    if key=="f3" then world.debug=not world.debug;return end
    if key=="f5" then reload();return end
    if key=="escape" then
        hud:execute(world.menu and "menu" or "pause",world,reload);return
    end
    if world.input:acceptsKey(key) then
        if not world.menu and not world.paused and not world.training.result then world.input:enqueue(key,true,world.time) end
        return
    end
    local shortcut=({r="restart",p="pause",["["]="skill:next",["]"]="skill:next",
        pageup="speed:next",pagedown="speed:next",["="]="frequency:next",["-"]="frequency:next"})[key]
    if shortcut then hud:execute(shortcut,world,reload) end
end
function love.keyreleased(key)
    if not testMode and world then world.input:enqueue(key,false,world.time) end
end
function love.mousepressed(x,y,button)
    if testMode or button~=1 then return end
    local action=hud:click((x-offsetX)/screenScale,(y-offsetY)/screenScale)
    if action then hud:execute(action,world,reload) end
end
function love.focus(focused)
    if not focused and world and not captureMode then world.paused=true;world.input:reset() end
end
function love.quit()
    if world and not captureMode and not world.training.result and world.training.stats.time>0 then world:stop("Saída") end
end
function love.draw()
    if testMode then return end
    love.graphics.clear(.035,.05,.07)
    love.graphics.push();love.graphics.translate(offsetX,offsetY);love.graphics.scale(screenScale)
    renderer:draw(world,hud.fonts);hud:draw(world,renderer)
    love.graphics.pop()
end
