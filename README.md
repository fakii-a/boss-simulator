# GLA Boss Fight Simulator

Versão **0.7**, jogável e offline em Lua + LÖVE 11.5. O kit de Shanks foi revisado a partir dos quadros e das legendas do [vídeo enviado, trecho 3:00–7:00](https://www.youtube.com/watch?v=IuGgBNBXnGs&t=180s). A principal correção é **Kenshi Speed: aumenta a velocidade de caminhada, exige comando de direção e não concede imunidade**. Os nomes das habilidades foram conferidos na [wiki de Shanks](https://wiki.gla.com.br/index.php/Shanks).

![Interface do simulador](docs/preview.png)

A arena ocupa toda a janela. Durante a luta aparecem barras finas de HP **verde**, energia **azul**, HP do boss, oito ícones com teclas/cooldowns e FPS. Uma linha discreta mostra o bloqueio das habilidades. Avisos inimigos continuam vermelhos. O grid fica desligado inicialmente; pode ser ativado no menu ou no F3. Preferências salvas de grid são respeitadas. Não há pontuação nem círculos de orientação.

**Esc abre e fecha o menu**, pausando a simulação. A aba **Shanks** explica os ícones e habilidades; Treinamento concentra os modos e dados da tentativa. Calibração, Controles e Referências completam o menu. Os ícones foram desenhados em código para esta interface; não são ícones extraídos do GLA.

![Menu de treinamento](docs/menu-preview.png)

![Impacto do salto e marcação do boss](docs/skill-preview.png)

## Efeitos e edição manual

As oito habilidades agora usam as seis spritesheets do pacote **Pixel Art Skill Animations – Lightning**, de Frostwindz, fornecido pelo usuário. Foram preservados os PNGs originais e a licença; o jogo usa cópias locais em `assets/effects/lightning`. Os efeitos não alteram dano ou hitboxes.

**Invisibilidade reduzida de 2 s para 0,6 s**, mantendo o bônus de velocidade em 2 s. O ajuste é uma preferência de treino, não uma medição do GLA.

O código foi formatado com quatro espaços; configurações de skills estão em campos separados, e o fluxo do jogador foi dividido em preparação, comandos e movimento. O [guia de edição manual](docs/EDITANDO-O-JOGO.md) explica onde mudar cada comportamento, com exemplos. A aparência fica em `data/effects.lua`; os números de combate ficam em `config.lua`.

## Shanks: kit e limites da reprodução

| Tecla | Habilidade | Comportamento implementado |
| --- | --- | --- |
| Espaço | Haki Saber | Ataque próximo no boss; segurar repete quando disponível; recupera 5 EN ao acertar |
| 1 | Heroic Strike | Salta até 2 SQMs à frente e causa dano em área ao chegar |
| 2 | Kenshi Flurry | Cortes numa faixa frontal de 3 SQMs de largura e 2 de profundidade |
| 3 | Ryusosen | Recua até 2 SQMs, mantém a orientação e corta à frente da posição final |
| 4 | Kenshi Speed | Acelera o movimento controlado pelo teclado por 2 s; fica semitransparente por 0,6 s; não desloca sozinho |
| 5 | Mighty Fissure | Golpe frontal longo: faixa de 3 SQMs de largura e alcance inicial de 8 SQMs |
| 6 | Haoshoku Haki Waves | Três pulsos de dano e stun na área próxima ao corpo |
| 7 | Haoshoku Haki | Dano e stun numa área maior |

**Os comportamentos têm referência no vídeo; os números são parâmetros iniciais de treino.** Energia, dano, cooldowns (exceto o básico), tempos, distâncias de salto, máscaras diagonais, colisões e duração do stun ainda não foram medidos com precisão. O apresentador descreve o alcance longo como aproximadamente oito tiles; isso não é uma medição. A execução instantânea de inimigos com diferença de nível mencionada no vídeo não é simulada: esta arena não tem progressão de níveis nem regra confirmada para execução de bosses.

Todas as skills mantêm self-stun. Ataques estacionários congelam imediatamente um passo em andamento; ele continua depois do bloqueio. Nos saltos, a preparação fica imóvel, o deslocamento é forçado e a recuperação bloqueia movimento/skills. Um SQM já iniciado termina continuamente, sem teleporte; ele conta no alcance se estiver na mesma direção do salto. Se for contrário, termina antes do recuo. Paredes, entidades e cantos bloqueiam saltos. Essas regras de colisão são aproximações conservadoras a validar no GLA.

Kenshi Speed usa `stepMultiplier = 0.40`: cada passo leva 40% do tempo habitual (2,5× a velocidade), durante 2 s. É uma estimativa configurável. Ativar ou terminar o buff preserva a posição interpolada de um passo. A invisibilidade dura 0,6 s e é mostrada como transparência para permitir enxergar o próprio personagem; **ele continua recebendo dano**. O boss deixa de iniciar perseguições/ataques enquanto o jogador está invisível, mas ataques já preparados continuam. Ao terminar, o boss retoma o único alvo. Essa é a aproximação de perda de aggro num treino solo; não representa a troca de alvo de um grupo.

Valores em `config.lua → playerSkills` (segundos da simulação):

| ID interno | Energia / CD | Preparação / self-stun | Outros parâmetros iniciais |
| --- | --- | --- | --- |
| basic | 0 / 2 s | 0,10 / 0,28 s | +5 EN no acerto; dano 65 |
| cut | 18 / 3 s | 0,22 / 0,22 s | 2 SQMs; 0,10 s reto / 0,14 s diagonal por trecho; recuperação 0,18 s; raio 1,5 |
| spin | 26 / 6 s | 0,38 / 0,65 s | faixa 2×3; dano 235 |
| shot | 16 / 4 s | 0,18 / 0,18 s | recuo 2 SQMs; tempos iguais ao salto frontal; corte 4×3 |
| dash | 15 / 5 s | 0,10 / 0,10 s | buff 2 s; multiplicador de passo 0,40; invisibilidade 0,6 s |
| fissure | 30 / 10 s | 0,45 / 0,72 s | faixa 8×3; dano 300 |
| waves | 30 / 14 s | 0,30 / 2,05 s | 3 pulsos, intervalo 0,80 s, raio 1,65; dano 95/pulso; stun 0,45 s/pulso |
| haki | 45 / 24 s | 0,50 / 0,90 s | raio 4,5; dano 360; stun 2 s |

Os IDs antigos `cut`, `spin`, `shot` e `dash` preservam os atalhos existentes; agora representam as habilidades listadas acima. `selfStun` é contado desde a ativação; a sequência de ondas também bloqueia ações até emitir o último pulso. Saltos adicionam a recuperação após o deslocamento. As áreas de dano acompanham o chão; os efeitos são visuais. As faixas e áreas não têm oclusão por paredes nesta versão. Projéteis do boss continuam colidindo com obstáculos.

O boss usa a sprite de espadachim fornecida e mantém os padrões de treino aproximados de Alvida. A aparência não o transforma num boss oficial daquele personagem. A caminhada normal continua calibrada pelos vídeos do **Killer com move speed 300**; essa velocidade ainda não foi confirmada para Shanks.

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
| Girar sem andar | Ctrl esquerdo ou direito + direção; funciona com WASD, setas e numpad |
| Haki Saber | Espaço; segurar repete quando disponível |
| Heroic Strike / Kenshi Flurry / Ryusosen | 1 / 2 / 3 |
| Kenshi Speed | 4 |
| Mighty Fissure / Haki Waves / Haoshoku Haki | 5 / 6 / 7 |
| Reiniciar instantaneamente | R ou F6 |
| Pausar / continuar | P |
| Abrir / fechar menu e pausar enquanto aberto | Esc |
| Boss Fight | F1 |
| Skill Practice | F2 |
| Endless | F4 |
| Slow Motion | F7 |
| Hitboxes, estados, grid e tempos | F3 |
| Recarregar config.lua e reiniciar | F5 |
| Próximo padrão individual | [ ou ] |
| Alternar velocidade / frequência | PageUp/PageDown; −/= |

Todos os controles de combate e direção são configuráveis em `config.lua` ou na página **Controles** do menu Esc. Clique numa ação e pressione uma tecla. Ctrl é reservado para girar; Esc e F1–F7 são reservadas à interface. Esc cancela a escolha de tecla quando um remapeamento está em andamento. Tab pode ser remapeado como tecla de gameplay. R e P podem ser usados por habilidades remapeadas; nesse caso, F6 reinicia e Esc permite pausar pelo menu. Teclas de ação usam os nomes do LÖVE (`space`, `kp7`, `up`, etc.); não dependem do repeat do Windows.

Preferências antigas recebem os atalhos 5–7 sem perder seus remapeamentos. Se uma tecla já estiver ocupada por outra ação salva, escolha uma tecla livre em Esc → Controles; o botão correspondente na barra funciona mesmo sem tecla atribuída. A tecla 4 anteriormente usada pelo dash de treino agora ativa Kenshi Speed.

O ataque básico procura o único boss e gira para ele; seu alcance é radial. As habilidades frontais seguem a direção definida por movimento ou Ctrl + direção e guardam direção/área no início da preparação. Ctrl durante um passo deixa o passo atual terminar e impede o próximo; não teleporta nem interrompe a interpolação. Soltar Ctrl com uma direção ainda pressionada volta a andar. Não há mira pelo mouse nesta versão. Botões da barra também executam as habilidades.

## Movimentação e calibração

- Simulação fixa em **1/120 s**; o FPS de desenho não determina a velocidade.
- Passo reto inicial **0,333333 s**; diagonal **0,666667 s**. A diagonal usa o dobro do tempo, conforme a razão observada no vídeo, sem normalização por sqrt(2).
- Primeiro passo começa no próximo tick após receber o comando. Segurar mantém passos; liberar conclui o passo atual. Um toque curto é preservado mesmo que pressione/solte entre ticks. Há apenas uma intenção recente de direção pendente, sem fila de dezenas de passos.
- O personagem atravessa o SQM com interpolação linear, sem aceleração. A direção pode mudar no próximo SQM. Inputs opostos cancelam o eixo correspondente.
- Paredes, caixas e entidades bloqueiam os passos. Origem e destino ficam reservados enquanto uma entidade anda. Diagonais entre cantos bloqueados são proibidas por padrão, com opção para recalibrar.
- A hitbox acompanha os pés interpolados, inclusive durante os saltos; o sprite não define a área de dano. Não há stamina ou invulnerabilidade automática no jogador padrão.
- Latência opcional atrasa press/release e habilidades em segundos da simulação. É uma aproximação de input, não uma emulação de rede do GLA.

Veja [docs/REFERENCIAS.md](docs/REFERENCIAS.md) para evidências, timestamps e limites da medição. **300 é o atributo informado para Killer**, não uma fórmula que converte automaticamente em pixels/s. O SQM base de 40 px com zoom 1,8× aparece como 72 px no layout 1280 × 820; essa escolha visual não altera o tempo dos passos.

No Esc → **Calibração**, ajuste passos, intervalo extra, latência, tamanho visual do SQM, preparação do leque e câmera. Em `config.lua`, também ajuste HP, energia, defesa, máscaras de alcance, hitboxes, dano, duração, cooldown, recuperação, velocidade de projéteis e rotação. A tabela `provenance` distingue dados informados, estimados e não calibrados.

F5 lê `config.lua` novamente e reinicia a tentativa. O botão **Salvar ajustes** guarda overrides em `settings.lua` no diretório de dados do LÖVE; eles são aplicados no próximo início. F5 ignora overrides salvos na sessão corrente. Para persistir a restauração, pressione **Salvar ajustes** após restaurar.

Janelas redimensionadas mantêm a arena ocupando toda a área, sem faixas pretas de interface. O HUD se ancora nas bordas e o menu fica centralizado. Ajuste o zoom em Esc → Calibração ou em `camera.zoom` (padrão 1,8); `window.scale` é um multiplicador adicional. `config.lua.window.width/height` controlam a resolução inicial; a interface tem referência 1280 × 820 e dimensões mínimas 960 × 615. Câmera acompanha jogador com limites da arena, ou pode ficar fixa. Preferências antigas de câmera preservam o novo zoom padrão.

## Boss e padrões

| Padrão | Uso | Evidência |
| --- | --- | --- |
| Clava | básico direcional, um SQM frontal | animação observada; timing e hitbox estimados |
| Impacto em leque | área frontal de até três SQMs, lentidão | marca em leque observada; dano/área/tempo estimados |
| Clava dupla | dois pulsos com intervalo fixo | padrão provisório de treinamento |
| Projéteis de treino | três lâminas, colisão com paredes e alvo | exercício demonstrativo, não observado em Alvida |

A rotação padrão é clava → leque → clava → combo, **definida para o simulador, não medida como rotação oficial**. Projéteis estão disponíveis em Skill Practice e podem ser acrescentados à rotação em `config.lua`. O boss seleciona o jogador, caminha por SQMs e usa busca de caminho para contornar caixas. Preparação captura direção/área; a sequência dupla mantém a mesma área. Cooldown por habilidade e intervalo entre habilidades são independentes. A frequência do treino divide cooldowns e intervalo, mantendo preparação e execução.

HP, danos, defesa, recuperação e restrições de movimento não estão calibrados à progressão original. Haki Saber tem recarga de 2 s e ganho de 5 de energia, conforme a [wiki de Shanks](https://wiki.gla.com.br/index.php/Shanks). Dano de 65, alcance de 1,45 SQM, preparação de 0,10 s e efeito de corte são aproximações. O ganho ocorre ao acertar nesta implementação; a condição exata não foi confirmada. O poder 15 da wiki não foi convertido diretamente em dano. O kit atual está descrito no início deste documento; a reprodução quantitativa ainda é aproximada. Os grandes efeitos da Yamato não foram atribuídos ao boss sem confirmação. Não há referência de Madera nesta entrega.

## Treinamento e métricas

Boss Fight termina com vitória ou morte. Skill Practice repete o padrão selecionado e recupera HP do boss quando necessário; Endless também recupera HP do boss e continua a rotação. Slow Motion inicia a luta com velocidade 0,5×; o botão alterna 1×, 0,75×, 0,5× e 0,25×. Selecionar Boss Fight, Skill Practice ou Endless restaura 1×, inclusive após reduzir manualmente a velocidade. A tentativa anterior é registrada com seu modo e velocidade anteriores. A dificuldade altera dano/preparação conforme os presets e é uma ferramenta local de treino.

O sistema de pontos foi removido: não há aviso “+1”, contagem de esquivas/falhas ou porcentagem de precisão. A remoção vale para a interface, o resumo e os novos CSVs. São mantidos apenas dados objetivos de combate, sem atribuir uma nota ao jogador.

Ataque básico e habilidades ofensivas do jogador possuem cooldowns e custos próprios. Defesa subtrai dano por acerto, com mínimo zero. Cada área ativa acerta uma vez por alvo/pulso; projéteis usam teste do segmento percorrido, evitando atravessar alvos ou paredes em altas velocidades. Lentidão e stun são estados reutilizáveis. Invulnerabilidade só existe quando configurada; o padrão é zero, inclusive após receber dano.

Esc → Treinamento mostra dano recebido, dano causado, DPS, acertos recebidos, passos, sobrevivência e mortes da sessão. Essas informações não ocupam espaço durante a luta. Tempos de combate e DPS usam segundos da simulação; o relatório também registra tempo real ativo. Pausa/menu não contam. Frames muito longos são limitados a 0,25 s para evitar uma recuperação brusca após travar/minimizar; nesses casos o relógio não tenta alcançar o tempo de parede perdido.

Fim, reinício ou encerramento geram resumo e CSV. `attempts.csv`, `settings.lua` e `test-results.txt` ficam em:

```text
%APPDATA%\LOVE\gla-boss-fight-simulator\
```

No **EXE portátil**, o diretório é `%APPDATA%\gla-boss-fight-simulator\`, sem a pasta intermediária `LOVE`, conforme o comportamento de [jogos empacotados do LÖVE](https://love2d.org/wiki/love.filesystem.isFused). Os dois formatos têm preferências e relatórios separados.

São guardadas até 100 tentativas da sessão no CSV; a sessão seguinte começa nova contagem e exporta o histórico novo. Mortes ficam preservadas entre reinícios e modos na sessão. Avisos coloridos podem ser desligados para treinar a leitura da preparação visual.

## Arquitetura

`main.lua` conecta callbacks do LÖVE, carregamento de configuração e interface. `src/game.lua` coordena os ticks. `movement/dash/input/arena/collision` cuidam dos SQMs, eventos, ocupação e geometria. `combat/skill/player/boss` implementam dano, estados, cooldowns, áreas, projéteis e IA. `training` registra dados de combate sem pontuação. `animation/spritesheet/effects/renderer/hud/skill_icons` desenham sem determinar resultados do combate. `data` descreve os ataques; parâmetros numéricos ficam centralizados em `config.lua`.

O protótipo original foi preservado em `docs/original-main.lua`. Os PNGs selecionados estão incluídos em `assets`, sem depender da pasta Downloads durante a execução. Shanks e boss usam três folhas 128 × 128 cada, com quatro vistas de 64 × 64; diagonais reutilizam vistas cardinais. Frames corporais específicos de ataque e morte não foram identificados: ataque combina pose e sprite de efeito; morte usa a pose esmaecida. As seis folhas Lightning são recortadas por `src/spritesheet.lua` e animadas em `src/effects.lua`; os efeitos anteriores continuam nos impactos/projéteis do boss. Chão, caixas e vegetação usam texturas fornecidas; a disposição da arena é própria do simulador. Veja [assets/README.md](assets/README.md) para o inventário e formato do carregador. Sprite, resolução e zoom não mudam o tamanho lógico das hitboxes.

## Referências necessárias para aproximar o jogo do GLA

O vídeo já esclareceu o funcionamento de Kenshi Speed e a estrutura do kit. Agora a prioridade é medir a caminhada normal, os saltos e os tempos exatos, depois um boss escolhido. Não é preciso enviar tudo de uma vez.

| Material | Como registrar | O que permite calibrar |
| --- | --- | --- |
| Shanks andando | 10–20 s em linha reta, diagonais, toques curtos, troca de direção e Ctrl; mostre move speed, buffs, equipamento, resolução, zoom, FPS e ping | duração dos passos, resposta ao input, escala e câmera |
| Saltos e Kenshi Speed | 5 repetições retas/diagonais; parado e andando; perto de parede, canto e inimigo; mostre tecla e tooltip | distância, colisão, fator/duração de velocidade, self-stun e momento da perda de aggro |
| Cada skill isolada | nome e tecla, tooltip completo, 3–5 usos; segure uma direção durante o golpe; teste alvos perto/longe e de lado | self-stun, alcance, hitboxes, custo, cooldown, acertos múltiplos e cancelamentos |
| Boss prioritário | nome, dificuldade e 2–3 lutas completas, preferencialmente solo; trechos parado e desviando, com HP visível | sequência, escolha de alvo, mudanças de fase, velocidade, avisos e momento do dano |
| Sprites e controles | identifique arquivos de personagem/efeito, ordem dos frames e direções quando souber; screenshot dos atalhos e da interface do GLA | animações corretas, tamanho dos personagens, aparência do mapa e controles |

Prefira os arquivos de vídeo originais a 60 FPS ou mais, velocidade normal, sem cortes durante uma ação, sem câmera lenta aplicada na edição e com teclado/atalhos visíveis quando possível. Informe timestamps dos exemplos relevantes. Evite efeitos de outros jogadores nos testes isolados. Nome da skill e tooltip ajudam a distinguir a mecânica de uma coincidência visual. O número de poder exibido não basta, sozinho, para determinar dano final.

Os próximos materiais mais úteis são **tooltips completos das skills do Shanks** e **uma gravação de caminhada com move speed e teclas visíveis**. Para medir self-stun, segure uma direção antes, durante e depois de cada habilidade. Informe também qual boss deve ser priorizado.

## Verificação

Execute testes no runtime real do LÖVE:

```powershell
& 'C:\Program Files\LOVE\lovec.exe' . --test
```

Os testes verificam FPS, oito direções, diagonais, toques curtos, input simultâneo, latência, cantos, entidades, hitbox interpolada, máscaras direcionais, cooldown/energia, defesa/imunidade, projéteis atravessando alvos pequenos, múltiplos pulsos, status, métricas, morte/vitória, treino sem fim, reinício, pathfinding e telas de interface. O processo retorna 0 no sucesso e 1 em falha, com relatório no console e no diretório de dados.

O empacotamento é reproduzível com `python tools/package.py` usando Python apenas durante desenvolvimento. O jogo e o pacote portátil não dependem de Python ou de bibliotecas de vídeo.
