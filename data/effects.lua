-- Aparência das habilidades: editar este arquivo não altera dano ou hitboxes.
-- duration: segundos da simulação; width/height/length: tamanhos visuais em SQMs.
local Effects = {}

-- Ordem dos frames: esquerda para direita, depois a próxima linha.
-- VFX6 possui 10 espaços na folha, mas apenas os primeiros 8 são frames.
Effects.sheets = {
    lightning1 = {
        path = "assets/effects/lightning/vfx1.png",
        frameWidth = 256,
        frameHeight = 128,
        frameCount = 4,
    },
    lightning2 = {
        path = "assets/effects/lightning/vfx2.png",
        frameWidth = 256,
        frameHeight = 128,
        frameCount = 4,
    },
    lightning3 = {
        path = "assets/effects/lightning/vfx3.png",
        frameWidth = 128,
        frameHeight = 256,
        frameCount = 5,
    },
    lightning4 = {
        path = "assets/effects/lightning/vfx4.png",
        frameWidth = 128,
        frameHeight = 256,
        frameCount = 5,
    },
    lightning5 = {
        path = "assets/effects/lightning/vfx5.png",
        frameWidth = 128,
        frameHeight = 128,
        frameCount = 4,
    },
    lightning6 = {
        path = "assets/effects/lightning/vfx6.png",
        frameWidth = 128,
        frameHeight = 128,
        frameCount = 8,
    },
}

-- forward: acompanha a direção da espada; impact: raio vertical ancorado no chão;
-- radial: ocupa a área circular; aura: efeito pequeno centralizado no personagem.
Effects.player = {
    basic = { sheet = "lightning1", layout = "forward", duration = 0.28, width = 1.2 },
    cut = { sheet = "lightning3", layout = "impact", duration = 0.45, width = 2.4, height = 3.2 },
    spin = { sheet = "lightning2", layout = "forward", duration = 0.40, width = 3 },
    shot = { sheet = "lightning1", layout = "forward", duration = 0.36, width = 3 },
    dash = { sheet = "lightning6", layout = "aura", duration = 0.48, width = 1.7, height = 1.7 },
    fissure = {
        sheet = "lightning4",
        layout = "forward",
        duration = 0.45,
        width = 3,
        vertical = true,
    },
    waves = { sheet = "lightning5", layout = "radial", duration = 0.55 },
    haki = { sheet = "lightning5", layout = "radial", duration = 0.65 },
    trail = { sheet = "lightning6", layout = "aura", duration = 0.20, width = 0.8, height = 0.8 },
}

return Effects
