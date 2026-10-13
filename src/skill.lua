local Collision=require("src.collision")
local Combat=require("src.combat")
local U=require("src.util")
local Skill={}
function Skill.shape(actor,parameters,kind)
    if kind=="circle" then return {kind="circle",x=actor.rx,y=actor.ry,radius=parameters.radius} end
    return Collision.cells({x=math.floor(actor.rx+.5),y=math.floor(actor.ry+.5)},
        actor.faceX,actor.faceY,parameters.range or 1,parameters.width or 1,parameters.spread)
end
function Skill.projectile(world,owner,angle,p,attack)
    world.projectiles[#world.projectiles+1]={owner=owner,x=owner.rx,y=owner.ry,
        vx=math.cos(angle)*p.speed,vy=math.sin(angle)*p.speed,radius=p.radius,
        remaining=p.lifetime,lifetime=p.lifetime,damage=p.damage,status=p.status,attack=attack}
    if attack then attack.projectiles=attack.projectiles+1 end
end
function Skill.angle(actor,target)
    return math.atan2(target.ry-actor.ry,target.rx-actor.rx)
end
function Skill.hazard(world,owner,shape,p,attack)
    world.hazards[#world.hazards+1]={owner=owner,shape=shape,remaining=p.duration,
        duration=p.duration,damage=p.damage,status=p.status,hit={},attack=attack}
    if attack then attack.hazards=attack.hazards+1 end
end
function Skill.newAttack(world,id,shape,parameters)
    return {id=id,shape=shape,parameters=parameters,startSteps=world.player.steps,
        threatened=shape and Collision.hits(shape,world.player) or false,
        hit=false,immune=false,hazards=0,projectiles=0,done=false,resolved=false}
end
function Skill.checkThreat(world,attack)
    if attack.shape and Collision.hits(attack.shape,world.player) then attack.threatened=true end
end
function Skill.projectileThreat(world,attack,owner,angles,p)
    for _,angle in ipairs(angles) do
        local range=p.speed*p.lifetime
        local bx,by=owner.rx+math.cos(angle)*range,owner.ry+math.sin(angle)*range
        local wall=world.arena:projectileWall(owner.rx,owner.ry,bx,by,p.radius)
        if wall then bx=owner.rx+(bx-owner.rx)*wall;by=owner.ry+(by-owner.ry)*wall end
        if Collision.segmentCircle(owner.rx,owner.ry,bx,by,
            world.player.rx,world.player.ry,world.player.radius+p.radius) then
            attack.threatened=true
        end
    end
end
function Skill.updateEffects(world,dt)
    for i=#world.hazards,1,-1 do
        local h=world.hazards[i]
        local target=h.owner==world.player and world.boss or world.player
        if h.attack then Skill.checkThreat(world,h.attack) end
        if not h.hit[target] and Collision.hits(h.shape,target) then
            h.hit[target]=true
            Combat.damage(world,h.owner,target,h.damage,h.status,h.attack)
        end
        h.remaining=h.remaining-dt
        if h.remaining<=1e-9 then
            if h.attack then h.attack.hazards=h.attack.hazards-1 end
            table.remove(world.hazards,i)
        end
    end
    for i=#world.projectiles,1,-1 do
        local p=world.projectiles[i]
        if p.attack then
            Skill.projectileThreat(world,p.attack,{rx=p.x,ry=p.y},{math.atan2(p.vy,p.vx)},
                {speed=math.sqrt(p.vx*p.vx+p.vy*p.vy),lifetime=p.remaining,radius=p.radius})
        end
        local target=p.owner==world.player and world.boss or world.player
        local nx,ny=p.x+p.vx*dt,p.y+p.vy*dt
        local wallTime=world.arena:projectileWall(p.x,p.y,nx,ny,p.radius)
        local endX,endY=nx,ny
        if wallTime then endX=p.x+(nx-p.x)*wallTime;endY=p.y+(ny-p.y)*wallTime end
        local hit=target.hp>0 and Collision.segmentCircle(p.x,p.y,endX,endY,target.rx,target.ry,p.radius+target.radius)
        if hit then Combat.damage(world,p.owner,target,p.damage,p.status,p.attack) end
        if wallTime and not hit then
            world:addVisual({kind="effect",style="hit",x=endX,y=endY},.22,p.owner.kind)
        end
        p.remaining=p.remaining-dt;p.x,p.y=nx,ny
        if hit or wallTime or p.remaining<=0 then
            if p.attack then p.attack.projectiles=p.attack.projectiles-1 end
            table.remove(world.projectiles,i)
        end
    end
    for i=#world.attacks,1,-1 do
        local attack=world.attacks[i]
        if attack.done and attack.hazards==0 and attack.projectiles==0 then
            if not attack.resolved then world.training:resolveAttack(attack,world.player) end
            attack.resolved=true;table.remove(world.attacks,i)
        end
    end
end
function Skill.scaledBossParameters(world,id)
    local p=U.copy(world.config.bossSkills[id])
    local difficulty=world.config.training.difficultyPresets[world.settings.difficulty]
    local tempo=world.config.boss.attackTimeScale or 1
    p.windup=p.windup*difficulty.windup*tempo;p.damage=p.damage*difficulty.damage
    p.recovery=p.recovery*tempo
    if p.interval then p.interval=p.interval*tempo end
    if p.speed then p.speed=p.speed/tempo;p.lifetime=p.lifetime*tempo end
    return p
end
return Skill
