# Revisão visual e legibilidade — v0.7, 14/10/2026

Pedido do usuário: usar as folhas de `Pixel Art Skill Animations - Lightning`, diminuir invisibilidade e facilitar edição do código. Foram examinadas as seis folhas, suas dimensões, transparência e arquivos de frames. Elas são efeitos visuais escolhidos para este simulador, não uma nova referência das habilidades oficiais do GLA.

Invisibilidade agora dura **0,6 s**; velocidade continua **2 s**. É um ajuste solicitado para treino. Números anteriores nesta análise são históricos. A organização em quatro espaços, nomes de parâmetros mais claros e separação do fluxo do jogador mantém as regras de combate; os testes de regressão cobrem essa preservação.

Guia de edição: `EDITANDO-O-JOGO.md`. Mapeamento visual: `data/effects.lua`. Inventário das novas folhas: `assets/effects/lightning/inventory.json`.

# Revisão Shanks — v0.6, 14/10/2026

Fonte prioritária desta revisão: [vídeo fornecido, IuGgBNBXnGs, 3:00–7:00](https://www.youtube.com/watch?v=IuGgBNBXnGs&t=180s). Metadados da cópia local identificam o vídeo “O ÚLTIMO IMPERADOR DA ANTIGA GERAÇÃO: SHANKS O RUIVO !”, publicado em 01/10/2024. Foram examinados quadros extraídos e legendas automáticas em português; nomes e transcrição podem conter erros. Os nomes/ordem do kit foram conferidos na [wiki de Shanks](https://wiki.gla.com.br/index.php/Shanks), consultada em 14/10/2026. Vídeo e recortes são material de análise local e não entram nos pacotes do jogo.

Os timestamps abaixo localizam aproximadamente a **explicação na legenda do vídeo original**, não são medições quadro a quadro. Os recortes locais podem ter deslocamento de keyframe; seus rótulos não foram usados para alegar durações exatas.

| Trecho aproximado | Evidência | Decisão no simulador |
| --- | --- | --- |
| 3:00–3:05, repetição 3:18–3:28 | Salto para a frente com dano em área; uso ofensivo ou para fugir | Heroic Strike com deslocamento e impacto ao chegar |
| 3:06–3:17 | Corte que alcança os SQMs à frente; explicação menciona três posições e distância de dois SQMs | Kenshi Flurry usa máscara inicial 3 de largura × 2 de profundidade, a validar |
| 3:30–3:50 | Narrador corrige “dash” para speed; exige caminhar, invisibilidade temporária | Kenshi Speed não desloca automaticamente; buff controlado por input |
| 3:51–4:00 | Salto para trás e dano à frente; demonstração visual do recuo/corte | Ryusosen preserva orientação durante o recuo |
| 4:08–4:31 | Narração afirma ausência de imunidade e perda do aggro de NPCs | Continua vulnerável; boss não adquire alvo invisível; ataques comprometidos continuam por escolha local |
| 4:35–4:53 | Corte reto longo, incluindo laterais; narrador diz “se não me engano oito tiles” | Mighty Fissure: 3 de largura, 8 de alcance provisório |
| 4:54–5:09 | Três ondas ao redor do corpo; quadros mostram ícones de stun nos alvos | Haki Waves em três pulsos, cada um com dano e stun |
| 5:30–6:13 | Haki maior; explicação de execução por diferença de 11 níveis; menciona stun | Haki amplo com stun; execução por nível não aplicada ao boss |
| 6:15–6:42 | Combina saltos e cortes para reposicionar | Skills têm cooldowns independentes; encadeamento após recuperação |

## Estimativas que continuam abertas

Todos os custos/danos e cooldowns especiais usam escala de treino, não números oficiais. Não foi possível medir exatamente self-stun, aquisição de alvo, distância de salto, fator/duração do speed, máscara diagonal ou regras contra paredes/entidades. A versão de 2024 mostrada no vídeo pode diferir do GLA atual; nenhum patch posterior foi presumido.

Parâmetros iniciais: saltos de 2 SQMs, 0,10 s por segmento reto / 0,14 s diagonal, recuperação 0,18 s; speed 2 s e multiplicador 0,40 no tempo do passo; flurry 2×3; fissure 8×3; ondas com raio 1,65 e três pulsos separados por 0,80 s; Haki maior com raio 4,5. Duração de stun 0,45 s nas ondas e 2 s no Haki amplo. `config.lua` contém todos os valores e `provenance` identifica a origem.

Colisões dos saltos são conservadoras, sem atravessar obstáculos/entidades e sem invulnerabilidade. Um passo parcial é concluído continuamente. Ao recuar durante avanço, termina o segmento antes de recuar os dois SQMs; essa regra é local e precisa de comparação. Self-stun de início/recuperação foi mantido conforme pedido do usuário, com tempos estimados. A invisibilidade usa transparência visual e suspende novas decisões de alvo do boss solo, sem apagar efeitos já lançados. Hitboxes de áreas não são recortadas por paredes.

Efeitos usam as sequências autorizadas já disponíveis; não foram identificadas as texturas exatas de cada skill mostrada no vídeo. Os ícones pequenos da interface são desenhos próprios em código. A execução por diferença de nível não foi adicionada porque não há sistema de níveis e o vídeo não confirma sua aplicação a este boss.

## Histórico das referências anteriores

As seções abaixo registram as entregas anteriores. Afirmações sobre golpes genéricos ou ausência de habilidades especiais descrevem aquelas versões e são substituídas pela revisão v0.6 acima.

# Análise inicial — 13/10/2026

Fontes prioritárias: os três MKVs fornecidos pelo usuário. Todos: 1920 × 1080, 60 FPS. Durações: caminhada 22,450 s; Killer 23,833 s; Alvida/Yamato 31,133 s. Os quadros em `reference/` são material de análise, não assets do jogo e não entram no pacote executável.

## Observado / informado

- Move speed do Killer: **300**, informado pelo usuário. Não é convertido diretamente para pixels/segundo.
- Perspectiva superior oblíqua, personagem aproximadamente central, câmera acompanha deslocamento do mundo; HUD lateral, HP acima das entidades e atalhos inferiores.
- Movimento horizontal contínuo em aproximadamente 1,12–3,80 s e 4,27–6,25 s. Fluxo óptico mediano do cenário: cerca de 296 px/s. Diagonais sustentadas em aproximadamente 7,48–8,83 s e 10,70–12,63 s: aproximadamente 147 px/s por eixo. Razão de tempo diagonal/reto próxima de **2**; normalizar diagonal com sqrt(2) não reproduziria essa amostra.
- O deslocamento final de trechos corresponde aproximadamente a múltiplos de 98–100 px. **A medida em pixels não prova o tamanho interno do SQM**, nem a fórmula do move speed. Não há registro das teclas nem relógio de comandos.
- No vídeo do Killer: seleção de alvo com círculo vermelho, golpes de lâmina e efeitos de sangue próximos ao alvo; animações giratórias em aproximadamente 7–9 s; deslocamentos especiais em aproximadamente 15–17 s e 20–23 s. Não é possível atribuir todos os efeitos a uma tecla sem captura de inputs.
- Alvida: aproximação ao alvo, golpes de clava com arco escuro (por exemplo, 17,8–18,4 s e 22,2–22,6 s) e marcas em leque no chão (~15,4–16,8 s e ~22,6–24,0 s). Vários efeitos grandes pretos/elétricos são da Yamato ou se sobrepõem a ela. Não foram tratados como projéteis confirmados da Alvida.

## Parâmetros iniciais propostos antes da implementação

| Parâmetro | Inicial | Proveniência |
| --- | --- | --- |
| Move speed de referência | 300 | Informado pelo usuário |
| SQM aparente na gravação | ~98–100 px | Estimado por deslocamentos / cenário |
| Passo reto | 0,333333 s | Estimativa: ~99 px / ~296 px/s |
| Passo diagonal | 0,666667 s | Estimativa apoiada na razão ~2 observada |
| SQM renderizado | base 40 px; v0.2 com zoom 1,6× = 64 px | Escolha visual do simulador, independente do tempo |
| Primeiro comando | próximo tick de 1/120 s | Escolha local; latência real desconhecida |
| Latência adicional | 0 ms | Configurável; gravação não mede rede/input |
| Hitbox do personagem | raio 0,22 SQM no chão | Estimada; não usar dimensões do sprite como hitbox |
| Preparação da clava | 0,45 s | Estimada a partir das animações; dano exato não identificável |
| Preparação do leque | 0,75 s | Estimada; separação entre aviso, efeito e dano desconhecida |
| Alcance frontal | 3 SQMs | Aproximação do leque; máscara calibrável |
| Combo de duas clavas | 0,50 s + intervalo 0,36 s | Padrão provisório para treino; sequência não comprovada |
| Projétil de treino | 7 SQM/s | Demonstração técnica, fora da rotação padrão |
| HP, energia, dano e defesa | escala própria de treinamento | Não calibrados ao GLA |

## Limites e fontes complementares

Faltam input gravado, dano isolado sem ataques da Yamato, repetições suficientes para medir cooldown, confirmação de bloqueios de movimento, colisões de cantos, hitboxes e ordem das habilidades. As áreas de aviso coloridas e a rotação determinística são ferramentas deste simulador, não alegações sobre o GLA. Os ataques do jogador são exercícios genéricos de alcance, não uma implementação completa de Killer ou Yamato. Nenhum dash, stamina ou invulnerabilidade implícita foi adicionado ao jogador.

A [página do Killer](https://wiki.gla.com.br/Killer) lista habilidades; os [dados do módulo Killer](https://wiki.gla.com.br/index.php/M%C3%B3dulo%3AKiller) descrevem cortes frontais, sangramento e Backflip. A consulta direta do módulo apresentou autenticação, embora trechos estivessem disponíveis no índice de busca. Isso não foi usado para afirmar tempos de ataque, cooldowns ou reproduzir todas essas habilidades. A [página de Alvida](https://wiki.gla.com.br/index.php/Alvida) é de personagem jogável; não basta para inferir a IA do boss. Consulta em 13/10/2026.

## Como refinar

Compare trechos retos e diagonais separadamente. Divida duração entre centros de SQMs por número de passos; desconsidere começo/fim sem registro de tecla. Ajuste `config.lua`, pressione F5 e confira tempo e posição no F3. Use treino individual e telegráficos opcionais para isolar um ataque.

## Atualização v0.2: Shanks e cenário

O usuário forneceu `Image_2D_5264_6629.png` e indicou a pasta com as demais texturas. A pasta contém 13.815 PNGs. A imagem indicada e as folhas `Image_2D_2059_8444.png` e `Image_2D_2077_8463.png` mostram poses compatíveis de Shanks: 128 × 128, quatro regiões de 64 × 64 por folha. A orientação vertical e os recortes foram examinados visualmente. O mapeamento cardinal é inferido, e diagonais reutilizam vistas; ataques/morte não possuem sequências confirmadas. Texturas selecionadas de piso, árvore, arbusto e caixa estão no inventário `assets/inventory.json` e são incluídas no jogo. A arena não é uma cópia de um mapa original.

A [wiki de Shanks](https://wiki.gla.com.br/index.php/Shanks), consultada em 13/10/2026, informa para Haki Saber recarga 2, ganho de energia 5 e poder 15. O simulador usa 2 s e +5 de energia ao acertar. A condição do ganho, alcance, dano final, animação e preparação não foram confirmados; são estimativas configuráveis. O poder da wiki não é uma fórmula de dano. Golpes 1–3 permanecem demonstrativos; não foi reconstruído o restante do kit de Shanks.

Ctrl + direção e zoom 1,6× atendem aos ajustes pedidos pelo usuário. A duração dos passos continua baseada no vídeo do Killer com velocidade 300, sem afirmar que Shanks possui a mesma velocidade no GLA. O tamanho da sprite não participa das colisões.
