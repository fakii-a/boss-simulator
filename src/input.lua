local Input = {}
Input.__index = Input
local directions = {
    up = { 0, -1 },
    down = { 0, 1 },
    left = { -1, 0 },
    right = { 1, 0 },
    northwest = { -1, -1 },
    northeast = { 1, -1 },
    southwest = { -1, 1 },
    southeast = { 1, 1 },
}
local function sign(v)
    return v > 0 and 1 or (v < 0 and -1 or 0)
end

function Input.mergeControls(defaults, saved)
    local result, used = {}, {}
    for action, keys in pairs(saved or {}) do
        result[action] = {}
        for _, key in ipairs(keys) do
            result[action][#result[action] + 1] = key
            used[key] = true
        end
    end
    for action, keys in pairs(defaults) do
        if not result[action] then
            result[action] = {}
            for _, key in ipairs(keys) do
                if not used[key] then
                    result[action][#result[action] + 1] = key
                    used[key] = true
                end
            end
        end
    end
    return result
end

function Input.new(controls, latency)
    return setmetatable(
        { controls = controls, latency = latency, events = {}, held = {}, actions = {}, tap = nil },
        Input
    )
end

function Input:reset()
    self.events = {}
    self.held = {}
    self.actions = {}
    self.tap = nil
    self.turnTap = nil
end

function Input:isTurnKey(key)
    return key == "lctrl" or key == "rctrl"
end

function Input:acceptsKey(key)
    return self:isTurnKey(key) or self:actionFor(key) ~= nil
end

function Input:isTurning()
    return self.held.lctrl or self.held.rctrl or false
end

function Input:actionFor(key)
    for action, keys in pairs(self.controls) do
        for _, k in ipairs(keys) do
            if k == key then
                return action
            end
        end
    end
end

function Input:enqueue(key, down, time)
    if self:acceptsKey(key) then
        self.events[#self.events + 1] = { key = key, down = down, due = time + self.latency / 1000 }
    end
end

function Input:enqueueAction(action, time)
    self.events[#self.events + 1] = { action = action, due = time + self.latency / 1000 }
end

function Input:isDown(action)
    for _, k in ipairs(self.controls[action] or {}) do
        if self.held[k] then
            return true
        end
    end
    return false
end

function Input:direction()
    local x, y = 0, 0
    for action, d in pairs(directions) do
        if self:isDown(action) then
            x, y = x + d[1], y + d[2]
        end
    end
    return sign(x), sign(y)
end

function Input:update(time)
    while self.events[1] and self.events[1].due <= time + 1e-9 do
        local event = table.remove(self.events, 1)
        if event.action then
            self.actions[#self.actions + 1] = event.action
        else
            local was = self.held[event.key]
            self.held[event.key] = event.down
            if event.down and not was then
                local action = self:actionFor(event.key)
                if self:isTurnKey(event.key) then
                    self.tap = nil
                elseif directions[action] then
                    local x, y = self:direction()
                    if self:isTurning() then
                        self.turnTap = (x ~= 0 or y ~= 0) and { x, y } or nil
                        self.tap = nil
                    else
                        self.tap = (x ~= 0 or y ~= 0) and { x, y } or nil
                    end
                else
                    self.actions[#self.actions + 1] = action
                end
            end
        end
    end
end

function Input:consumeTurnDirection()
    local turning = self:isTurning() or self.turnTap ~= nil
    local x, y = 0, 0
    if turning then
        x, y = self:direction()
        if x == 0 and y == 0 and self.turnTap then
            x, y = self.turnTap[1], self.turnTap[2]
        end
        self.tap = nil
    end
    self.turnTap = nil
    return x, y, turning
end

function Input:consumeDirection(bufferTap)
    local x, y = self:direction()
    if x == 0 and y == 0 and bufferTap and self.tap then
        x, y = self.tap[1], self.tap[2]
    end
    self.tap = nil
    return x, y
end

function Input:takeActions()
    local actions = self.actions
    self.actions = {}
    return actions
end
return Input
