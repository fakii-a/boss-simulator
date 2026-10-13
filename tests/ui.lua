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
    assert(hud:click(1200,32)=="menu" and #hud.buttons==5)
    assert(renderer.view.x==0 and renderer.view.y==0 and renderer.view.w==1280 and renderer.view.h==820)
    for _,button in ipairs(hud.buttons) do assert(button.id=="menu" or button.id:match("^player:")) end
    results[#results+1]="PASS full-window arena and compact live HUD expose only menu and skills"
    hud:execute("menu",w,function()end);assert(w.menu)
    for _,page in ipairs({"training","calibration","controls","help"}) do
        hud.page=page;hud:draw(w,renderer)
    end
    results[#results+1]="PASS training, calibration, controls and help pages render inside the menu"
    hud.page="training";hud:draw(w,renderer)
    assert(hud:click(220,293)=="mode:fight" and hud:click(890,605)=="stop")
    assert(hud:click(220,490)=="speed:next" and hud:click(440,580)=="toggle:grid")
    assert(hud:systemAction("escape")=="menu" and hud:systemAction("tab")==nil)
    w.input:enqueue("d",true,w.time);hud:execute("menu",w,function()end)
    hud:execute(hud:systemAction("escape"),w,function()end)
    local oldTime=w.time;w:update(.2);assert(w.time==oldTime and #w.input.events==0)
    hud:execute(hud:systemAction("escape"),w,function()end);w:update(.1)
    assert(w.time>oldTime and w.player.steps==0 and not w.menu and not w.paused)
    hud:execute("menu",w,function()end)
    results[#results+1]="PASS Escape toggles the menu, freezes simulation, clears held input and exposes training controls"
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
    assert(w.menu);local frozen=w.time;w:update(.1);assert(w.time==frozen)
    results[#results+1]="PASS HUD mode switches restore speed and Ctrl stays reserved for facing"
    w.menu=false;w:stop("Encerrado");hud:draw(w,renderer)
    assert(hud:click(400,555)=="restart")
    results[#results+1]="PASS performance summary renders with working restart control"
    w:reset(false);w.paused=true;hud:draw(w,renderer)
    love.graphics.push();love.graphics.scale(.75)
    renderer:draw(w,hud.fonts);hud:draw(w,renderer)
    love.graphics.pop();love.graphics.setCanvas()
    results[#results+1]="PASS pause and scaled viewport render without graphics errors"
    for _,size in ipairs({{1600,820},{1280,1000}}) do
        local canvas=love.graphics.newCanvas(size[1],size[2]);love.graphics.setCanvas(canvas)
        renderer.view={x=0,y=0,w=size[1],h=size[2]};w.paused=false
        renderer:draw(w,hud.fonts);hud:draw(w,renderer)
        assert(hud:click(size[1]-60,32)=="menu")
        hud:execute("menu",w,function()end);hud:draw(w,renderer)
        local ox,oy=(size[1]-1280)/2,(size[2]-820)/2
        assert(hud:click(220+ox,293+oy)=="mode:fight")
        assert(hud:click(900+ox,698+oy)=="menu")
        for _,b in ipairs(hud.buttons) do
            assert(b.x>=0 and b.y>=0 and b.x+b.w<=size[1] and b.y+b.h<=size[2])
        end
        hud:execute("menu",w,function()end);love.graphics.setCanvas()
    end
    results[#results+1]="PASS wide and tall viewports keep the arena full-window and menu clicks aligned"
    return results
end
return T
