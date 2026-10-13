local tileSize = 32
local cols = 20
local rows = 14

local player = {
    x = 5,
    y = 7,
    hp = 100,
    moveDelay = 0.4,
    timer = 0
}

local boss = {
    x = 15,
    y = 7,
    hp = 1000
}

function love.load()
    love.window.setTitle("GLA Boss Training")
    love.window.setMode(cols * tileSize, rows * tileSize + 40)
end

function love.update(dt)
    player.timer = player.timer - dt

    if player.timer > 0 then
        return
    end

    local dx = 0
    local dy = 0

    if love.keyboard.isDown("w") then dy = -1 end
    if love.keyboard.isDown("s") then dy = 1 end
    if love.keyboard.isDown("a") then dx = -1 end
    if love.keyboard.isDown("d") then dx = 1 end

    if dx ~= 0 or dy ~= 0 then
        local newX = player.x + dx
        local newY = player.y + dy

        if newX >= 1 and newX <= cols
            and newY >= 1 and newY <= rows then
            -- Impede atravessar o boss
            if newX ~= boss.x or newY ~= boss.y then
                player.x = newX
                player.y = newY
            end
        end

        player.timer = player.moveDelay
    end
end

function love.keypressed(key)
    if key == "space" and boss.hp > 0 then
        local distanceX = math.abs(player.x - boss.x)
        local distanceY = math.abs(player.y - boss.y)

        if distanceX <= 1 and distanceY <= 1 then
            boss.hp = math.max(0, boss.hp - 10)
        end
    end
end

function love.draw()
    -- Fundo da arena
    love.graphics.setBackgroundColor(0.10, 0.12, 0.16)

    -- Grid
    love.graphics.setColor(0.25, 0.28, 0.35)

    for x = 0, cols do
        love.graphics.line(x * tileSize, 0,
            x * tileSize, rows * tileSize)
    end

    for y = 0, rows do
        love.graphics.line(0, y * tileSize,
            cols * tileSize, y * tileSize)
    end

    -- Jogador
    love.graphics.setColor(0.2, 0.6, 1)
    love.graphics.rectangle("fill",
        (player.x - 1) * tileSize + 4,
        (player.y - 1) * tileSize + 4,
        tileSize - 8,
        tileSize - 8
    )

    -- Boss
    if boss.hp > 0 then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.rectangle("fill",
            (boss.x - 1) * tileSize + 4,
            (boss.y - 1) * tileSize + 4,
            tileSize - 8,
            tileSize - 8
        )
    end

    -- Interface
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        "HP: " .. player.hp ..
        "   Boss HP: " .. boss.hp ..
        "   WASD: Mover | ESPACO: Atacar",
        10, rows * tileSize + 12
    )
end
