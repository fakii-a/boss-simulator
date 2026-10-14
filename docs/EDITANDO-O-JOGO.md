# Guia de edição do jogo

Trabalhe na pasta de código-fonte, que contém `main.lua`, `config.lua`, `src` e `assets`. Editar essa pasta não modifica automaticamente o EXE já empacotado. Faça uma cópia do arquivo antes de experimentar.

## Comece por estes arquivos

| Quero alterar… | Arquivo | Onde procurar |
| --- | --- | --- |
| Dano, custo, cooldown, alcance ou self-stun | `config.lua` | `playerSkills` |
| Invisibilidade e velocidade do Shanks | `config.lua` | `playerSkills.dash` |
| Tempo dos passos, câmera e resolução | `config.lua` | `movement`, `camera`, `window` |
| HP, rotação e ataques do boss | `config.lua` | `boss`, `bossSkills` |
| Spritesheet, duração e tamanho de um efeito | `data/effects.lua` | `sheets`, `player` |
| Nome, descrição e atalho lógico da skill | `data/skills.lua` | `player` |
| Teclas físicas | `config.lua` ou menu Esc | `controls` |
| Comportamento da habilidade | `src/player.lua` | `use`, `execute`, `emitAttack` |
| Saltos e recuo | `src/dash.lua` | `start`, `update` |
| Barras, menus e textos na tela | `src/hud.lua` | `draw`, `drawMenu` |

Os IDs internos preservam compatibilidade com os controles: `basic` = Haki Saber, `cut` = Heroic Strike, `spin` = Kenshi Flurry, `shot` = Ryusosen, `dash` = Kenshi Speed, `fissure` = Mighty Fissure, `waves` = Haki Waves e `haki` = Haoshoku Haki.

## Exemplo 1: mudar invisibilidade

Em `config.lua`, dentro de `playerSkills.dash`, os campos relevantes são:

```lua
buffDuration = 2,           -- Tempo do bônus de velocidade.
stepMultiplier = 0.40,     -- Cada passo leva 40% do tempo normal.
invisibilityDuration = 0.6, -- Tempo invisível, independente da velocidade.
```

Para testar 0,3 segundo, troque apenas `0.6` por `0.3`. Use **ponto decimal**, não vírgula. Zero desativa a invisibilidade; ela não concede imunidade. Salve e pressione **F5** no jogo para recarregar `config.lua` e reiniciar a tentativa. A duração conta a partir da execução, após `windup`.

## Exemplo 2: alterar uma habilidade

Em `playerSkills.cut`, aumente `damage` para alterar o dano do salto frontal. `sqms` controla quantos trechos ele percorre. `radius` controla a área atingida na chegada, em SQMs. `energy` é o custo e `cooldown` a recarga.

- `windup`: tempo até executar a habilidade.
- `selfStun`: bloqueio de comandos contado desde a ativação.
- `duration`: tempo em que a área de dano fica ativa; não é a duração do desenho.
- `recovery`: bloqueio adicional após terminar o salto.
- `count` e `interval`: número de pulsos e intervalo entre eles, usados pelas ondas.

Não use tempos negativos. Passos precisam de duração maior que zero; quantidade de SQMs/frames/pulsos deve ser inteira e positiva. Slow motion afeta todos esses tempos.

## Exemplo 3: trocar o efeito sem alterar o dano

Em `data/effects.lua`, a entrada `player.cut` define:

```lua
cut = {
    sheet = "lightning3",
    layout = "impact",
    duration = 0.45,
    width = 2.4,
    height = 3.2,
},
```

Para trocar o raio visual, mude `sheet` para `"lightning4"`. Para aumentar o desenho, altere `width`/`height`. `duration` controla a animação inteira; os frames são distribuídos por esse tempo. **Esses campos não aumentam dano, alcance ou hitbox.** Feche e abra o jogo após modificar `data/effects.lua`, outros módulos ou imagens; F5 recarrega apenas `config.lua`.

