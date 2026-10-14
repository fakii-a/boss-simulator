local Movement = require("src.movement")
local trailDuration = require("data.effects").player.trail.duration
local Dash = {}
local function accelerate(entity, parameters)
    local step = entity.step
    local phase = step.elapsed / step.duration
    step.duration = (entity.x ~= step.fromX and entity.y ~= step.fromY) and parameters.diagonalStep
        or parameters.straightStep
    step.baseDuration = nil -- Forced displacement has its own timing, independent of speed buffs.
    step.elapsed = phase * step.duration
end

function Dash.start(entity, dx, dy, parameters, cast)
    entity.dash = {
        dx = dx,
        dy = dy,
        parameters = parameters,
        left = parameters.sqms,
        trail = 0,
        cast = cast,
        faceX = entity.faceX,
        faceY = entity.faceY,
    }
    -- Finish a partial step continuously. Count it only if it already follows
    -- the leap direction, so a retreat never turns into a forward jump.
    if entity.step then
        if entity.x - entity.step.fromX == dx and entity.y - entity.step.fromY == dy then
            entity.dash.left = entity.dash.left - 1
        end
        accelerate(entity, parameters)
    end
end

function Dash.update(entity, dt, world)
    local displacement = entity.dash
    local parameters = displacement.parameters
    if not entity.step and displacement.left > 0 then
        entity.gap = 0
        if
            Movement.start(entity, displacement.dx, displacement.dy, world, {
                straightStep = parameters.straightStep,
                diagonalStep = parameters.diagonalStep,
                blockDiagonalCorners = world.config.movement.blockDiagonalCorners,
            })
        then
            accelerate(entity, parameters)
            displacement.left = displacement.left - 1
        else
            displacement.left = 0
        end
        entity.faceX, entity.faceY = displacement.faceX, displacement.faceY
    end
    if entity.step then
        Movement.update(entity, dt, { stepGap = 0 })
        displacement.trail = displacement.trail - dt
        if displacement.trail <= 0 then
            world:addVisual({
                kind = "effect",
                style = "trail",
                x = entity.rx,
                y = entity.ry,
                dx = displacement.dx,
                dy = displacement.dy,
            }, trailDuration, "player")
            displacement.trail = 0.04
        end
    end
    if not entity.step and displacement.left == 0 then
        entity.dash = nil
        entity.selfStunTotal = parameters.recovery
        entity.selfStunRemaining = parameters.recovery
        if displacement.cast then
            entity:finishLeap(world, displacement.cast)
        end
    end
end
return Dash
