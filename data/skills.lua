return {
    player = {
        {
            id = "basic",
            action = "basic",
            name = "Haki Saber",
            kind = "melee",
            note = "Espadada no alvo próximo; recupera energia ao acertar.",
        },
        {
            id = "cut",
            action = "skill1",
            name = "Heroic Strike",
            kind = "leap",
            note = "Salto frontal e impacto em área na chegada. Distância: até 2 SQMs.",
        },
        {
            id = "spin",
            action = "skill2",
            name = "Kenshi Flurry",
            kind = "cells",
            note = "Cortes frontais: 3 SQMs de largura e 2 de profundidade.",
        },
        {
            id = "shot",
            action = "skill3",
            name = "Ryusosen",
            kind = "backstep",
            note = "Salto para trás e corte à frente, preservando a direção da espada.",
        },
        {
            id = "dash",
            action = "skill4",
            name = "Kenshi Speed",
            kind = "buff",
            note = "Velocidade por 2 s; use WASD. Invisível por 0,6 s, sem imunidade.",
        },
        {
            id = "fissure",
            action = "skill5",
            name = "Mighty Fissure",
            kind = "cells",
            note = "Corte longo: faixa de 3 SQMs, alcance de 8 SQMs.",
        },
        {
            id = "waves",
            action = "skill6",
            name = "Haoshoku Haki Waves",
            kind = "sequence",
            note = "Três ondas próximas ao corpo, com dano e stun por pulso.",
        },
        {
            id = "haki",
            action = "skill7",
            name = "Haoshoku Haki",
            kind = "circle",
            note = "Haki em área ampla e stun. Execução por diferença de nível não simulada.",
        },
    },
    boss = {
        club = {
            name = "Clava",
            kind = "cells",
            description = "Golpe direcional no SQM à frente.",
        },
        fan = {
            name = "Impacto em leque",
            kind = "cells",
            description = "Ataque frontal em área, com lentidão.",
        },
        combo = {
            name = "Clava dupla",
            kind = "sequence",
            description = "Dois golpes consecutivos na mesma área.",
        },
        volley = {
            name = "Projéteis de treino",
            kind = "projectile",
            description = "Três projéteis direcionados ao jogador.",
        },
    },
    order = { "club", "fan", "combo", "volley" },
}
