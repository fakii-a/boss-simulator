# GLA Boss Fight Simulator

Simulador offline de combate em Lua e LÖVE 11.5 para praticar movimentação por SQMs, posicionamento, esquiva e uso de habilidades contra um boss.

![Arena e interface](docs/preview.png)

A arena ocupa toda a janela. O HUD mostra HP verde, energia azul, vida do boss, habilidades com cooldown e FPS. **Esc** abre o menu e pausa a simulação. As abas Treinamento, Shanks, Calibração, Controles e Ajuda concentram os ajustes e informações de combate.

![Menu](docs/menu-preview.png)

## Executar no Windows

Extraia `GLA-Boss-Fight-Simulator-Windows.zip` e abra **GLA Boss Fight Simulator.exe**. Mantenha as DLLs ao lado do executável. O pacote inclui o runtime e funciona sem conexão à internet.

Para executar e editar o código-fonte, instale [LÖVE 11.5](https://love2d.org/) e use o PowerShell:

```powershell
Set-Location 'C:\Users\fakii\Desktop\bossfightsimulator'
& 'C:\Program Files\LOVE\love.exe' .
```

O arquivo `dist/GLA-Boss-Fight-Simulator.love` também pode ser aberto com LÖVE. Alterações na pasta de fontes exigem um novo empacotamento para aparecer no EXE.

## Controles

| Ação | Teclas |
| --- | --- |
| Movimentar | WASD, setas ou numpad 2/4/6/8 |
| Diagonais | Duas direções simultâneas ou numpad 1/3/7/9 |
| Girar sem andar | Ctrl + direção |
| Haki Saber | Espaço; segurar repete quando disponível |
| Heroic Strike / Kenshi Flurry / Ryusosen | 1 / 2 / 3 |
| Kenshi Speed | 4 |
| Mighty Fissure / Haki Waves / Haoshoku Haki | 5 / 6 / 7 |
| Reiniciar | R ou F6 |
| Pausar / continuar | P |
| Abrir / fechar menu | Esc |
| Boss Fight / Skill Practice / Endless / Slow Motion | F1 / F2 / F4 / F7 |
| Exibir depuração | F3 |
| Recarregar config.lua e reiniciar | F5 |
| Alternar padrão individual | [ ou ] |
| Alternar velocidade / frequência | PageUp/PageDown; −/= |

Remapeie movimento e combate em **Esc → Controles** ou em `config.lua`. Ctrl, Esc e F1–F7 são reservados. Esc cancela um remapeamento em andamento. Habilidades também podem ser acionadas pelos ícones, mesmo sem tecla atribuída.

## Habilidades do Shanks

| Habilidade | Comportamento |
| --- | --- |
| Haki Saber | Espadada no boss próximo; recupera 5 de energia ao acertar |
| Heroic Strike | Salto frontal de até 2 SQMs, com dano em área na chegada |
| Kenshi Flurry | Cortes frontais com 3 SQMs de largura e 2 de profundidade |
| Ryusosen | Recuo de até 2 SQMs, mantendo a orientação, seguido de corte frontal |
| Kenshi Speed | Movimento 2,5× mais rápido por 2 s; invisibilidade de 0,6 s, sem imunidade |
| Mighty Fissure | Golpe frontal com alcance de 8 SQMs e largura de 3 SQMs |
| Haoshoku Haki Waves | Três pulsos de dano e stun ao redor do personagem |
| Haoshoku Haki | Dano e stun em área ampla |

![Heroic Strike](docs/skill-preview.png)

Todas as habilidades aplicam self-stun. Ataques estacionários congelam um passo em andamento e permitem retomá-lo após o bloqueio. Saltos têm preparação, deslocamento e recuperação; respeitam paredes, entidades e cantos. Um trecho já iniciado termina continuamente antes de mudar a direção do deslocamento.

Kenshi Speed exige comandos de movimento. A invisibilidade suspende novas decisões de ataque/perseguição do boss, mas habilidades já preparadas continuam e o jogador permanece vulnerável. O boss retoma o alvo quando a invisibilidade termina.

Alcance, dano, custos, tempos e hitboxes são parâmetros configuráveis de treinamento. O simulador não possui progressão de níveis ou execução instantânea por diferença de nível. Ataques em área não têm oclusão por paredes; projéteis colidem com obstáculos.

## Treinamento e métricas

- **Boss Fight:** termina com vitória ou morte.
- **Skill Practice:** repete o padrão escolhido e recupera o HP do boss quando necessário.
- **Endless:** mantém a rotação do boss até encerrar a tentativa ou o jogador morrer.
- **Slow Motion:** inicia em 0,5× para estudar preparação e esquiva. Os demais modos restauram 1×.

O boss utiliza clava, impacto em leque, clava dupla e projéteis. Configure a rotação em `config.lua`. Frequência ajusta cooldowns e intervalos; dificuldade ajusta dano e preparação.

O menu e o resumo mostram dano recebido, dano causado, DPS, acertos recebidos, passos, sobrevivência e mortes da sessão. Pausa e menu não contam no tempo ativo. Sobrevivência, cooldowns e DPS usam segundos da simulação; o CSV inclui tempo real ativo. Cada área causa um acerto por alvo e por pulso. Defesa reduz o dano; invulnerabilidade exige configuração explícita.

Reiniciar, encerrar ou terminar a luta gera um resumo e atualiza `attempts.csv`. Os arquivos de dados ficam em:

```text
Código-fonte / .love: %APPDATA%\LOVE\gla-boss-fight-simulator\
EXE portátil:        %APPDATA%\gla-boss-fight-simulator\
```

Os dois formatos mantêm preferências separadas. O histórico guarda até 100 tentativas da sessão.

## Configuração e edição

O movimento usa oito direções e ticks fixos de **1/120 s**. Passos retos levam **1/3 s** e diagonais **2/3 s**. Segurar uma direção mantém a caminhada; soltar termina o SQM atual. Teclas opostas cancelam o eixo. Ctrl gira sem iniciar um novo passo; um trecho em andamento termina normalmente.

O zoom padrão é **1,8×** e pode ser alterado em **Esc → Calibração → Zoom**. Um SQM de 40 px aparece com 72 px na resolução de referência de 1280 × 820. Zoom, resolução e sprites não alteram a geometria do combate.

| Ajuste | Arquivo |
| --- | --- |
| Movimento, câmera, HP, energia, dano, self-stun e cooldowns | `config.lua` |
| Nome e descrição das habilidades | `data/skills.lua` |
| Spritesheets, duração e tamanho visual dos efeitos | `data/effects.lua` |
| Manifestos de personagens | `assets/player/manifest.lua`, `assets/bosses/manifest.lua` |

Salve `config.lua` e pressione **F5** para reiniciar com os novos valores. Mudanças em módulos, imagens e `data/effects.lua` exigem reiniciar o jogo. **Salvar ajustes** grava preferências em `settings.lua`; F5 usa o arquivo de configuração para a sessão atual.

O código usa quatro espaços, UTF-8 e funções separadas para preparação, comandos e movimento. Consulte o [guia de edição](docs/EDITANDO-O-JOGO.md), a [calibração do combate](docs/CALIBRACAO.md) e a [documentação de assets](assets/README.md).

## Arquitetura e validação

`main.lua` conecta eventos do LÖVE; `src/game.lua` coordena a simulação. `movement`, `dash`, `input`, `arena` e `collision` cuidam dos SQMs e colisões. `combat`, `skill`, `player` e `boss` implementam combate e comportamento. `training` registra tentativas. `animation`, `spritesheet`, `effects`, `renderer`, `hud` e `skill_icons` desenham o estado do jogo.

```powershell
# Testar combate, interface e carregamento de assets.
& 'C:\Program Files\LOVE\lovec.exe' . --test

# Formatar Lua; exige StyLua local ou no PATH.
python tools/format.py
python tools/format.py --check

# Gerar .love, ZIP de fontes e pacote portátil.
python tools/package.py
```

Python e StyLua são ferramentas de desenvolvimento; o jogo não depende delas. Veja [a validação](docs/VALIDACAO.md) para a cobertura dos testes.

Os efeitos Lightning são de Frostwindz. A licença está em `assets/effects/lightning/LICENSE.docx`; as licenças do runtime acompanham o pacote portátil.
