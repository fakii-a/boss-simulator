-- Supplied sprite sequences. Visual extents never participate in hit detection.
local Effects = {}
Effects.__index = Effects
local Spritesheet = require("src.spritesheet")
local EffectDefinitions = require("data.effects")
local definitions = {
    slash = {
        files = { "2241_10054", "2247_10055", "2266_10056", "2275_10057", "2283_10058" },
        rect = { 14, 34, 67, 74 },
    },
    ring = { files = { "3187_4173", "3190_4182" }, rect = { 0, 33, 223, 223 } },
    hit = {
        files = { "1090_12279", "1127_12285", "1130_12291", "1132_12296" },
        rect = {
            12,
            110,
            138,
            126,
        },
    },
}
function Effects.new()
    local self = setmetatable({ groups = {} }, Effects)
    for id, definition in pairs(definitions) do
        local frames = {}
        local r = definition.rect
        for _, name in ipairs(definition.files) do
            local image = love.graphics.newImage("assets/effects/Image_2D_" .. name .. ".png")
            image:setFilter("nearest", "nearest")
            frames[#frames + 1] = {
                image = image,
                quad = love.graphics.newQuad(r[1], r[2], r[3], r[4], image:getDimensions()),
                w = r[3],
                h = r[4],
                flipY = true,
            }
        end
        self.groups[id] = frames
    end
    for id, definition in pairs(EffectDefinitions.sheets) do
        self.groups[id] = Spritesheet.load(definition)
    end
    return self
end

function Effects:sprite(id, progress, x, y, w, h, angle, boss, originX, originY)
    local frames = self.groups[id]
    local frame = frames[math.max(1, math.min(#frames, math.floor(progress * #frames) + 1))]
    local alpha = math.max(0, 1 - progress ^ 3)
    if boss then
        love.graphics.setColor(1, 0.14, 0.18, alpha)
    else
        love.graphics.setColor(1, 1, 1, alpha)
    end
    local scaleY = (frame.flipY and -1 or 1) * h / frame.h
    love.graphics.draw(
        frame.image,
        frame.quad,
        x,
        y,
        angle or 0,
        w / frame.w,
        scaleY,
        (originX or 0.5) * frame.w,
        (originY or 0.5) * frame.h
    )
end

-- Tamanhos e posições abaixo são apenas visuais. A máscara de dano está em Skill.
function Effects:drawPlayer(renderer, visual, definition, progress)
    local shape = visual.shape
    local sqm = renderer.sqm
    local x, y = renderer:point(shape.x, shape.y)
    local direction = math.atan2(shape.dy or 0, shape.dx or 1)
    local width = definition.width or 1

    if definition.layout == "forward" then
        local length = shape.range or 1.5
        -- Centros dos SQMs atingidos ficam entre 1 e length, à frente dos pés.
        x = x + math.cos(direction) * (length + 1) * sqm / 2
        y = y + math.sin(direction) * (length + 1) * sqm / 2

        if definition.vertical then
            -- Esta folha aponta para baixo: rotacionar -90 graus alinha à espada.
            self:sprite(
                definition.sheet,
                progress,
                x,
                y,
                width * sqm,
                length * sqm,
                direction - math.pi / 2,
                false
            )
        else
            self:sprite(
                definition.sheet,
                progress,
                x,
                y,
                length * sqm,
                width * sqm,
                direction,
                false
            )
        end
    elseif definition.layout == "impact" then
        -- O pé do raio (90% da altura do frame) coincide com a posição de chegada.
        self:sprite(
            definition.sheet,
            progress,
            x,
            y,
            width * sqm,
            definition.height * sqm,
            0,
            false,
            0.5,
            0.9
        )
    elseif definition.layout == "radial" then
        local diameter = (shape.radius or 1.65) * 2 * sqm
        self:sprite(definition.sheet, progress, x, y, diameter, diameter, 0, false)
    else
        self:sprite(
            definition.sheet,
            progress,
            x,
            y - sqm * 0.4,
            width * sqm,
            (definition.height or width) * sqm,
            0,
            false
        )
    end
end

function Effects:draw(renderer, visual)
    local shape = visual.shape
    local progress = math.max(0, 1 - visual.remaining / visual.duration)
    local s, boss = renderer.sqm, visual.kind == "boss"
    local playerEffect = not boss and EffectDefinitions.player[shape.style]
    if playerEffect then
        self:drawPlayer(renderer, visual, playerEffect, progress)
        return
    end
    local x, y = renderer:point(shape.x, shape.y)
    local angle = math.atan2(shape.dy or 0, shape.dx or 1)
    if shape.style == "hit" then
        self:sprite("hit", progress, x, y - s * 0.4, s * 1.25, s * 1.2, 0, boss)
    elseif shape.style == "impact" and shape.area and shape.area.cells then
        for _, cell in ipairs(shape.area.cells) do
            local px, py = renderer:point(cell.x, cell.y)
            self:sprite("hit", progress, px, py, s * 1.2, s * 1.2, 0, boss)
        end
    else
        local reach = shape.range or 1.3
        x = x + math.cos(angle) * reach * s * 0.55
        y = y + math.sin(angle) * reach * s * 0.55
        self:sprite("slash", progress, x, y, s * math.max(1.6, reach), s * 1.7, angle, boss)
    end
end

function Effects:projectile(renderer, p)
    local x, y = renderer:point(p.x, p.y)
    local s = renderer.sqm
    local progress = ((p.lifetime or p.remaining) - p.remaining) * 8 % 1
    self:sprite(
        "slash",
        progress,
        x,
        y,
        s * 0.85,
        s * 0.65,
        math.atan2(p.vy, p.vx),
        p.owner.kind == "boss"
    )
end
return Effects
