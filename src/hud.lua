local U = require("src.util")
local Skills = require("data.skills")
local Icons = require("src.skill_icons")
local Hud = {}
Hud.__index = Hud
local colors = {
    bg = { 0.055, 0.08, 0.105 },
    panel = { 0.08, 0.115, 0.145 },
    border = { 0.2, 0.3, 0.35 },
    text = { 0.87, 0.92, 0.94 },
    muted = { 0.49, 0.61, 0.67 },
    accent = { 0.3, 0.82, 0.8 },
    gold = { 0.98, 0.72, 0.35 },
    red = { 0.96, 0.39, 0.43 },
}
local function color(c, a)
    love.graphics.setColor(c[1], c[2], c[3], a or 1)
end
local modes = {
    { "fight", "Boss Fight", "F1" },
    { "practice", "Skill Practice", "F2" },
    { "endless", "Endless", "F4" },
    { "slow", "Slow Motion", "F7" },
}
local bindingOrder = {
    "up",
    "down",
    "left",
    "right",
    "northwest",
    "northeast",
    "southwest",
    "southeast",
    "basic",
    "skill1",
    "skill2",
    "skill3",
    "skill4",
    "skill5",
    "skill6",
    "skill7",
}
local bindingNames = {
    up = "Norte",
    down = "Sul",
    left = "Oeste",
    right = "Leste",
    northwest = "Noroeste",
    northeast = "Nordeste",
    southwest = "Sudoeste",
    southeast = "Sudeste",
    basic = "Ataque básico",
    skill1 = "Heroic Strike",
    skill2 = "Kenshi Flurry",
    skill3 = "Ryusosen",
    skill4 = "Kenshi Speed",
    skill5 = "Mighty Fissure",
    skill6 = "Haki Waves",
    skill7 = "Haoshoku Haki",
}
function Hud.new()
    return setmetatable({
        buttons = {},
        page = "training",
        fonts = {
            tiny = love.graphics.newFont(11),
            small = love.graphics.newFont(13),
            body = love.graphics.newFont(15),
            medium = love.graphics.newFont(19),
            title = love.graphics.newFont(27),
            large = love.graphics.newFont(40),
        },
    }, Hud)
end

function Hud:text(text, x, y, font, c, width, align)
    local g = love.graphics
    g.setFont(self.fonts[font or "body"])
    color(c or colors.text)
    if width then
        g.printf(text, x, y, width, align or "left")
    else
        g.print(text, x, y)
    end
end

function Hud:panel(x, y, w, h)
    color(colors.panel)
    love.graphics.rectangle("fill", x, y, w, h, 7)
    color(colors.border, 0.7)
    love.graphics.rectangle("line", x, y, w, h, 7)
end

function Hud:button(id, label, x, y, w, h, selected)
    local g = love.graphics
    color(selected and { 0.12, 0.29, 0.31 } or { 0.115, 0.16, 0.195 })
    g.rectangle("fill", x, y, w, h, 4)
    color(selected and colors.accent or colors.border)
    g.rectangle("line", x, y, w, h, 4)
    self:text(
        label,
        x + 5,
        y + (h - 16) / 2,
        "small",
        selected and colors.accent or colors.text,
        w - 10,
        "center"
    )
    self:hitArea(id, x, y, w, h)
end

