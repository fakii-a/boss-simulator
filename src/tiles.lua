-- Rendering only: occupancy stays in arena.lua. Original PNG files are untouched.
local Tiles = {}
Tiles.__index = Tiles
local files = {
    sand1 = "6120_0069",
    sand2 = "6124_0071",
    tree = "1550_1712",
    bush = "1613_1473",
    crate = "1516_2895",
}
function Tiles.new()
    local self = setmetatable({ images = {} }, Tiles)
    for id, file in pairs(files) do
        local image = love.graphics.newImage("assets/tiles/Image_2D_" .. file .. ".png")
        image:setFilter("nearest", "nearest")
        self.images[id] = image
    end
    return self
end

function Tiles:draw(id, x, y, sqm, ground)
    local image = self.images[id]
    local w, h = image:getDimensions()
    local scale = sqm / 32
    love.graphics.setColor(1, 1, 1)
    if ground then
        love.graphics.draw(image, x, y, 0, scale, -scale, w / 2, h / 2)
    else
        -- Feet/base centered on the occupied SQM; tall art extends upward.
        local ox = id == "crate" and 46 or w * 0.65
        love.graphics.draw(image, x, y + sqm * 0.3, 0, scale, -scale, ox, h * 0.02)
    end
end

function Tiles:object(arena, x, y)
    if not arena:isWall(x, y) then
        return nil
    end
    if x == 1 or y == 1 or x == arena.cols or y == arena.rows then
        return (x + y) % 3 == 0 and "bush" or "tree"
    end
    return "crate"
end
return Tiles
