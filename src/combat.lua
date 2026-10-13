local Combat={}
function Combat.tickEntity(e,dt)
    e.invulnerable=math.max(0,(e.invulnerable or 0)-dt)
    e.flash=math.max(0,(e.flash or 0)-dt)
    for key,v in pairs(e.status) do
        if type(v)=="table" then
            v.remaining=v.remaining-dt
            if v.remaining<=0 then e.status[key]=nil end
        else
            v=v-dt;e.status[key]=v>0 and v or nil
        end
    end
    for id,v in pairs(e.cooldowns) do e.cooldowns[id]=math.max(0,v-dt) end
end
function Combat.status(e,s)
    if not s then return end
    if s.kind=="stun" then e.status.stun=math.max(e.status.stun or 0,s.duration)
    elseif s.kind=="slow" then
        e.status.slow={remaining=s.duration,multiplier=s.multiplier or 1.5}
    end
end
function Combat.damage(world,source,target,amount,status,attack)
    if target.hp<=0 then return false end
    if target.invulnerable>0 then
        if attack then attack.immune=true end
        return false
    end
    local damage=math.max(0,amount-(target.defense or 0))
    damage=math.min(target.hp,damage)
    target.hp=math.max(0,target.hp-damage)
    target.flash=.14
    world:addVisual({kind="effect",style="hit",x=target.rx,y=target.ry},.22,source.kind)
    Combat.status(target,status)
    if attack then attack.hit=true;attack.threatened=true end
    local stats=world.training.stats
    if target==world.player then
        stats.received=stats.received+damage;stats.hits=stats.hits+1
        target.invulnerable=world.config.player.invulnerabilityOnHit
        world.training:feedback("ACERTO RECEBIDO  -"..math.floor(damage))
    else stats.dealt=stats.dealt+damage end
    world:addText(target.rx,target.ry,"-"..math.floor(damage),target==world.player and "hurt" or "damage")
    if target.hp<=0 then target.state="dead";target.step=nil;target.cast=nil end
    return damage>0
end
return Combat
