local Movement=require("src.movement")
local Skill=require("src.skill")
local Combat=require("src.combat")
local U=require("src.util")
local definitions=require("data.skills").player
local Player={};Player.__index=Player
function Player.new(config)
    local self=setmetatable({kind="player",hp=config.player.hp,maxHp=config.player.hp,
        energy=config.player.energy,maxEnergy=config.player.energy,defense=config.player.defense,
        radius=config.player.hitRadius,cooldowns={},status={},state="idle",invulnerable=0,selfStunRemaining=0},Player)
    Movement.initialize(self,unpack(config.arena.playerSpawn))
    return self
end
function Player:use(world,id)
    local p=world.config.playerSkills[id]
    if self.hp<=0 or self.cast or self.selfStunRemaining>1e-9 or self.status.stun or (self.cooldowns[id] or 0)>0 or self.energy<p.energy then return false end
    if id=="basic" then
        self.faceX,self.faceY=U.sign(world.boss.x-self.x),U.sign(world.boss.y-self.y)
        if self.faceX==0 and self.faceY==0 then self.faceY=1 end
    end
    self.energy=self.energy-p.energy;self.cooldowns[id]=p.cooldown
    self.selfStunTotal=math.max(p.selfStun or 0,p.lockMovement and p.windup or 0)
    self.selfStunRemaining=self.selfStunTotal
    local kind=(id=="spin" or id=="basic") and "circle" or "cells"
    local shapeParameters=p
    if id=="basic" then shapeParameters={radius=p.range} end
    self.cast={id=id,p=p,remaining=p.windup,shape=Skill.shape(self,shapeParameters,kind),
        originX=self.rx,originY=self.ry,dx=self.faceX,dy=self.faceY}
    self.state="attacking"
    return true
end
function Player:execute(world,cast)
    world:addVisual({kind="effect",style=cast.id,x=cast.originX,y=cast.originY,
        dx=cast.dx,dy=cast.dy,range=cast.p.range,radius=cast.p.radius,area=cast.shape},
        cast.id=="spin" and .45 or .32,"player")
    if cast.id=="shot" then
        Skill.projectile(world,self,math.atan2(cast.dy,cast.dx),cast.p)
    elseif cast.id=="basic" then
        local dist=U.distance(self,world.boss)
        if dist<=cast.p.range+world.boss.radius then
            Combat.damage(world,self,world.boss,cast.p.damage,cast.p.status)
            self.energy=math.min(self.maxEnergy,self.energy+(cast.p.energyGain or 0))
        end
    else Skill.hazard(world,self,cast.shape,cast.p) end
end
function Player:update(dt,world)
    Combat.tickEntity(self,dt)
    self.selfStunRemaining=math.max(0,self.selfStunRemaining-dt)
    if self.hp<=0 then self.state="dead";return end
    self.energy=math.min(self.maxEnergy,self.energy+world.config.player.energyRegen*dt)
    if self.status.stun then self.state="stunned";world.input:takeActions();return end
    if self.cast then
        self.cast.remaining=self.cast.remaining-dt
        if self.cast.remaining<=1e-9 then self:execute(world,self.cast);self.cast=nil;self.attackPose=.15 end
    end
    self.attackPose=math.max(0,(self.attackPose or 0)-dt)
    -- Skills are accepted before movement: a cast freezes even a partial SQM immediately.
    for _,action in ipairs(world.input:takeActions()) do
        local id=action=="basic" and "basic" or ({skill1="cut",skill2="spin",skill3="shot"})[action]
        if id then self:use(world,id) end
    end
    if world.input:isDown("basic") then self:use(world,"basic") end
    local locked=self.selfStunRemaining>1e-9 or (self.cast and self.cast.p.lockMovement)
    local turnX,turnY,turning=world.input:consumeTurnDirection()
    if not locked and turning and (turnX~=0 or turnY~=0) then self.faceX,self.faceY=turnX,turnY end
    if not locked then
        Movement.update(self,dt,world.config.movement)
        if not turning and not self.step and self.gap<=0 then
            local dx,dy=world.input:consumeDirection(world.config.movement.bufferTap)
            Movement.start(self,dx,dy,world,world.config.movement)
        end
    else world.input:consumeDirection(false) end -- discard taps while locked; held keys resume naturally
    self.state=self.cast and "attacking" or (locked and "recovering") or
        (self.attackPose>0 and "attacking") or (self.step and "moving" or "idle")
    world.training.stats.steps=self.steps
end
Player.definitions=definitions
return Player
