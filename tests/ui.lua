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
    local target=love.graphics.newCanvas(1280,820)
    love.graphics.setCanvas(target)
    renderer:draw(w,hud.fonts);hud:draw(w,renderer)
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
