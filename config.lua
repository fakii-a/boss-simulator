-- Units: world distances are SQMs; all durations are simulation seconds.
-- Reference analysis and uncertainty: docs/REFERENCIAS.md.
return {
    simulation = { tick = 1 / 120, maxFrameDelta = 0.25 },
    window = { width = 1280, height = 820, scale = 1 },
    arena = {
        cols = 27, rows = 21, sqm = 40,
        playerSpawn = { 11, 12 }, bossSpawn = { 16, 10 },
        obstacles = { {5,5}, {5,6}, {6,5}, {22,16}, {22,17}, {21,17}, {6,16}, {22,5} },
    },
    movement = {
        referenceMoveSpeed = 300, referenceSqmPixels = 99,
        straightStep = 1 / 3, diagonalStep = 2 / 3,
        stepGap = 0, latencyMs = 0, blockDiagonalCorners = true,
        bufferTap = true, -- one recent direction, never an unbounded queue
    },
    camera = { follow = true, zoom = 1.6 },
    controls = {
        up = {"w", "up", "kp8"}, down = {"s", "down", "kp2"},
        left = {"a", "left", "kp4"}, right = {"d", "right", "kp6"},
        northwest = {"kp7"}, northeast = {"kp9"},
        southwest = {"kp1"}, southeast = {"kp3"},
        basic = {"space"}, skill1 = {"1"}, skill2 = {"2"}, skill3 = {"3"}, skill4 = {"4"},
    },
    player = {
        hp = 1000, energy = 100, energyRegen = 8, defense = 0,
        hitRadius = 0.22, invulnerabilityOnHit = 0,
    },
    boss = {
        hp = 3600, defense = 2, hitRadius = 0.32,
        straightStep = 0.50, diagonalStep = 1.00,
        initialDelay = 1.50, betweenSkills = 1.10,
        attackTimeScale = 1.30, -- longer preparation/recovery/combos; slower projectiles
        acquisitionRange = 5, chase = true,
        rotation = {"club", "fan", "club", "combo"},
    },
    playerSkills = {
        -- Requested training dash. Values are provisional, not verified GLA data.
        dash = { cooldown = 5, energy = 15, windup = .10, selfStun = .10, lockMovement = true,
            sqms = 3, straightStep = .05, diagonalStep = .075, recovery = .12 },
        -- Haki Saber: wiki confirms 2 s cooldown / +5 energy. Other values estimated.
        basic = { cooldown = 2.0, windup = 0.10, duration = 0.10, damage = 65,
            energy = 0, energyGain = 5, range = 1.45, lockMovement = true, selfStun = 0.28 },
        cut = { cooldown = 3.0, windup = 0.22, duration = 0.15, damage = 170,
            energy = 18, range = 3, width = 1, lockMovement = true, selfStun = 0.45 },
        spin = { cooldown = 6.0, windup = 0.38, duration = 0.18, damage = 235,
            energy = 26, radius = 1.65, lockMovement = true, selfStun = 0.65 },
        shot = { cooldown = 4.0, windup = 0.18, duration = 0.12, damage = 120,
            energy = 16, speed = 8, radius = 0.14, lifetime = 2.5,
            lockMovement = true, selfStun = 0.40,
            status = { kind = "slow", duration = 1.2, multiplier = 1.35 } },
    },
    bossSkills = {
        club = { windup = 0.45, duration = 0.16, recovery = 0.38,
            cooldown = 2.0, damage = 105, range = 1, width = 1 },
        fan = { windup = 0.75, duration = 0.22, recovery = 0.52,
            cooldown = 4.0, damage = 190, range = 3, spread = 0.65,
            status = { kind = "slow", duration = 1.3, multiplier = 1.45 } },
        combo = { windup = 0.50, duration = 0.13, recovery = 0.50,
            cooldown = 5.0, damage = 90, range = 2, width = 1,
            count = 2, interval = 0.36 },
        volley = { windup = 0.80, duration = 0.12, recovery = 0.45,
            cooldown = 4.0, damage = 100, speed = 7, radius = 0.18,
            lifetime = 3, count = 3, angle = 0.19 },
    },
    training = {
        mode = "fight", practiceSkill = "fan", frequency = 1,
        difficulty = "normal", speed = 1, telegraphs = true, grid = true,
        difficultyPresets = {
            easy = { name = "Leve", damage = 0.65, windup = 1.30 },
            normal = { name = "Normal", damage = 1, windup = 1 },
            hard = { name = "Intenso", damage = 1.35, windup = 0.80 },
        },
    },
    provenance = {
        referenceMoveSpeed = "informado: Killer 300",
        playerSprite = "fornecida: Shanks; direções inferidas; diagonais reutilizam vistas cardinais",
        cameraZoom = "preferência visual: 1.6x; não medido no GLA",
        basic = "Haki Saber: wiki confirma recarga 2s e ganho 5; dano/alcance/timing estimados",
        selfStun = "solicitado pelo usuário; durações totais estimadas desde o início da skill",
        dash = "solicitado: dash de treino; alcance, tempo, custo e recarga ainda não calibrados",
        bossTempo = "ajuste de treino solicitado: tempos 30% maiores; não é calibração oficial",
        straightStep = "estimado: ~99px / ~296px/s no vídeo de caminhada",
        diagonalStep = "estimado: razão diagonal/reto ~2 no vídeo",
        hitboxes = "não calibradas: aproximações em SQMs",
        club = "forma observada; tempos/dano estimados",
        fan = "marca em leque observada; máscara/tempos estimados",
        combo = "provisório: ordem e intervalo não confirmados",
        volley = "demonstrativo: não observado em Alvida",
    },
}
