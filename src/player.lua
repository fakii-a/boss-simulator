local Movement = require("src.movement")
local Dash = require("src.dash")
local Skill = require("src.skill")
local Combat = require("src.combat")
local Util = require("src.util")
local skillDefinitions = require("data.skills").player
local effectDefinitions = require("data.effects").player
local actionIds = {}
for _, def in ipairs(skillDefinitions) do
    actionIds[def.action] = def.id
end
local Player = {}
Player.__index = Player
function Player.new(config)
    local self = setmetatable({
        kind = "player",
        hp = config.player.hp,
        maxHp = config.player.hp,
        energy = config.player.energy,
        maxEnergy = config.player.energy,
        defense = config.player.defense,
        radius = config.player.hitRadius,
        cooldowns = {},
        status = {},
        state = "idle",
        invulnerable = 0,
        selfStunRemaining = 0,
    }, Player)
    Movement.initialize(self, unpack(config.arena.playerSpawn))
    return self
end

function Player:use(world, id)
    local parameters = world.config.playerSkills[id]
    if
        not parameters
        or self.hp <= 0
        or self.cast
        or self.dash
        or self.selfStunRemaining > 1e-9
        or self.status.stun
        or (self.cooldowns[id] or 0) > 0
        or self.energy < parameters.energy
    then
        return false
    end
    if id == "basic" then
        self.faceX, self.faceY = Util.sign(world.boss.x - self.x), Util.sign(world.boss.y - self.y)
        if self.faceX == 0 and self.faceY == 0 then
            self.faceY = 1
        end
    end
    self.energy = self.energy - parameters.energy
    self.cooldowns[id] = parameters.cooldown
    self.selfStunTotal =
        math.max(parameters.selfStun or 0, parameters.lockMovement and parameters.windup or 0)
    self.selfStunRemaining = self.selfStunTotal
    local kind = (id == "cut" or id == "waves" or id == "haki" or id == "basic") and "circle"
        or "cells"
    local shapeParameters = parameters
    if id == "basic" then
        shapeParameters = { radius = parameters.range }
    end
    self.cast = {
        id = id,
        parameters = parameters,
        remaining = parameters.windup,
        shape = Skill.shape(self, shapeParameters, kind),
        originX = self.rx,
        originY = self.ry,
        dx = self.faceX,
        dy = self.faceY,
        pulse = 0,
    }
    self.state = "attacking"
    return true
end

function Player:execute(world, cast)
    if cast.id == "dash" then
        self.status.speed = {
            remaining = cast.parameters.buffDuration,
            multiplier = cast.parameters.stepMultiplier,
        }
        self.status.invisible = cast.parameters.invisibilityDuration > 0
                and cast.parameters.invisibilityDuration
            or nil
        world:addVisual({
            kind = "effect",
            style = "dash",
            x = self.rx,
            y = self.ry,
            dx = cast.dx,
            dy = cast.dy,
        }, effectDefinitions.dash.duration, "player")
        return
    end
    if cast.id == "cut" or cast.id == "shot" then
        local sign = cast.id == "cut" and 1 or -1
        Dash.start(self, cast.dx * sign, cast.dy * sign, cast.parameters, cast)
        return
    end
    self:emitAttack(world, cast)
end

function Player:finishLeap(world, cast)
    cast.originX, cast.originY = self.rx, self.ry
    cast.shape = Skill.shape(
        { rx = self.rx, ry = self.ry, faceX = cast.dx, faceY = cast.dy },
        cast.parameters,
        cast.id == "cut" and "circle" or "cells"
    )
    self:emitAttack(world, cast)
end

function Player:emitAttack(world, cast)
    world:addVisual({
        kind = "effect",
        style = cast.id,
        x = cast.originX,
        y = cast.originY,
        dx = cast.dx,
        dy = cast.dy,
        range = cast.parameters.range,
        radius = cast.parameters.radius,
        area = cast.shape,
    }, effectDefinitions[cast.id].duration, "player")
    if cast.id == "basic" then
        local distance = Util.distance(self, world.boss)
        if distance <= cast.parameters.range + world.boss.radius then
            Combat.damage(world, self, world.boss, cast.parameters.damage, cast.parameters.status)
            self.energy = math.min(self.maxEnergy, self.energy + (cast.parameters.energyGain or 0))
        end
    else
        Skill.hazard(world, self, cast.shape, cast.parameters)
    end
end
-- Avança a preparação e agenda os pulsos sem depender do FPS de desenho.
function Player:updateCast(dt, world)
    if self.cast then
        self.cast.remaining = self.cast.remaining - dt
        if self.cast.remaining <= 1e-9 then
            local cast = self.cast
            self:execute(world, cast)
            cast.pulse = cast.pulse + 1
            if cast.pulse < (cast.parameters.count or 1) then
                cast.remaining = cast.remaining + cast.parameters.interval
            else
                self.cast = nil
            end
            self.attackPose = 0.15
        end
    end
end

-- Skills são lidas antes do movimento para aplicar self-stun no mesmo tick.
function Player:readActions(world)
    for _, action in ipairs(world.input:takeActions()) do
        local id = actionIds[action]
        if id then
            self:use(world, id)
        end
    end
    if world.input:isDown("basic") then
        self:use(world, "basic")
    end
end

function Player:updateMovement(dt, world)
    local locked = self.dash
        or self.selfStunRemaining > 1e-9
        or (self.cast and self.cast.parameters.lockMovement)
    local turnX, turnY, turning = world.input:consumeTurnDirection()
    if not locked and turning and (turnX ~= 0 or turnY ~= 0) then
        self.faceX, self.faceY = turnX, turnY
    end
    if self.dash then
        Dash.update(self, dt, world)
        world.input:consumeDirection(false)
    elseif not locked then
        Movement.update(self, dt, world.config.movement)
        if not turning and not self.step and self.gap <= 0 then
            local dx, dy = world.input:consumeDirection(world.config.movement.bufferTap)
            Movement.start(self, dx, dy, world, world.config.movement)
        end
    else
        world.input:consumeDirection(false)
    end -- Descarta toques; teclas seguradas retomam após o bloqueio.
    if self.dash then
        self.state = "moving"
    elseif self.cast then
        self.state = "attacking"
    elseif locked then
        self.state = "recovering"
    elseif self.attackPose > 0 then
        self.state = "attacking"
    elseif self.step then
        self.state = "moving"
    else
        self.state = "idle"
    end
    world.training.stats.steps = self.steps
end

-- Ordem do tick: timers -> preparação -> comandos -> movimento -> estado visual.
function Player:update(dt, world)
    Combat.tickEntity(self, dt)
    self.selfStunRemaining = math.max(0, self.selfStunRemaining - dt)
    if self.hp <= 0 then
        self.dash = nil
        self.state = "dead"
        return
    end
    self.energy = math.min(self.maxEnergy, self.energy + world.config.player.energyRegen * dt)
    if self.status.stun then
        self.state = "stunned"
        world.input:takeActions()
        return
    end

    self:updateCast(dt, world)
    self.attackPose = math.max(0, (self.attackPose or 0) - dt)
    self:readActions(world)
    self:updateMovement(dt, world)
end
Player.skillDefinitions = skillDefinitions
return Player
