# Sprites autorizadas opcionais

A versão entregue usa placeholders originais desenhados em `src/animation.lua`. Nenhuma sprite foi extraída dos vídeos ou da wiki.

Coloque uma spritesheet autorizada aqui e crie `player/manifest.lua` ou `bosses/manifest.lua`. Quadros são numerados a partir de 1, por linha, da esquerda para a direita. Cada estado possui oito listas: N, NE, E, SE, S, SW, W, NW. Estados ausentes usam `idle`; direções ausentes usam S ou a primeira disponível. Caminhada usa o progresso real do passo.

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