function Hud:hitArea(id, x, y, w, h)
    self.buttons[#self.buttons + 1] =
        { id = id, x = x + (self.offsetX or 0), y = y + (self.offsetY or 0), w = w, h = h }
end

function Hud:systemAction(key)
    return ({
        escape = "menu",
        f1 = "mode:fight",
        f2 = "mode:practice",
        f4 = "mode:endless",
        f7 = "mode:slow",
        f6 = "restart",
    })[key]
end

function Hud:bar(label, current, max, x, y, w, h, c)
    color({ 0.035, 0.055, 0.075 })
    love.graphics.rectangle("fill", x, y, w, h, 4)
    color(c)
    love.graphics.rectangle("fill", x, y, w * U.clamp(current / max, 0, 1), h, 4)
    self:text(
        label .. "  " .. math.ceil(current) .. " / " .. max,
        x + 8,
        y + 3,
        "small",
        colors.text
    )
end

function Hud:liveBar(label, current, maximum, x, y, width, c)
    local g = love.graphics
    color(colors.bg, 0.68)
    g.rectangle("fill", x - 8, y - 4, width + 16, 29, 4)
    self:text(label, x, y, "tiny", colors.text)
    self:text(tostring(math.ceil(current)), x, y, "tiny", colors.text, width, "right")
    color(colors.bg, 0.55)
    g.rectangle("fill", x, y + 16, width, 5, 2)
    color(c)
    g.rectangle("fill", x, y + 16, width * U.clamp(current / maximum, 0, 1), 5, 2)
end

function Hud:row(label, value, x, y, w)
    self:text(label, x, y, "small", colors.muted)
    self:text(value, x, y, "small", colors.text, w, "right")
end

-- Live HUD uses the whole viewport. Detailed controls only exist inside the menu.
function Hud:draw(world, renderer)
    self.buttons = {}
    self.offsetX, self.offsetY = 0, 0
    local g, w, h = love.graphics, renderer.view.w, renderer.view.h
    local overlay = world.menu or world.training.result or world.paused
    if not overlay then
        self:liveBar("HP", world.player.hp, world.player.maxHp, 20, 18, 168, { 0.20, 0.78, 0.28 })
        self:liveBar(
            "EN",
            world.player.energy,
            world.player.maxEnergy,
            20,
            43,
            168,
            { 0.34, 0.56, 0.91 }
        )
        self:liveBar(
            "BOSS",
            world.boss.hp,
            world.boss.maxHp,
            w / 2 - 120,
            18,
            240,
            { 0.20, 0.78, 0.28 }
        )
        color(colors.bg, 0.68)
        g.rectangle("fill", w - 110, 16, 94, 28, 4)
        self:text("Esc  Menu", w - 124, 21, "small", colors.text, 96, "right")
        self:hitArea("menu", w - 116, 16, 96, 28)
        for i, def in ipairs(Skills.player) do
            local x, y = w / 2 - (#Skills.player * 50 - 6) / 2 + (i - 1) * 50, h - 62
            local key = string.upper(world.config.controls[def.action][1] or "—")
            if key == "SPACE" then
                key = "SPC"
            end
            local cd, p = world.player.cooldowns[def.id] or 0, world.config.playerSkills[def.id]
            local ready = cd <= 0 and world.player.energy >= p.energy
            color(colors.bg, 0.65)
            g.rectangle("fill", x, y, 44, 44, 5)
            color(ready and colors.text or colors.muted, 0.95)
            Icons.draw(def.id, x + 11, y + 5, 22)
            if cd > 0 then
                color(colors.bg, 0.65)
                g.rectangle(
                    "fill",
                    x,
                    y + 44 * (1 - U.clamp(cd / p.cooldown, 0, 1)),
                    44,
                    44 * U.clamp(cd / p.cooldown, 0, 1),
                    4
                )
                self:text(string.format("%.1f", cd), x, y + 9, "small", colors.text, 44, "center")
            end
            self:text(
                key,
                x,
                y + 29,
                "tiny",
                world.player.energy >= p.energy and colors.text or colors.red,
                44,
                "center"
            )
            self:hitArea("player:" .. def.id, x, y, 44, 44)
        end
        local lock = world.player.selfStunRemaining or 0
        if lock > 0 then
            local width = #Skills.player * 50 - 6
            color(colors.text, 0.65)
            g.rectangle(
                "fill",
                w / 2 - width / 2,
                h - 12,
                width * U.clamp(lock / (world.player.selfStunTotal or lock), 0, 1),
                2
            )
        end
        local speed = world.player.status.speed
        if speed then
            self:text(string.format("SPEED %.1fs", speed.remaining), 20, 72, "tiny", colors.bg)
        end
    end
    if world.training.noticeTimer > 0 and not overlay then
        self:text(world.training.notice, 1, 91, "medium", colors.bg, w, "center")
        self:text(world.training.notice, 0, 90, "medium", colors.gold, w, "center")
    end
    if world.settings.speed ~= 1 and not overlay then
        self:text(
            string.format("%.2f×", world.settings.speed),
            w / 2 - 50,
            47,
            "small",
            colors.bg,
            100,
            "center"
        )
    end
    if world.debug and not overlay then
        local p, cast = world.player, world.boss.cast
        self:panel(20, h - 184, 440, 100)
        self:text(
            string.format("DEBUG tick %.4fs · sim %.3fs", world.config.simulation.tick, world.time),
            32,
            h - 174,
            "tiny",
            colors.accent
        )
        self:text(
            string.format(
                "Reto %.4fs · diagonal %.4fs · gap %.4fs",
                world.config.movement.straightStep,
                world.config.movement.diagonalStep,
                world.config.movement.stepGap
            ),
            32,
            h - 153,
            "tiny"
        )
        self:text(
            string.format("Player %.3f, %.3f · passos %d · %s", p.rx, p.ry, p.steps, p.state),
            32,
            h - 132,
            "tiny"
        )
        self:text(
            "Boss "
                .. world.boss.state
                .. " · "
                .. (cast and cast.phase or "idle")
                .. " · latência "
                .. world.config.movement.latencyMs
                .. "ms",
            32,
            h - 111,
            "tiny"
        )
    end
    if world.menu or world.training.result or world.paused then
        color(colors.bg, 0.82)
        g.rectangle("fill", 0, 0, w, h)
        self.offsetX, self.offsetY = (w - 1280) / 2, (h - 820) / 2
        g.push()
        g.translate(self.offsetX, self.offsetY)
        if world.menu then
            self:drawMenu(world)
        elseif world.training.result then
            self:drawResult(world)
        else
            self.buttons = {}
            self:text("PAUSADO", 0, 350, "large", colors.text, 1280, "center")
            self:text(
                "P para continuar · Esc para abrir o menu",
                0,
                410,
                "body",
                colors.text,
                1280,
                "center"
            )
        end
        g.pop()
        self.offsetX, self.offsetY = 0, 0
    end
    -- Real rendering FPS, independent of simulation speed and visible in menus too.
    local fps = string.format("%d FPS", love.timer.getFPS())
    self:text(fps, w - 115, 48, "small", colors.bg, 96, "right")
    self:text(fps, w - 116, 47, "small", colors.text, 96, "right")
end

function Hud:drawTraining(world)
    local s = world.training.stats
    self:text("Combate", 200, 243, "medium", colors.accent)
    for i, m in ipairs(modes) do
        self:button(
            "mode:" .. m[1],
            m[2] .. " · " .. m[3],
            200 + ((i - 1) % 2) * 214,
            279 + math.floor((i - 1) / 2) * 42,
            204,
            34,
            world.settings.mode == m[1]
        )
    end
    self:text("Habilidade do treino individual", 200, 375, "small", colors.muted)
    self:button(
        "skill:next",
        Skills.boss[world.settings.practiceSkill].name .. " ›",
        200,
        400,
        418,
        34,
        false
    )
    self:text(Skills.boss[world.settings.practiceSkill].evidence, 200, 443, "tiny", colors.gold)
    self:button(
        "speed:next",
        string.format("Velocidade %.2f× ›", world.settings.speed),
        200,
        477,
        204,
        34,
        false
    )
    self:button(
        "frequency:next",
        string.format("Frequência %.2f× ›", world.settings.frequency),
        414,
        477,
        204,
        34,
        false
    )
    self:button(
        "difficulty:next",
        "Dificuldade: "
            .. world.config.training.difficultyPresets[world.settings.difficulty].name
            .. " ›",
        200,
        523,
        418,
        34,
        false
    )
    self:button(
        "toggle:telegraphs",
        "Avisos " .. (world.settings.telegraphs and "ON" or "OFF"),
        200,
        569,
        204,
        30,
        world.settings.telegraphs
    )
    self:button(
        "toggle:grid",
        "Grid " .. (world.settings.grid and "ON" or "OFF"),
        414,
        569,
        204,
        30,
        world.settings.grid
    )
    self:text("Tentativa " .. world.training.attempt, 674, 243, "medium", colors.accent)
    self:row("Sobrevivência (sim.)", string.format("%.1f s", s.time), 674, 286, 396)
    self:row("Dano recebido", tostring(math.floor(s.received)), 674, 323, 396)
    self:row(
        "Dano causado / DPS",
        string.format("%d / %.1f", s.dealt, world.training:dps()),
        674,
        360,
        396
    )
    self:row("Acertos recebidos", tostring(s.hits), 674, 397, 396)
    self:row("Passos", tostring(s.steps), 674, 434, 396)
    self:row("Mortes na sessão", tostring(world.training.deaths), 674, 471, 396)
    self:text("Dados de combate, sem pontuação.", 674, 526, "tiny", colors.muted)
    self:text("Alvida aproximada · parâmetros ainda estimados.", 674, 550, "tiny", colors.gold)
    self:button("restart", "Reiniciar [R / F6]", 674, 590, 192, 34, false)
    self:button("stop", "Encerrar tentativa", 878, 590, 192, 34, false)
end

function Hud:drawMenu(world)
    self.buttons = {}
    self:panel(170, 94, 940, 638)
    self:text("Menu", 198, 117, "title")
    self:text(
        "A simulação fica pausada enquanto você ajusta os parâmetros.",
        198,
        155,
        "small",
        colors.muted
    )
    if world.training.noticeTimer > 0 then
        self:text(world.training.notice, 790, 126, "tiny", colors.accent, 285, "right")
    end
    self:button("page:training", "Treinamento", 198, 184, 164, 34, self.page == "training")
    self:button("page:skills", "Shanks", 372, 184, 142, 34, self.page == "skills")
    self:button("page:calibration", "Calibração", 524, 184, 164, 34, self.page == "calibration")
    self:button("page:controls", "Controles", 698, 184, 164, 34, self.page == "controls")
    self:button("page:help", "Referências", 872, 184, 206, 34, self.page == "help")
    if self.page == "training" then
        self:drawTraining(world)
    elseif self.page == "skills" then
        for i, def in ipairs(Skills.player) do
            local y = 235 + (i - 1) * 49
            local p = world.config.playerSkills[def.id]
            color(colors.accent)
            Icons.draw(def.id, 204, y + 8, 24)
            self:text(def.name, 242, y, "body")
            self:text(def.note, 242, y + 22, "tiny", colors.muted, 650)
            self:text(
                string.upper(world.config.controls[def.action][1] or "sem tecla"),
                900,
                y,
                "small",
                colors.accent,
                165,
                "right"
            )
            self:text(
                string.format("%g EN · %gs CD", p.energy, p.cooldown),
                875,
                y + 22,
                "tiny",
                colors.muted,
                190,
                "right"
            )
        end
        self:text(
            "Vídeo: 3:00–7:00. Regras observadas; dano, tempos e colisões ainda aproximados.",
            200,
            644,
            "small",
            colors.gold
        )
    elseif self.page == "calibration" then
        local rows = {
            {
                "straight",
                "Passo reto",
                string.format("%.4f s", world.config.movement.straightStep),
                "estimado: ~296 px/s na gravação",
            },
            {
                "diagonal",
                "Passo diagonal",
                string.format("%.4f s", world.config.movement.diagonalStep),
                "estimado: ~147 px/s em cada eixo",
            },
            {
                "gap",
                "Intervalo extra",
                string.format("%.4f s", world.config.movement.stepGap),
                "não calibrado; padrão zero",
            },
            {
                "latency",
                "Latência adicional",
                world.config.movement.latencyMs .. " ms",
                "não calibrada; atraso nos comandos de gameplay",
            },
            {
                "sqm",
                "Tamanho visual do SQM",
                world.config.arena.sqm .. " px",
                "escala do simulador; não altera duração do passo",
            },
            {
                "windup",
                "Preparação do leque",
                string.format("%.3f s", world.config.bossSkills.fan.windup),
                "estimada; hitboxes em config.lua",
            },
        }
        for i, row in ipairs(rows) do
            local y = 239 + (i - 1) * 57
            self:text(row[2], 200, y, "body")
            self:text(row[4], 200, y + 23, "tiny", colors.muted)
            self:button("adjust:" .. row[1] .. ":-1", "−", 754, y, 38, 32, false)
            self:text(row[3], 800, y + 7, "body", colors.accent, 170, "center")
            self:button("adjust:" .. row[1] .. ":1", "+", 980, y, 38, 32, false)
        end
        self:button(
            "camera",
            world.config.camera.follow and "Câmera: acompanha jogador" or "Câmera: arena fixa",
            200,
            591,
            305,
            32,
            world.config.camera.follow
        )
        self:text("Zoom", 650, 600, "body")
        self:button("adjust:zoom:-1", "−", 754, 591, 38, 32, false)
        self:text(
            string.format("%.1f×", world.config.camera.zoom),
            800,
            598,
            "body",
            colors.accent,
            170,
            "center"
        )
        self:button("adjust:zoom:1", "+", 980, 591, 38, 32, false)
        self:text(
            "Move speed 300: dado informado. Fórmula interna do GLA não confirmada.",
            200,
            640,
            "small",
            colors.gold
        )
    elseif self.page == "controls" then
        for i, action in ipairs(bindingOrder) do
            local x = 200 + math.floor((i - 1) / 8) * 438
            local y = 237 + (i - 1) % 8 * 47
            self:text(bindingNames[action], x, y + 8, "body")
            self:button(
                "bind:" .. action,
                table.concat(world.config.controls[action], " / "),
                x + 150,
                y,
                252,
                34,
                self.rebinding == action
            )
        end
        self:text(
            self.rebinding
                    and ("Pressione a nova tecla para " .. bindingNames[self.rebinding] .. ". Esc cancela.")
                or "Clique num comando e pressione uma tecla. Aliases secundários ficam disponíveis.",
            200,
            635,
            "small",
            colors.gold
        )
        self:text(
            "Ctrl + direção gira sem caminhar. Esc abre o menu; P pausa. Reservadas: Ctrl, Esc, F1–F7.",
            200,
            659,
            "tiny",
            colors.muted
        )
    else
        local paragraphs = {
            "MOVIMENTO · Passo reto 1/3 s e diagonal 2/3 s são estimativas do vídeo do Killer com move speed 300. A simulação usa ticks de 1/120 s e não aplica aceleração ou stamina.",
            "ALVIDA · Clava e marca em leque têm referência visual. Tempos, dano e área ainda são aproximações. Clava dupla é provisória. Projéteis são exercício demonstrativo disponível no treino individual.",
            "SHANKS · Kenshi Speed [4] acelera a caminhada controlada pelo teclado, com transparência temporária e sem imunidade. Saltos frontal/traseiro, cortes e Haki estão descritos na aba Shanks. Valores numéricos estimados.",
            "TEMPO E DPS · Sobrevivência, cooldowns e DPS usam segundos da simulação. O CSV também registra tempo real ativo. Slow motion altera toda a simulação, inclusive movimentação e preparação.",
            "CALIBRAÇÃO · Edite config.lua e pressione F5. Shanks, boss e efeitos usam PNGs fornecidos. A aparência do boss não altera os padrões. Self-stun por skill em playerSkills; durações e hitboxes são estimadas.",
        }
        for i, text in ipairs(paragraphs) do
            self:text(
                text,
                200,
                244 + (i - 1) * 77,
                "small",
                i == 2 and colors.gold or colors.text,
                860
            )
        end
    end
    self:button("restore", "Restaurar config [F5]", 198, 682, 232, 32, false)
    self:button("save", "Salvar ajustes", 650, 682, 192, 32, false)
    self:button("menu", "Voltar ao jogo [Esc]", 854, 682, 224, 32, true)
end

function Hud:drawResult(world)
    self.buttons = {}
    local s = world.training.result
    self:panel(342, 206, 596, 394)
    self:text(
        s.reason,
        364,
        229,
        "large",
        s.reason == "Vitória" and colors.accent or colors.gold,
        552,
        "center"
    )
    self:text(
        "TENTATIVA " .. s.attempt .. " / " .. s.mode,
        364,
        282,
        "small",
        colors.muted,
        552,
        "center"
    )
    self:row(
        "Sobrevivência simulada / tempo real",
        string.format("%.2fs / %.2fs", s.time, s.realTime),
        372,
        325,
        536
    )
    self:row(
        "Dano recebido / dano causado",
        string.format("%d / %d", s.received, s.dealt),
        372,
        355,
        536
    )
    self:row("DPS (segundos de simulação)", string.format("%.1f", s.dps), 372, 385, 536)
    self:row("Acertos recebidos", tostring(s.hits), 372, 415, 536)
    self:row("Passos", tostring(s.steps), 372, 445, 536)
    self:row("Mortes nesta sessão", tostring(s.deaths), 372, 475, 536)
    self:text(
        "Resumo salvo em attempts.csv no diretório de dados do LÖVE.",
        372,
        515,
        "tiny",
        colors.muted,
        536,
        "center"
    )
    self:button("restart", "NOVA TENTATIVA [R / F6]", 372, 546, 264, 34, true)
    self:button("menu", "AJUSTAR TREINO [Esc]", 648, 546, 260, 34, false)
end

function Hud:click(x, y)
    for i = #self.buttons, 1, -1 do
        local b = self.buttons[i]
        if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            return b.id
        end
    end
end

local function cycle(current, choices)
    for i, v in ipairs(choices) do
        if current == v then
            return choices[i % #choices + 1]
        end
    end
    return choices[1]
end

function Hud:execute(action, world, reload)
    if action == "restart" then
        world:reset(true)
    elseif action == "menu" then
        world.menu = not world.menu
        self.rebinding = nil
        world.input:reset()
        if not world.menu then
            world.paused = false
        end
    elseif action == "pause" then
        world.paused = not world.paused
        world.input:reset()
    elseif action == "stop" then
        world:stop()
        world.menu = false
    elseif action == "restore" then
        reload()
    elseif action == "save" then
        local prefs = {
            training = world.settings,
            movement = world.config.movement,
            controls = world.config.controls,
            sqm = world.config.arena.sqm,
            camera = world.config.camera,
            bossSkills = world.config.bossSkills,
        }
        local ok, err = love.filesystem.write("settings.lua", "return " .. U.serialize(prefs))
        world.training:feedback(ok and "Ajustes salvos" or tostring(err))
    elseif action == "camera" then
        world.config.camera.follow = not world.config.camera.follow
    else
        local group, value, amount = action:match("^([^:]+):([^:]+):?(.*)$")
        if group == "page" then
            self.page = value
            self.rebinding = nil
        elseif group == "bind" then
            self.rebinding = value
        elseif group == "mode" then
            local menuOpen = world.menu
            world:setMode(value)
            world.menu = menuOpen
        elseif group == "skill" then
            world.settings.practiceSkill = cycle(world.settings.practiceSkill, Skills.order)
            if world.settings.mode == "practice" then
                local menuOpen = world.menu
                world:reset(true)
                world.menu = menuOpen
            end
        elseif group == "speed" then
            world.settings.speed = cycle(world.settings.speed, { 1, 0.75, 0.5, 0.25 })
        elseif group == "frequency" then
            world.settings.frequency = cycle(world.settings.frequency, { 1, 1.5, 2, 0.5, 0.75 })
        elseif group == "difficulty" then
            world.settings.difficulty =
                cycle(world.settings.difficulty, { "normal", "hard", "easy" })
        elseif group == "toggle" then
            world.settings[value] = not world.settings[value]
        elseif
            group == "player"
            and not world.paused
            and not world.menu
            and not world.training.result
        then
            for _, def in ipairs(Skills.player) do
                if def.id == value then
                    world.input:enqueueAction(def.action, world.time)
                    break
                end
            end
        elseif group == "adjust" then
            local delta = tonumber(amount)
            local m = world.config.movement
            if value == "straight" then
                m.straightStep = U.clamp(m.straightStep + delta / 60, 1 / 60, 2)
            elseif value == "diagonal" then
                m.diagonalStep = U.clamp(m.diagonalStep + delta / 60, 1 / 60, 3)
            elseif value == "gap" then
                m.stepGap = U.clamp(m.stepGap + delta / 60, 0, 1)
            elseif value == "latency" then
                m.latencyMs = U.clamp(m.latencyMs + delta * 10, 0, 500)
                world.input.latency = m.latencyMs
            elseif value == "sqm" then
                world.config.arena.sqm = U.clamp(world.config.arena.sqm + delta * 2, 24, 64)
            elseif value == "zoom" then
                world.config.camera.zoom = U.clamp(world.config.camera.zoom + delta * 0.1, 0.8, 2.5)
            elseif value == "windup" then
                world.config.bossSkills.fan.windup =
                    U.clamp(world.config.bossSkills.fan.windup + delta / 60, 1 / 60, 3)
            end
        end
    end
end

function Hud:rebind(key, world)
    if not self.rebinding then
        return false
    end
    if key == "escape" then
        self.rebinding = nil
        return true
    end
    if world.input:isTurnKey(key) or key:match("^f[1-7]$") then
        return true
    end
    local action = self.rebinding
    for name, keys in pairs(world.config.controls) do
        if name ~= action then
            for i = #keys, 1, -1 do
                if keys[i] == key then
                    table.remove(keys, i)
                end
            end
        end
    end
    local keys = world.config.controls[action]
    for i = #keys, 1, -1 do
        if keys[i] == key then
            table.remove(keys, i)
        end
    end
    keys[1] = key
    self.rebinding = nil
    world.input:reset()
    return true
end

return Hud