Layouts disponíveis: `forward` aponta na direção da espada, `impact` ancora a base do raio no chão, `radial` usa o diâmetro da área e `aura` centraliza um efeito pequeno. `vertical = true` em um efeito `forward` gira uma folha que originalmente aponta para baixo. Em `forward`, o comprimento vem do alcance da habilidade, e a largura visual vem de `data/effects.lua`.

## Adicionar uma spritesheet

1. Copie um PNG transparente para `assets/effects/`.
2. Adicione uma entrada em `Effects.sheets` de `data/effects.lua`:

```lua
meuEfeito = {
    path = "assets/effects/meu-efeito.png",
    frameWidth = 128,
    frameHeight = 128,
    frameCount = 8,
},
```

3. Use `sheet = "meuEfeito"` na habilidade desejada e reinicie o jogo.

O carregador lê da esquerda para a direita, linha por linha. O tamanho total precisa ser divisível pelo tamanho de cada frame. `frameCount` exclui espaços vazios no fim da folha: VFX6, por exemplo, tem dez espaços, mas apenas oito frames. Folhas Lightning não usam `flipY`; as texturas antigas do GLA têm orientação própria. Use apenas assets que você tenha autorização para utilizar; a licença do pack está em assets/effects/lightning/LICENSE.docx.

## Como o código funciona

`main.lua` recebe eventos do LÖVE. `src/game.lua` acumula tempo e executa a simulação em passos fixos de 1/120 s. Em cada passo, `src/player.lua` atualiza timers, preparação, comandos e movimento nessa ordem. `src/boss.lua` decide a próxima ação; `src/skill.lua` verifica as áreas/projéteis; `src/combat.lua` aplica dano e status.

`x/y` são o destino inteiro reservado no grid; `rx/ry` são a posição interpolada dos pés, usada para desenho e colisão. Por isso, não mova somente a sprite: use `src/movement.lua`. `src/dash.lua` cuida dos saltos forçados; Kenshi Speed é um status no jogador.

`src/renderer.lua`, `src/animation.lua`, `src/effects.lua` e `src/hud.lua` desenham o estado pronto. `src/spritesheet.lua` recorta as folhas regulares. Evite aplicar dano nessas funções de desenho: elas são chamadas a cada frame e isso faria o dano depender do FPS.

## Organização e validação

O código usa quatro espaços, UTF-8, nomes explícitos nos módulos principais e instruções em linhas separadas. `.editorconfig` ajuda seu editor a manter isso. `.stylua.toml` guarda o padrão do formatador [StyLua](https://github.com/JohnnyMorganz/StyLua); a ferramenta é opcional e não é necessária para jogar.

No PowerShell, dentro da pasta do projeto:

```powershell
# Execute o código que você acabou de editar.
& 'C:\Program Files\LOVE\love.exe' .

# Verifique regras de combate e carregamento gráfico.
& 'C:\Program Files\LOVE\lovec.exe' . --test

# Padronize a indentação (StyLua local ou instalado no PATH).
python tools/format.py

# Confira a formatação sem modificar os arquivos.
python tools/format.py --check

# Gere novamente o EXE portátil e os ZIPs; requer Python só para empacotar.
python tools/package.py
```

Se necessário, informe o caminho do formatador: `python tools/format.py --stylua 'C:\Ferramentas\stylua.exe'`. O script inclui `--verify`, que confere a equivalência sintática da formatação. O arquivo `docs/original-main.lua` é um registro histórico e fica fora da formatação. Python é usado apenas pelos utilitários de desenvolvimento.

Se aparecer erro de Lua, confira arquivo e linha indicados na tela: vírgulas entre campos, aspas em textos e pares `function/end`, `if/end` e `{}`. Mantenha uma alteração pequena por vez, teste e só então faça a próxima. Ajustes de movimento salvos pelo menu podem sobrepor valores no início; F5 usa os valores do arquivo para a sessão atual.
