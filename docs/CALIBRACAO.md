# Calibração do combate

Os valores de combate são parâmetros ajustáveis de treinamento. Eles não representam uma especificação oficial do GLA. Configure os tempos e alcances de acordo com o exercício desejado.

## Movimento e câmera

| Parâmetro | Padrão | Efeito |
| --- | --- | --- |
| `simulation.tick` | 1/120 s | Intervalo fixo de atualização |
| `movement.straightStep` | 1/3 s | Duração do passo reto |
| `movement.diagonalStep` | 2/3 s | Duração do passo diagonal |
| `movement.stepGap` | 0 s | Intervalo adicional entre passos |
| `movement.latencyMs` | 0 ms | Atraso opcional de input |
| `arena.sqm` | 40 px | Tamanho visual base do SQM |
| `camera.zoom` | 1,8× | Ampliação da câmera |
| `player.hitRadius` | 0,22 SQM | Raio da hitbox do jogador |

Para ajustar caminhada, compare o tempo necessário para percorrer uma quantidade fixa de SQMs. Calibre movimentos retos e diagonais separadamente. O tamanho da imagem, a resolução e o zoom não alteram a duração dos passos.

## Habilidades

Em `config.lua`, `playerSkills` contém dano, energia, alcance, recarga e restrições de movimento:

- `windup`: preparação antes da execução.
- `selfStun`: bloqueio de comandos contado desde a ativação.
- `duration`: janela ativa de dano.
- `cooldown`: intervalo até poder usar a habilidade novamente.
- `range`, `width` e `radius`: geometria do ataque em SQMs.
- `recovery`: bloqueio após concluir um salto.
- `count` e `interval`: quantidade de pulsos e tempo entre eles.

Kenshi Speed usa `buffDuration = 2`, `stepMultiplier = 0.40` e `invisibilityDuration = 0.6`. A invisibilidade e o bônus de velocidade têm timers independentes. Invisibilidade não impede receber dano.

## Limites do combate

Saltos respeitam paredes, entidades e cantos bloqueados. Um passo parcial termina continuamente antes de mudar a direção do deslocamento. Ataques em área não têm oclusão por paredes; projéteis usam colisão por segmento. Cada área acerta uma vez por alvo e por pulso.

O boss possui rotação configurável, seleção de alvo e busca de caminho. Durante a invisibilidade, ele suspende novas decisões de perseguição/ataque; habilidades já preparadas continuam. O simulador trabalha com um jogador, sem troca de alvo entre membros de um grupo ou progressão de níveis.

## Aplicar e conferir ajustes

Salve `config.lua` e pressione F5 para reiniciar a tentativa com os novos valores. F3 exibe hitboxes, grid, posições, estados e tempos. Use Skill Practice para repetir um padrão e Slow Motion para estudar a preparação e o momento do dano.

Alterações em módulos, spritesheets ou `data/effects.lua` exigem reiniciar o jogo. Veja [o guia de edição](EDITANDO-O-JOGO.md) para exemplos e comandos de validação.
