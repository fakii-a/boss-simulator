local U=require("src.util")
local Game=require("src.game")
local Movement=require("src.movement")
local Collision=require("src.collision")
local Combat=require("src.combat")
local Skill=require("src.skill")
local Input=require("src.input")
local T={}
local function close(a,b,message)
    assert(math.abs(a-b)<1e-6,(message or "values differ")..": "..a.." vs "..b)
end
local function fresh()
    local c=U.copy(require("config"));c.boss.chase=false;c.boss.initialDelay=1000
    local w=Game.new(c,U.copy(c.training));w.training.export=function() return true end
    return w
end
local function ticks(w,seconds)
    for _=1,math.floor(seconds/w.config.simulation.tick+.5) do w:tick(w.config.simulation.tick) end
end
local function place(e,x,y) Movement.initialize(e,x,y) end
function T.run()
    local results={};local function test(name,fn) fn();results[#results+1]="PASS "..name end
    test("short tap survives a down/up within one simulation tick",function()
        local w=fresh();local x=w.player.x
        w.input:enqueue("d",true,0);w.input:enqueue("d",false,.001)
        ticks(w,.5);assert(w.player.x==x+1 and not w.player.step)
    end)
    test("held movement remains identical at 30, 60, 144 FPS",function()
        local states={}
        for _,fps in ipairs({30,60,144}) do
            local w=fresh();w.input:enqueue("d",true,0)
            for _=1,fps*3 do w:update(1/fps) end
            states[#states+1]=w
        end
        for i=2,#states do
            close(states[1].player.rx,states[i].player.rx);close(states[1].time,states[i].time)
            assert(states[1].player.steps==states[i].player.steps)
        end
        assert(states[1].player.steps==9)
    end)
    test("diagonal uses twice straight duration and eight directions work",function()
        local directions={{1,0},{-1,0},{0,1},{0,-1},{1,1},{-1,1},{1,-1},{-1,-1}}
        for _,d in ipairs(directions) do
            local w=fresh();place(w.player,10,10)
            assert(Movement.start(w.player,d[1],d[2],w,w.config.movement))
            local expected=(d[1]~=0 and d[2]~=0) and 2/3 or 1/3
            close(w.player.step.duration,expected)
            Movement.update(w.player,expected,w.config.movement)
            close(w.player.rx,10+d[1]);close(w.player.ry,10+d[2])
        end
    end)
    test("opposite keys cancel and a new axis produces a diagonal",function()
        local input=Input.new(require("config").controls,0)
        input:enqueue("w",true,0);input:enqueue("s",true,0);input:update(.1)
        local x,y=input:consumeDirection(true);assert(x==0 and y==0)
        input:enqueue("s",false,.1);input:enqueue("d",true,.1);input:update(.2)
        x,y=input:direction();assert(x==1 and y==-1)
    end)
    test("direction changes at the next SQM without accumulated backlog",function()
        local w=fresh();w.input:enqueue("d",true,0);ticks(w,.15)
        w.input:enqueue("d",false,w.time);w.input:enqueue("w",true,w.time)
        ticks(w,.2);assert(w.player.step and w.player.x==12 and w.player.y==11)
        assert(w.player.step.fromX==12 and w.player.step.fromY==12)
    end)
    test("simulated latency delays both press and release",function()
        local w=fresh();w.input.latency=100
        w.input:enqueue("d",true,0);w.input:enqueue("d",false,.01)
        ticks(w,.09);assert(w.player.steps==0)
        ticks(w,.03);assert(w.player.steps==1)
        ticks(w,.5);assert(w.player.steps==1)
    end)
    test("walls, obstacles and diagonal corners block movement",function()
        local w=fresh();place(w.player,2,2)
        assert(not Movement.start(w.player,-1,0,w,w.config.movement))
        place(w.player,4,5);assert(not Movement.start(w.player,1,0,w,w.config.movement))
        place(w.player,4,4);assert(not Movement.start(w.player,1,1,w,w.config.movement))
        w.arena.obstacles["5:4"]=true
        assert(not Movement.start(w.player,1,-1,w,w.config.movement))
        w.config.movement.blockDiagonalCorners=false
        assert(Movement.start(w.player,1,-1,w,w.config.movement))
    end)
    test("directional attack masks reach an adjacent SQM in all eight directions",function()
        for _,d in ipairs({{1,0},{-1,0},{0,1},{0,-1},{1,1},{-1,1},{1,-1},{-1,-1}}) do
            local shape=Collision.cells({x=10,y=10},d[1],d[2],1,1)
            assert(Collision.hits(shape,{rx=10+d[1],ry=10+d[2],radius=.22}))
            assert(not Collision.hits(shape,{rx=10-d[1],ry=10-d[2],radius=.22}))
        end
    end)
    test("entity collisions reserve both endpoints of an active step",function()
        local w=fresh();place(w.player,10,10);place(w.boss,11,10)
        assert(not Movement.start(w.player,1,0,w,w.config.movement))
        assert(Movement.start(w.boss,1,0,w,w.config.movement))
        assert(w.arena:isBlocked(11,10,w.player,w.entities))
        assert(w.arena:isBlocked(12,10,w.player,w.entities))
    end)
    test("no teleport: hitbox follows interpolated feet",function()
        local w=fresh();place(w.player,10,10)
        Movement.start(w.player,1,0,w,w.config.movement)
        close(w.player.rx,10);Movement.update(w.player,1/6,w.config.movement);close(w.player.rx,10.5)
        assert(Collision.hits({kind="circle",x=10.5,y=10,radius=.01},w.player))
    end)
    test("cooldowns are independent and energy prevents invalid casts",function()
        local w=fresh();assert(w.player:use(w,"cut"));assert(not w.player:use(w,"spin"))
        ticks(w,.3);assert(w.player:use(w,"spin"))
        assert(w.player.cooldowns.cut>0 and w.player.cooldowns.spin>0)
        ticks(w,.5);w.player.energy=0;assert(not w.player:use(w,"shot"))
    end)
    test("defense, death and invulnerability require explicit configuration",function()
        local w=fresh();w.player.defense=5
        Combat.damage(w,w.boss,w.player,20);Combat.damage(w,w.boss,w.player,20)
        close(w.player.hp,970);assert(w.player.invulnerable==0)
        w.player.invulnerable=1;Combat.damage(w,w.boss,w.player,100);close(w.player.hp,970)
        w.player.invulnerable=0;Combat.damage(w,w.boss,w.player,2000)
        assert(w.player.hp==0 and w.player.state=="dead")
    end)
    test("swept projectile hits small targets and stops behind obstacles",function()
        local w=fresh();place(w.player,3,10);place(w.boss,12,10)
        Skill.projectile(w,w.player,0,{speed=2000,radius=.1,lifetime=1,damage=100})
        Skill.updateEffects(w,1/120);assert(w.boss.hp<w.boss.maxHp)
        local blocked=fresh();place(blocked.player,3,10);place(blocked.boss,12,10)
        blocked.arena.obstacles["8:10"]=true
        Skill.projectile(blocked,blocked.player,0,{speed=2000,radius=.1,lifetime=1,damage=100})
        Skill.updateEffects(blocked,1/120);assert(blocked.boss.hp==blocked.boss.maxHp)
        assert(#blocked.projectiles==0)
    end)
    test("hazard hits only once per pulse, with no universal immunity",function()
        local w=fresh();place(w.player,10,10)
        local shape={kind="circle",x=10,y=10,radius=1}
        Skill.hazard(w,w.boss,shape,{duration=.2,damage=50})
        ticks(w,.25);close(w.player.hp,950)
        Skill.hazard(w,w.boss,shape,{duration=.2,damage=50});ticks(w,.25);close(w.player.hp,900)
    end)
    test("stun freezes movement; slow changes the next step duration",function()
        local w=fresh();w.input:enqueue("d",true,0);ticks(w,.1)
        Combat.status(w.player,{kind="stun",duration=.2});local x=w.player.rx
        ticks(w,.1);close(w.player.rx,x)
        ticks(w,.2);assert(w.player.rx>x)
        place(w.player,10,10);Combat.status(w.player,{kind="slow",duration=1,multiplier=2})
        assert(Movement.start(w.player,1,0,w,w.config.movement));close(w.player.step.duration,2/3)
    end)
    test("all four boss patterns execute, including two separate combo hits",function()
        for _,id in ipairs({"club","fan","combo","volley"}) do
            local w=fresh();place(w.boss,10,10);place(w.player,11,10)
            w.boss:begin(w,id);ticks(w,2)
            assert(w.training.stats.received>0,id.." did not hit")
            assert(w.training.stats.failures==1,id.." did not resolve once")
            if id=="combo" then assert(w.training.stats.hits==2) end
        end
    end)
    test("threatened movement without damage counts as a dodge",function()
        local w=fresh();place(w.boss,10,10);place(w.player,11,10)
        w.boss:begin(w,"club");w.input:enqueue("s",true,0);w.input:enqueue("s",false,.01)
        ticks(w,1.2);assert(w.training.stats.avoided==1 and w.training.stats.failures==0)
        close(w.training:accuracy(),100)
    end)
    test("safe positioning and immunity cannot inflate dodge precision",function()
        local w=fresh();place(w.boss,10,10);place(w.player,14,10)
        w.boss:begin(w,"club");ticks(w,1.2)
        assert(w.training.stats.positioned==1 and w.training:accuracy()==nil)
        place(w.player,11,10);w.player.invulnerable=3;w.boss:begin(w,"club");ticks(w,1.2)
        assert(w.training.stats.immune==1 and w.training.stats.avoided==0)
    end)
    test("the fatal attack is included before defeat summary",function()
        local w=fresh();place(w.boss,10,10);place(w.player,11,10);w.player.hp=10
        w.boss:begin(w,"club");ticks(w,1)
        assert(w.training.result.reason=="Derrota" and w.training.result.failures==1 and w.training.deaths==1)
    end)
    test("ending during an active hit records a failure; walls exclude projectile threats",function()
        local w=fresh();place(w.boss,10,10);place(w.player,11,10)
        w.boss:begin(w,"club");ticks(w,.5);w:stop("Encerrado")
        assert(w.training.result.failures==1)
        local blocked=fresh();place(blocked.boss,3,10);place(blocked.player,12,10)
        blocked.arena.obstacles["8:10"]=true
        blocked.boss:begin(blocked,"volley")
        assert(not blocked.boss.cast.attack.threatened)
    end)
    test("short taps remain buffered during a configured gap between SQMs",function()
        local w=fresh();w.config.movement.stepGap=.2
        w.input:enqueue("d",true,0);w.input:enqueue("d",false,.01);ticks(w,.4)
        w.input:enqueue("w",true,w.time);w.input:enqueue("w",false,w.time+.001)
        ticks(w,.5);assert(w.player.steps==2 and w.player.y==11)
    end)
    test("full boss AI and damage remain identical at different rendering rates",function()
        local states={}
        for _,fps in ipairs({30,144}) do
            local w=fresh();w.config.boss.chase=true;w.boss.timer=0
            w.input:enqueue("space",true,0)
            for _=1,fps*20 do w:update(1/fps) end
            states[#states+1]=w
        end
        close(states[1].player.hp,states[2].player.hp)
        close(states[1].boss.hp,states[2].boss.hp)
        assert(states[1].training.stats.received>0 and states[1].training.stats.dealt>0)
        assert(states[1].training.stats.failures==states[2].training.stats.failures)
    end)
    test("practice and endless replenish boss; fight reports victory",function()
        for _,mode in ipairs({"fight","practice","endless"}) do
            local w=fresh();w.settings.mode=mode;w.boss.hp=0;w:tick(1/120)
            if mode=="fight" then assert(w.training.result.reason=="Vitória")
            else assert(not w.training.result and w.boss.hp==w.boss.maxHp) end
        end
    end)
    test("slow motion scales the entire simulation and pause freezes it",function()
        local w=fresh();w.settings.speed=.5;w.input:enqueue("d",true,0)
        for _=1,60 do w:update(1/60) end
        close(w.time,.5);close(w.training.stats.realTime,1)
        local x=w.player.rx;w.paused=true;w:update(.1);close(w.player.rx,x);close(w.time,.5)
    end)
    test("restart clears inputs and effects while preserving session deaths",function()
        local w=fresh();w.training.deaths=2;w.input:enqueue("d",true,0);ticks(w,.2)
        w:reset(true);assert(w.player.hp==w.player.maxHp and w.training.deaths==2)
        assert(#w.hazards==0 and #w.projectiles==0 and w.training.stats.received==0)
        ticks(w,.5);assert(w.player.steps==0)
    end)
    test("pathfinding routes around obstacles to a reachable adjacent SQM",function()
        local w=fresh();place(w.boss,4,5);place(w.player,8,5)
        local dx,dy=w.arena:nextDirection(w.boss,w.player,w.entities,true)
        assert(dx~=0 or dy~=0);assert(w.arena:canStep(w.boss,dx,dy,w.entities,true))
    end)
    if love and love.graphics then
        local ui=require("tests.ui").run()
        for _,line in ipairs(ui) do results[#results+1]=line end
    end
    return table.concat(results,"\n").."\n"..#results.." tests passed"
end
return T
