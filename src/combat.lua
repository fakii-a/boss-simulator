local Combat = {}
function Combat.tickEntity(entity, dt)
    entity.invulnerable = math.max(0, (entity.invulnerable or 0) - dt)
    entity.flash = math.max(0, (entity.flash or 0) - dt)
    for key, value in pairs(entity.status) do
        if type(value) == "table" then
            value.remaining = value.remaining - dt
            if value.remaining <= 0 then
                entity.status[key] = nil
            end
        else
            value = value - dt
            entity.status[key] = value > 0 and value or nil
        end
    end
    for id, value in pairs(entity.cooldowns) do
        entity.cooldowns[id] = math.max(0, value - dt)
    end
end

function Combat.status(entity, status)
    if not status then
        return
    end
    if status.kind == "stun" then
        entity.status.stun = math.max(entity.status.stun or 0, status.duration)
    elseif status.kind == "slow" then
        entity.status.slow = { remaining = status.duration, multiplier = status.multiplier or 1.5 }
    end
end

function Combat.damage(world, source, target, amount, status, attack)
    if target.hp <= 0 then
        return false
    end
    if target.invulnerable > 0 then
        return false
    end
    local damage = math.max(0, amount - (target.defense or 0))
    damage = math.min(target.hp, damage)
    target.hp = math.max(0, target.hp - damage)
    target.flash = 0.14
    world:addVisual(
        { kind = "effect", style = "hit", x = target.rx, y = target.ry },
        0.22,
        source.kind
    )
    Combat.status(target, status)
    local stats = world.training.stats
    if target == world.player then
        stats.received = stats.received + damage
        stats.hits = stats.hits + 1
        target.invulnerable = world.config.player.invulnerabilityOnHit
        world.training:feedback("ACERTO RECEBIDO  -" .. math.floor(damage))
    else
        stats.dealt = stats.dealt + damage
    end
    world:addText(
        target.rx,
        target.ry,
        "-" .. math.floor(damage),
        target == world.player and "hurt" or "damage"
    )
    if target.hp <= 0 then
        target.state = "dead"
        target.step = nil
        target.cast = nil
        target.dash = nil
    end
    return damage > 0
end
return Combat
