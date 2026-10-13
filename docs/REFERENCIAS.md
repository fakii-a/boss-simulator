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
| SQM renderizado | 40 px | Escolha visual do simulador, independente do tempo |
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

Compare trechos retos e diagonais separadamente. Divida duração entre centros de SQMs por número de passos; desconsidere começo/fim sem registro de tecla. Ajuste `config.lua`, pressione F5 e confira tempo e posição no F3. Use treino individual e telegráficos opcionais para isolar um ataque. Não há spritesheets autorizadas fornecidas: os placeholders são desenhos originais produzidos pelo código. Nenhum recorte do GLA é usado como recurso gráfico do jogo.
