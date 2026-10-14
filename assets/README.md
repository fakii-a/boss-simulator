# Assets e animações

Os efeitos Lightning, de Frostwindz, ficam em `effects/lightning`. A licença está em `effects/lightning/LICENSE.docx`; o inventário com hashes está em `effects/lightning/inventory.json`.

## Efeitos Lightning

| Folha | Dimensões | Frame / quantidade | Aplicação |
| --- | --- | --- | --- |
| vfx1.png | 1024×128 | 256×128 / 4 | Haki Saber e Ryusosen |
| vfx2.png | 1024×128 | 256×128 / 4 | Kenshi Flurry |
| vfx3.png | 640×256 | 128×256 / 5 | Impacto do Heroic Strike |
| vfx4.png | 640×256 | 128×256 / 5 | Mighty Fissure, rotacionado na direção da espada |
| vfx5.png | 512×128 | 128×128 / 4 | Haki Waves e Haoshoku Haki |
| vfx6.png | 640×256 | 128×128 / 8 | Kenshi Speed e rastros dos saltos |

Frames em ordem de leitura, sem inverter Y. VFX6 tem cinco colunas e duas linhas; os dois últimos espaços vazios são ignorados. `data/effects.lua` configura folha, layout, duração e escala. `src/spritesheet.lua` valida as dimensões e recorta com quads; `src/effects.lua` seleciona o frame pelo tempo da simulação. As cores originais das folhas são preservadas; avisos de dano do boss continuam vermelhos.

O inventário de personagens, mapa e efeitos de impacto está em `inventory.json`.

## Personagens, mapa e impactos

| Arquivo | Uso |
| --- | --- |
| `player/Image_2D_5264_6629.png` | Shanks: quatro vistas |
| `player/Image_2D_2059_8444.png` | Shanks: segunda pose de caminhada |
| `player/Image_2D_2077_8463.png` | Shanks: terceira pose de caminhada |
| `tiles/Image_2D_6120_0069.png`, `Image_2D_6124_0071.png` | pisos de terra/areia, 32 × 32 |
| `tiles/Image_2D_1516_2895.png` | caixa, textura 64 × 64 com transparência |
| `tiles/Image_2D_1550_1712.png` | árvore, 64 × 64 |
| `tiles/Image_2D_1613_1473.png` | arbusto, 64 × 64 |
| `bosses/Image_2D_1512_8212.png`, `Image_2D_6535_9423.png`, `Image_2D_6537_9433.png` | espadachim: três folhas 128 × 128, 12 vistas/poses |
| `effects/Image_2D_2241_10054.png`, `2247_10055`, `2266_10056`, `2275_10057`, `2283_10058` | corte: cinco texturas 128 × 128 |
| `effects/Image_2D_3187_4173.png`, `3190_4182` | anel giratório: duas texturas 256 × 256 |
| `effects/Image_2D_1090_12279.png`, `1127_12285`, `1130_12291`, `1132_12296` | impacto: quatro texturas 256 × 256 |

As folhas dos personagens medem 128 × 128. O manifesto recorta quatro regiões 64 × 64 por folha e inverte o eixo Y de cada frame ao desenhar. São 12 frames por personagem, com sequência base → pose 2 → base → pose 3 sincronizada ao passo. Direções são configuradas nos manifestos. Diagonais usam vistas cardinais. Ausentes sequências corporais específicas de ataque e morte, usa-se idle, com sprite de efeito ou esmaecimento. Kenshi Speed usa caminhada acelerada e faíscas Lightning.

`src/effects.lua` seleciona os quadros pelo progresso em segundos da simulação, recorta margens transparentes com quads e corrige o eixo Y ao desenhar. Escala, rotação e cor são ajustes visuais locais. Os mesmos cortes são usados no projétil, que mantém colisão por segmento. Impactos aparecem nos acertos e nas colisões com paredes; os padrões de área do boss mostram impactos sobre suas células. Esses sprites não definem hitboxes.

`src/tiles.lua` corrige a orientação das texturas do cenário e ancora os objetos no SQM. Caixas bloqueiam os mesmos SQMs de antes, árvores/arbustos representam a borda bloqueada; suas copas são apenas visuais. A ordem de desenho considera a posição vertical dos pés/bases.

Para substituir o personagem/boss, coloque uma spritesheet aqui e configure `player/manifest.lua` ou `bosses/manifest.lua`. Quadros são numerados a partir de 1, por linha, da esquerda para a direita. `images={...}` permite várias folhas, continuando os índices entre elas; `image="..."` continua compatível com uma folha. Cada estado possui oito listas: N, NE, E, SE, S, SW, W, NW. Estados ausentes usam `idle`; direções ausentes usam S ou a primeira disponível. Caminhada usa o progresso real do passo. `flipY=true` corrige exportações invertidas; as origens são medidas no frame já orientado.

Exemplo: folha de quatro colunas e oito linhas, frames de 32 × 48 pixels:

```lua
local idle, walk = {}, {}
for direction = 1, 8 do
    local first = (direction - 1) * 4 + 1
    idle[direction] = { first }
    walk[direction] = { first, first+1, first+2, first+3 }
end
return {
    image = "assets/player/sheet.png",
    frameWidth = 32, frameHeight = 48, sqmPixels = 32,
    originX = 16, originY = 46, fps = 8,
    states = { idle = idle, walk = walk },
}
```

Adicione `attack` e `death` com seus índices se disponíveis. Dimensões e índices são validados; manifest inválido usa placeholder e registra erro em `renderer.player.error`/`renderer.boss.error`. `sqmPixels` calibra escala, sem modificar hitboxes em SQMs.
