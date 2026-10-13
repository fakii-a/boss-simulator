local Arena=require("src.arena")
local Player=require("src.player")
local Boss=require("src.boss")
local Input=require("src.input")
local Training=require("src.training")
local Skill=require("src.skill")
local U=require("src.util")
local Game={};Game.__index=Game
function Game.new(config,settings)
    local self=setmetatable({config=config,settings=settings or U.copy(config.training),
        paused=false,menu=false,debug=false,accumulator=0,time=0},Game)
    self.training=Training.new(self.settings)
    self:reset(false)
    return self
end
function Game:reset(record)
    if record and self.training.stats.time>0 and not self.training.result then self:stop("Reinício") end
    if self.player then self.training:reset() end
    self.arena=Arena.new(self.config.arena)
    self.player=Player.new(self.config);self.boss=Boss.new(self.config)
    self.entities={self.player,self.boss}
    self.input=Input.new(self.config.controls,self.config.movement.latencyMs)
    self.hazards={};self.projectiles={};self.attacks={};self.texts={};self.visuals={}
    self.time=0;self.accumulator=0;self.paused=false;self.menu=false
end
function Game:addText(x,y,text,kind)
    self.texts[#self.texts+1]={x=x,y=y,text=text,kind=kind,remaining=.85}
end
function Game:addVisual(shape,duration,kind)
    self.visuals[#self.visuals+1]={shape=shape,remaining=duration,duration=duration,kind=kind}
end
function Game:setMode(mode)
    -- Finish with the old settings so the previous attempt keeps its actual mode/speed.
    if self.training.stats.time>0 and not self.training.result then self:stop("Troca de modo") end
    self.settings.mode=mode
    self.settings.speed=mode=="slow" and .5 or 1
    self:reset(false)
end
function Game:tick(dt)
    if self.training.result then return end
    self.time=self.time+dt
    self.input:update(self.time)
    self.training:update(dt)
    self.player:update(dt,self)
    self.boss:update(dt,self)
    Skill.updateEffects(self,dt)
    for _,list in ipairs({self.texts,self.visuals}) do
        for i=#list,1,-1 do
            list[i].remaining=list[i].remaining-dt
            if list[i].remaining<=0 then table.remove(list,i) end
        end
    end
    if self.player.hp<=0 then
        self:stop("Derrota")
    elseif self.boss.hp<=0 then
        if self.settings.mode=="practice" or self.settings.mode=="endless" then
            self.boss.hp=self.boss.maxHp;self.boss.state="idle";self.boss.timer=.6
            self.boss.cast=nil
            for _,a in ipairs(self.attacks) do a.done=true end
        else self:stop("Vitória") end
    end
end
function Game:update(realDt)
    if self.paused or self.menu or self.training.result then return end
    local dt=math.min(realDt,self.config.simulation.maxFrameDelta)
    self.training.stats.realTime=self.training.stats.realTime+dt
    self.accumulator=self.accumulator+dt*self.settings.speed
    local tick=self.config.simulation.tick
    while self.accumulator+1e-10>=tick and not self.training.result do
        self:tick(tick);self.accumulator=self.accumulator-tick
    end
end
function Game:stop(reason)
    self.training:finish(reason or "Encerrado")
    self.input:reset()
end
return Game
