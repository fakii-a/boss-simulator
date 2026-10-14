# Validação do projeto

Runtime: LÖVE 11.5 e LuaJIT. A suíte contém **64 testes**, sendo 49 de simulação e 15 de interface e recursos gráficos. O relatório está em `TEST-RESULTS.txt`.

## Cobertura

- Movimentação nas oito direções, passos diagonais, toques curtos, teclas opostas, Ctrl, latência, paredes, entidades e cantos.
- Equivalência de posição e combate em diferentes taxas de renderização.
- Cooldowns, energia, defesa, dano, morte, vitória, status e hitboxes interpoladas.
- Saltos frontal/traseiro, posição de chegada, preservação da direção e bloqueio durante recuperação.
- Kenshi Speed: mudança de velocidade sem teleporte, invisibilidade independente do buff e vulnerabilidade.
- Três pulsos de Haki, reaplicação de stun e faixa frontal de cortes.
- Colisão contínua de projéteis e acerto único por área/pulso.
- Comportamento do boss, busca de caminho, modos de treino, pausa, reinício e saída de slow motion.
- Carregamento de personagens, mapa, efeitos e folhas com múltiplas linhas de frames.
- Barras, ícones, menus, remapeamento, áreas de clique e redimensionamento da janela.

## Comandos

```powershell
& 'C:\Program Files\LOVE\lovec.exe' . --test
python tools/format.py --check
python tools/package.py
```

O processo de teste retorna 0 em sucesso e 1 em falha. O empacotador verifica a integridade dos arquivos ZIP e registra tamanhos e hashes em `dist/manifest.json`.

Os testes verificam as regras implementadas no simulador. Valores e limites de combate são descritos em [CALIBRACAO.md](CALIBRACAO.md).
