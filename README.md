<<<<<<< HEAD
# GLA Boss Fight Simulator

Versão 0.1 jogável, offline, em Lua + LÖVE 11.5.

![Interface do simulador](docs/preview.png)

## Executar no Windows

**Pacote portátil:** extraia `GLA-Boss-Fight-Simulator-Windows.zip` inteiro e abra `GLA Boss Fight Simulator.exe`. Mantenha as DLLs ao lado do EXE. O LÖVE está incluído; não precisa instalar GLA, Lua, Python ou conectar à internet.

**Código-fonte:** com [LÖVE 11.5](https://love2d.org/) instalado, execute no PowerShell:

```powershell
Set-Location 'C:\Users\fakii\Desktop\bossfightsimulator'
& 'C:\Program Files\LOVE\love.exe' .
```

Ou abra `dist\GLA-Boss-Fight-Simulator.love` com o LÖVE. O arquivo `.love` é um ZIP com `main.lua` na raiz. Para editar e calibrar, use a pasta de fontes; alterações nela não modificam o EXE já empacotado.

## Controles padrão

| Ação | Teclas |
| --- | --- |
| Movimentar | WASD, setas ou numpad 2/4/6/8 |
| Diagonais | duas direções simultâneas; numpad 1/3/7/9 |
| Ataque básico | Espaço; segurar repete quando disponível |
| Corte frontal | 1 |
| Corte circular | 2 |
| Lâmina lançada | 3 |
| Reiniciar instantaneamente | R ou F6 |
| Pausar / continuar | P ou Esc |
| Ajustes / controles / calibração | Tab |
| Boss Fight | F1 |
| Skill Practice | F2 |
| Endless | F4 |
| Slow Motion | F7 |
| Hitboxes, estados, grid e tempos | F3 |
| Recarregar config.lua e reiniciar | F5 |
| Próximo padrão individual | [ ou ] |
| Alternar velocidade / frequência | PageUp/PageDown; −/= |

Todos os controles de combate e direção são configuráveis em `config.lua` ou na página **Controles** do menu Tab. Clique numa ação e pressione uma tecla. Tab, Esc e F1–F7 são reservadas à interface. R e P podem ser usados por habilidades remapeadas; nesse caso, F6 e Esc continuam disponíveis para reinício/pausa. Teclas de ação usam os nomes do LÖVE (`space`, `kp7`, `up`, etc.); não dependem do repeat do Windows.

O ataque básico procura o único boss e gira para ele; seu alcance é radial. As habilidades frontais seguem a última direção de movimento e guardam direção/área no início da preparação. Não há mira pelo mouse nesta versão. Botões da barra também executam as habilidades.

## Movimentação e calibração

- Simulação fixa em **1/120 s**; o FPS de desenho não determina a velocidade.
- Passo reto inicial **0,333333 s**; diagonal **0,666667 s**. A diagonal usa o dobro do tempo, conforme a razão observada no vídeo, sem normalização por sqrt(2).
- Primeiro passo começa no próximo tick após receber o comando. Segurar mantém passos; liberar conclui o passo atual. Um toque curto é preservado mesmo que pressione/solte entre ticks. Há apenas uma intenção recente de direção pendente, sem fila de dezenas de passos.
- O personagem atravessa o SQM com interpolação linear, sem aceleração. A direção pode mudar no próximo SQM. Inputs opostos cancelam o eixo correspondente.
- Paredes, caixas e entidades bloqueiam os passos. Origem e destino ficam reservados enquanto uma entidade anda. Diagonais entre cantos bloqueados são proibidas por padrão, com opção para recalibrar.
- A hitbox acompanha os pés interpolados; o sprite não define a área de dano. Não há dash, stamina ou invulnerabilidade automática no jogador padrão.
- Latência opcional atrasa press/release e habilidades em segundos da simulação. É uma aproximação de input, não uma emulação de rede do GLA.

Veja [docs/REFERENCIAS.md](docs/REFERENCIAS.md) para evidências, timestamps e limites da medição. **300 é o atributo informado pelo usuário**, não uma fórmula que converte automaticamente em pixels/s. Os 40 px/SQM renderizados são escala visual local.

No Tab → **Calibração**, ajuste passos, intervalo extra, latência, tamanho visual do SQM, preparação do leque e câmera. Em `config.lua`, também ajuste HP, energia, defesa, máscaras de alcance, hitboxes, dano, duração, cooldown, recuperação, velocidade de projéteis e rotação. A tabela `provenance` distingue dados informados, estimados e não calibrados.

F5 lê `config.lua` novamente e reinicia a tentativa. O botão **Salvar ajustes** guarda overrides em `settings.lua` no diretório de dados do LÖVE; eles são aplicados no próximo início. F5 ignora overrides salvos na sessão corrente. Para persistir a restauração, pressione **Salvar ajustes** após restaurar.

Janelas redimensionadas preservam o layout com escala e margens; `window.scale` modifica o zoom do mundo. `config.lua.window.width/height` controlam a resolução inicial; o layout tem referência 1280 × 820 e dimensões mínimas 960 × 615. Câmera acompanha jogador com limites da arena, ou pode ficar fixa.

## Boss e padrões

| Padrão | Uso | Evidência |
| --- | --- | --- |
| Clava | básico direcional, um SQM frontal | animação observada; timing e hitbox estimados |
| Impacto em leque | área frontal de até três SQMs, lentidão | marca em leque observada; dano/área/tempo estimados |
| Clava dupla | dois pulsos com intervalo fixo | padrão provisório de treinamento |
| Projéteis de treino | três lâminas, colisão com paredes e alvo | exercício demonstrativo, não observado em Alvida |

A rotação padrão é clava → leque → clava → combo, **definida para o simulador, não medida como rotação oficial**. Projéteis estão disponíveis em Skill Practice e podem ser acrescentados à rotação em `config.lua`. O boss seleciona o jogador, caminha por SQMs e usa busca de caminho para contornar caixas. Preparação captura direção/área; a sequência dupla mantém a mesma área. Cooldown por habilidade e intervalo entre habilidades são independentes. A frequência do treino divide cooldowns e intervalo, mantendo preparação e execução.

HP, energia, danos, defesa, recuperação e restrições de movimento não estão calibrados à progressão original. Ataques do jogador são exercícios genéricos e não recebem nomes de habilidades específicas de Killer/Yamato. Os grandes efeitos da Yamato não foram atribuídos ao boss sem confirmação. Não há referência de Madera nesta entrega.

## Treinamento e métricas

Boss Fight termina com vitória ou morte. Skill Practice repete o padrão selecionado e recupera HP do boss quando necessário; Endless também recupera HP do boss e continua a rotação. Slow Motion inicia a luta com velocidade 0,5×; o botão alterna 1×, 0,75×, 0,5× e 0,25×. A dificuldade altera dano/preparação conforme os presets e é uma ferramenta local de treino.

Esquiva bem-sucedida significa: **um padrão ameaçou a hitbox durante aviso ou execução, o jogador iniciou pelo menos um passo desde o início desse aviso, e nenhum golpe desse padrão o acertou até ele terminar**. Cada combo/rajada conta uma vez, mesmo com múltiplos acertos. Falha é um padrão que acertou. Precisão = esquivas / (esquivas + falhas). Padrões sem ameaça, posicionamento já seguro e acertos bloqueados por invulnerabilidade não aumentam a precisão. Se não houver amostras, aparece `—`.

Ataque básico e habilidades ofensivas do jogador possuem cooldowns e custos próprios. Defesa subtrai dano por acerto, com mínimo zero. Cada área ativa acerta uma vez por alvo/pulso; projéteis usam teste do segmento percorrido, evitando atravessar alvos ou paredes em altas velocidades. Lentidão e stun são estados reutilizáveis. Invulnerabilidade só existe quando configurada; o padrão é zero, inclusive após receber dano.

HUD mostra dano recebido, dano causado, DPS, precisão, sobrevivência e mortes da sessão. Tempos de combate e DPS usam segundos da simulação; o relatório também registra tempo real ativo. Pausa/menu não contam. Frames muito longos são limitados a 0,25 s para evitar uma recuperação brusca após travar/minimizar; nesses casos o relógio não tenta alcançar o tempo de parede perdido.

Fim, reinício ou encerramento geram resumo e CSV. `attempts.csv`, `settings.lua` e `test-results.txt` ficam em:

```text
%APPDATA%\LOVE\gla-boss-fight-simulator\
```

No **EXE portátil**, o diretório é `%APPDATA%\gla-boss-fight-simulator\`, sem a pasta intermediária `LOVE`, conforme o comportamento de [jogos empacotados do LÖVE](https://love2d.org/wiki/love.filesystem.isFused). Os dois formatos têm preferências e relatórios separados.

São guardadas até 100 tentativas da sessão no CSV; a sessão seguinte começa nova contagem e exporta o histórico novo. Mortes ficam preservadas entre reinícios e modos na sessão. Avisos coloridos podem ser desligados para treinar a leitura da preparação visual.

## Arquitetura

`main.lua` conecta callbacks do LÖVE, carregamento de configuração e interface. `src/game.lua` coordena os ticks. `movement/input/arena/collision` cuidam dos SQMs, eventos, ocupação e geometria. `combat/skill/player/boss` implementam dano, estados, cooldowns, áreas, projéteis e IA. `training` calcula métricas. `animation/renderer/hud` desenham sem determinar resultados do combate. `data` descreve os ataques; parâmetros numéricos ficam centralizados em `config.lua`.

O protótipo original foi preservado em `docs/original-main.lua`. O runtime usa placeholders próprios, sem arquivos internos do GLA. Para spritesheets autorizadas, siga [assets/README.md](assets/README.md). Sprite, resolução e zoom não mudam o tamanho lógico das hitboxes.

## Verificação

Execute testes no runtime real do LÖVE:

```powershell
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

Os testes verificam FPS, oito direções, diagonais, toques curtos, input simultâneo, latência, cantos, entidades, hitbox interpolada, máscaras direcionais, cooldown/energia, defesa/imunidade, projéteis atravessando alvos pequenos, múltiplos pulsos, status, métricas, morte/vitória, treino sem fim, reinício, pathfinding e telas de interface. O processo retorna 0 no sucesso e 1 em falha, com relatório no console e no diretório de dados.

O empacotamento é reproduzível com `python tools/package.py` usando Python apenas durante desenvolvimento. O jogo e o pacote portátil não dependem de Python ou de bibliotecas de vídeo.
=======
# boss-simulator
A 2D boss fight training simulator inspired by Grand Line Adventures (GLA), built with Lua and LÖVE2D. Focused on improving movement, dodging, timing, and combat skills through challenging boss encounters and customizable training modes.
>>>>>>> e7980029c005a18acfa4f2c96ef0984d3aecfe42
