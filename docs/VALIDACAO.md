# Verificação v0.7 — 14/10/2026

Runtime: LÖVE 11.5 e LuaJIT instalados em `C:\Program Files\LOVE`.

- 27 módulos Lua passaram na verificação sintática. Fontes, dados, testes e manifestos foram formatados com StyLua 2.6.0, usando verificação de equivalência sintática (`--verify`); `python tools/format.py --check` passou.
- **64 testes passaram**: 49 de simulação e 15 de interface/recursos no LÖVE real. Relatório em `TEST-RESULTS.txt`.
- Seis folhas Lightning carregadas no runtime gráfico, com 4/4/5/5/4/8 frames. A troca de linha da VFX6 foi verificada, excluindo os dois espaços vazios finais. PNGs copiados byte a byte; hashes no inventário próprio do pack.
- Invisibilidade de 0,6 s termina antes do bônus de velocidade de 2 s; aquisição do alvo pelo boss retorna enquanto o bônus ainda está ativo. Nenhuma imunidade foi acrescentada.
- Separação do fluxo do jogador e renomeação de parâmetros cobertas pelos testes de regressão. Guia de edição manual incluído em `EDITANDO-O-JOGO.md`.
- Kenshi Speed exige direção, mantém colisão e vulnerabilidade; início/fim do buff retimam passos parciais sem teleporte. Lentidão e velocidade combinam seus multiplicadores.
- Invisibilidade impede novas aquisições do boss; ataques já preparados continuam e o alvo volta a ser adquirido depois.
- Saltos frontal/traseiro exercitados nas oito direções, com paredes, entidades, cantos, energia, cooldown e preservação da orientação. Recuo durante avanço conclui o segmento antes da mudança.
- Combo salto/recuo aplica dano a partir das posições finais; self-stun impede encadeamento antes da recuperação.
- Flurry/Fissure acertam faixas frontais; testes excluem retaguarda e SQMs fora da largura/alcance.
- Haki Waves causa exatamente três acertos e reaplica stun; Haki amplo atinge alvo distante sem execução por nível.
- Posições/energia comparadas a 30, 60 e 144 FPS; pausa, slow motion e reinício cobrem os estados novos.
- HUD real renderiza oito ícones, cinco abas do menu, HP verde, energia azul, avisos vermelhos e FPS. Botões respeitam latência e funcionam mesmo sem tecla associada.
- Testes anteriores de Ctrl, input, movimento, projéteis, dano, IA, treino, saída de slow motion, métricas sem pontos e viewport continuam passando.
- Capturas de jogo, menu e efeito atualizadas e inspecionadas.
- Pacotes `.love` e EXE portátil validados com a mesma suíte; ZIPs verificados por integridade e hashes em `dist/manifest.json`.

A validação confirma consistência do simulador, não igualdade numérica com GLA. A análise usou quadros e legendas da referência; não houve captura sincronizada de teclado nem medição controlada de latência/self-stun. As aproximações restantes estão em `REFERENCIAS.md` e `config.lua`.
