# Sprites fornecidas e carregador

A versão 0.2 usa PNGs da pasta `Grand Line Adventures/Frame_098906/LanSPR` indicada pelo usuário. Os arquivos foram copiados sem alterar seus bytes; o inventário e os hashes estão em `inventory.json`. Não é preciso manter essa pasta externa para jogar. O boss continua desenhado por código.

| Arquivo | Uso |
| --- | --- |
| `player/Image_2D_5264_6629.png` | Shanks: folha indicada, quatro vistas |
| `player/Image_2D_2059_8444.png` | Shanks: segunda pose de caminhada |
| `player/Image_2D_2077_8463.png` | Shanks: terceira pose de caminhada |
| `tiles/Image_2D_6120_0069.png`, `Image_2D_6124_0071.png` | pisos de terra/areia, 32 × 32 |
| `tiles/Image_2D_1516_2895.png` | caixa, textura 64 × 64 com transparência |
| `tiles/Image_2D_1550_1712.png` | árvore, 64 × 64 |
| `tiles/Image_2D_1613_1473.png` | arbusto, 64 × 64 |

As folhas do personagem medem 128 × 128. O manifesto recorta quatro regiões 64 × 64 por folha e inverte o eixo Y de cada frame ao desenhar. São 12 frames, com sequência base → pose 2 → base → pose 3 sincronizada ao passo. Direções foram inferidas visualmente e podem ser ajustadas na tabela `views`. Diagonais usam a vista cardinal mais próxima; o marcador sob os pés mostra a direção lógica exata. Ausentes sequências específicas de ataque e morte, usa-se idle, com corte procedural ou esmaecimento. Nenhuma animação original de habilidade foi afirmada como reconstruída.

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
