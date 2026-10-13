local Movement=require("src.movement")
local Skill=require("src.skill")
local Combat=require("src.combat")
local U=require("src.util")
local definition=require("data.bosses").alvida
local Boss={};Boss.__index=Boss
function Boss.new(config)
    local self=setmetatable({kind="boss",definition=definition,hp=config.boss.hp,maxHp=config.boss.hp,
        defense=config.boss.defense,radius=config.boss.hitRadius,cooldowns={},status={},
        state="idle",invulnerable=0,timer=config.boss.initialDelay,rotationIndex=1},Boss)
    Movement.initialize(self,unpack(config.arena.bossSpawn))
    return self
end
function Boss:begin(world,id)
    local p=Skill.scaledBossParameters(world,id)
    self.faceX,self.faceY=U.sign(world.player.x-self.x),U.sign(world.player.y-self.y)
    if self.faceX==0 and self.faceY==0 then self.faceY=1 end
    local shape=id~="volley" and Skill.shape(self,p,"cells") or nil
    local attack=Skill.newAttack(world,id,shape,p)
    world.attacks[#world.attacks+1]=attack
    local angles={}
    if id=="volley" then
        local aim=Skill.angle(self,world.player)
        for i=1,p.count do angles[#angles+1]=aim+(i-(p.count+1)/2)*p.angle end
    end
    self.cast={id=id,p=p,attack=attack,shape=shape,angles=angles,
        phase="windup",remaining=p.windup,total=p.windup,pulse=0}
    self.state="windup";self.cooldowns[id]=p.cooldown/world.settings.frequency
end
function Boss:execute(world,cast)
    cast.pulse=cast.pulse+1
    world:addVisual({kind="effect",style=cast.id=="volley" and "shot" or "impact",
        x=self.rx,y=self.ry,dx=self.faceX,dy=self.faceY,area=cast.shape},.38,"boss")
    if cast.id=="volley" then
        for _,angle in ipairs(cast.angles) do Skill.projectile(world,self,angle,cast.p,cast.attack) end
    else Skill.hazard(world,self,cast.shape,cast.p,cast.attack) end
    local last=cast.pulse>=(cast.p.count or 1) or cast.id=="volley"
    cast.phase=last and "active" or "between"
    cast.remaining=last and cast.p.duration or cast.p.interval
    cast.total=cast.remaining;self.state="attacking"
end
function Boss:updateCast(dt,world)
    local cast=self.cast
    cast.remaining=cast.remaining-dt
    if cast.remaining>1e-9 then return end
    if cast.phase=="windup" or cast.phase=="between" then
        self:execute(world,cast)
    elseif cast.phase=="active" then
        cast.phase="recovery";cast.remaining=cast.p.recovery;cast.total=cast.remaining
        self.state="recovery";cast.attack.done=true
    else
        self.cast=nil;self.state="idle"
        self.timer=world.config.boss.betweenSkills*(world.config.boss.attackTimeScale or 1)/world.settings.frequency
    end
end
function Boss:update(dt,world)
    Combat.tickEntity(self,dt)
    if self.hp<=0 then self.state="dead";return end
    if self.status.stun then self.state="stunned";return end
    if self.cast then self:updateCast(dt,world);return end
    local move={straightStep=world.config.boss.straightStep,diagonalStep=world.config.boss.diagonalStep,
        stepGap=0,blockDiagonalCorners=world.config.movement.blockDiagonalCorners}
    Movement.update(self,dt,move)
    self.timer=math.max(0,self.timer-dt)
    if self.step then self.state="moving";return end
    local practice=world.settings.mode=="practice"
    local id=practice and world.settings.practiceSkill or world.config.boss.rotation[self.rotationIndex]
    local range=id=="club" and 1.6 or world.config.boss.acquisitionRange
    if world.config.boss.chase and U.distance(self,world.player)>range then
        if self.gap<=0 then
            local dx,dy=world.arena:nextDirection(self,world.player,world.entities,move.blockDiagonalCorners)
            if not Movement.start(self,dx,dy,world,move) then self.gap=.15 end
        end
    elseif self.timer<=0 and (self.cooldowns[id] or 0)<=1e-9 then
        self:begin(world,id)
        if not practice then self.rotationIndex=self.rotationIndex%#world.config.boss.rotation+1 end
    else self.state="idle" end
end
return Boss
