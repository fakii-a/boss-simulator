local Movement = {}
function Movement.initialize(entity, x, y)
    entity.x, entity.y, entity.rx, entity.ry = x, y, x, y
    entity.faceX, entity.faceY = 0, 1
    entity.step, entity.gap = nil, 0
    entity.walkPhase, entity.steps = 0, 0
end

function Movement.start(entity, dx, dy, world, settings)
    if
        entity.step
        or entity.gap > 1e-9
        or entity.hp <= 0
        or (entity.status.stun or 0) > 0
        or (entity.selfStunRemaining or 0) > 1e-9
    then
        return false
    end
    if dx == 0 and dy == 0 then
        return false
    end
    entity.faceX, entity.faceY = dx, dy
    if not world.arena:canStep(entity, dx, dy, world.entities, settings.blockDiagonalCorners) then
        return false
    end
    local duration = (dx ~= 0 and dy ~= 0) and settings.diagonalStep or settings.straightStep
    entity.step = {
        fromX = entity.x,
        fromY = entity.y,
        elapsed = 0,
        duration = duration,
        baseDuration = duration,
    }
    Movement.retime(entity)
    entity.x, entity.y = entity.x + dx, entity.y + dy
    entity.steps = entity.steps + 1
    entity.state = "moving"
    return true
end

function Movement.retime(entity)
    local step = entity.step
    if not step or not step.baseDuration then
        return
    end
    local phase = step.elapsed / step.duration
    step.duration = step.baseDuration
        * (entity.status.slow and entity.status.slow.multiplier or 1)
        * (entity.status.speed and entity.status.speed.multiplier or 1)
    step.elapsed = phase * step.duration
end

function Movement.update(entity, dt, settings)
    if entity.step then
        Movement.retime(entity)
        local step = entity.step
        step.elapsed = math.min(step.duration, step.elapsed + dt)
        local progress = step.elapsed / step.duration
        entity.rx, entity.ry =
            step.fromX + (entity.x - step.fromX) * progress,
            step.fromY + (entity.y - step.fromY) * progress
        entity.walkPhase = progress
        if progress >= 1 - 1e-9 then
            entity.rx, entity.ry = entity.x, entity.y
            entity.step = nil
            entity.gap = settings.stepGap or 0
        end
    else
        entity.gap = math.max(0, entity.gap - dt)
    end
end
return Movement
