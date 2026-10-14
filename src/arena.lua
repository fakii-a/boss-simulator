local C = require("src.collision")
local Arena = {}
Arena.__index = Arena
function Arena.new(config)
    local self = setmetatable({ cols = config.cols, rows = config.rows, obstacles = {} }, Arena)
    for _, p in ipairs(config.obstacles) do
        self.obstacles[p[1] .. ":" .. p[2]] = true
    end
    return self
end

function Arena:isWall(x, y)
    return x <= 1
        or y <= 1
        or x >= self.cols
        or y >= self.rows
        or self.obstacles[x .. ":" .. y]
        or false
end

function Arena:isBlocked(x, y, entity, entities)
    if self:isWall(x, y) then
        return true
    end
    for _, other in ipairs(entities or {}) do
        if other ~= entity and other.hp > 0 then
            if other.x == x and other.y == y then
                return true
            end
            local s = other.step
            if s and s.fromX == x and s.fromY == y then
                return true
            end
        end
    end
    return false
end

function Arena:canStep(entity, dx, dy, entities, blockCorners)
    if self:isBlocked(entity.x + dx, entity.y + dy, entity, entities) then
        return false
    end
    if blockCorners and dx ~= 0 and dy ~= 0 then
        if
            self:isBlocked(entity.x + dx, entity.y, entity, entities)
            or self:isBlocked(entity.x, entity.y + dy, entity, entities)
        then
            return false
        end
    end
    return true
end

function Arena:projectileWall(ax, ay, bx, by, radius)
    local earliest
    local minx, maxx =
        math.floor(math.min(ax, bx) - radius - 0.5), math.ceil(math.max(ax, bx) + radius + 0.5)
    local miny, maxy =
        math.floor(math.min(ay, by) - radius - 0.5), math.ceil(math.max(ay, by) + radius + 0.5)
    for y = miny, maxy do
        for x = minx, maxx do
            if self:isWall(x, y) then
                local hit, t = C.segmentRect(ax, ay, bx, by, x - 0.5, y - 0.5, 1, 1, radius)
                if hit and (not earliest or t < earliest) then
                    earliest = t
                end
            end
        end
    end
    return earliest
end
-- Breadth-first pathfinding prevents a chasing boss getting stuck behind crates.
function Arena:nextDirection(entity, target, entities, blockCorners)
    local directions =
        { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 }, { 1, -1 }, { 1, 1 }, { -1, 1 }, { -1, -1 } }
    local blockers = {}
    for _, e in ipairs(entities) do
        if e ~= entity then
            blockers[#blockers + 1] = e
        end
    end
    local queue, seen = { { x = entity.x, y = entity.y } }, { [entity.x .. ":" .. entity.y] = true }
    local index = 1
    while queue[index] do
        local node = queue[index]
        index = index + 1
        if
            math.max(math.abs(node.x - target.x), math.abs(node.y - target.y)) <= 1 and node.first
        then
            return node.first[1], node.first[2]
        end
        for _, d in ipairs(directions) do
            local x, y = node.x + d[1], node.y + d[2]
            local key = x .. ":" .. y
            if not seen[key] then
                local probe = { x = node.x, y = node.y }
                -- Ignore the boss itself when searching from a virtual cell.
                if self:canStep(probe, d[1], d[2], blockers, blockCorners) then
                    seen[key] = true
                    queue[#queue + 1] = { x = x, y = y, first = node.first or d }
                end
            end
        end
    end
    return 0, 0
end
return Arena
