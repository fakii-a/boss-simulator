local Hud=require("src.hud")
local Renderer=require("src.renderer")
local Game=require("src.game")
local U=require("src.util")
local T={}
function T.run()
    local results={}
    local c=U.copy(require("config"));c.boss.initialDelay=1000
    local w=Game.new(c,U.copy(c.training));w.training.export=function()return true end
    local hud,renderer=Hud.new(),Renderer.new()
    assert(renderer.player.image and not renderer.player.error,renderer.player.error)
    assert(#renderer.player.quads==12 and renderer.player.manifest.flipY)
    for _,id in ipairs({"sand1","sand2","tree","bush","crate"}) do assert(renderer.tiles.images[id]) end
    results[#results+1]="PASS supplied Shanks frames and all map textures load in the real graphics runtime"
    local target=love.graphics.newCanvas(1280,820)
    love.graphics.setCanvas(target)
    renderer:draw(w,hud.fonts);hud:draw(w,renderer)
    local originalSqm=renderer.sqm
    hud:execute("adjust:zoom:1",w,function()end);renderer:camera(w)
    assert(renderer.sqm>originalSqm and w.player.steps==0)
    hud:execute("adjust:zoom:-1",w,function()end)
    for _,d in ipairs({{0,-1},{1,-1},{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1}}) do
        w.player.faceX,w.player.faceY=d[1],d[2]
        w.player.state="moving";w.player.step={}
        for _,phase in ipairs({0,.25,.5,.75}) do
            w.player.walkPhase=phase;renderer.player:draw(w.player,200,300,64,0)
        end
    end
    w.player.step=nil;w.player.state="idle"
    renderer:shape({kind="slash",x=11,y=12,dx=1,dy=0,range=1.45},.8,"player")
    w.player.hp=0;renderer.player:draw(w.player,200,300,64,0);w.player.hp=w.player.maxHp
    results[#results+1]="PASS adjustable zoom, walking views, attack effect and death fallback render"
    assert(hud:click(960,32)=="menu")
    results[#results+1]="PASS main HUD renders and buttons hit their intended controls"
    hud:execute("menu",w,function()end);assert(w.menu)
    for _,page in ipairs({"calibration","controls","help"}) do
        hud.page=page;hud:draw(w,renderer)
    end
    results[#results+1]="PASS calibration, controls and help pages render"
    local before=w.config.movement.straightStep
    hud:execute("adjust:straight:-1",w,function()end)
    assert(w.config.movement.straightStep<before)
    hud:execute("adjust:latency:1",w,function()end);assert(w.input.latency==10)
    results[#results+1]="PASS calibration buttons change timing and latency"
    hud:execute("bind:skill1",w,function()end);assert(hud:rebind("r",w))
    assert(w.input:actionFor("r")=="skill1")
    hud:execute("bind:skill2",w,function()end);hud:rebind("r",w)
    assert(w.input:actionFor("r")=="skill2")
    results[#results+1]="PASS remapped gameplay keys have one action without ambiguity"
    hud:execute("bind:skill2",w,function()end)
    assert(hud:rebind("lctrl",w) and hud.rebinding=="skill2")
    hud:rebind("escape",w)
    hud:execute("mode:slow",w,function()end);assert(w.settings.speed==.5)
    hud:execute("mode:fight",w,function()end);assert(w.settings.speed==1)
    results[#results+1]="PASS HUD mode switches restore speed and Ctrl stays reserved for facing"
    w.menu=false;w:stop("Encerrado");hud:draw(w,renderer)
    assert(hud:click(220,555)=="restart")
    results[#results+1]="PASS performance summary renders with working restart control"
    w:reset(false);w.paused=true;hud:draw(w,renderer)
    love.graphics.push();love.graphics.scale(.75)
    renderer:draw(w,hud.fonts);hud:draw(w,renderer)
    love.graphics.pop();love.graphics.setCanvas()
    results[#results+1]="PASS pause and scaled viewport render without graphics errors"
    return results
end
return T
