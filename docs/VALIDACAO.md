# Verificação da entrega v0.3 — 13/10/2026

- Runtime real: LÖVE 11.5 instalado em `C:\Program Files\LOVE` e LuaJIT de sua `lua51.dll`.
- Compilação dos módulos Lua verificada antes da execução dos testes.
- **43 testes passaram**, incluindo 32 testes de simulação e 11 de interface/recursos gráficos.
- HUD durante a luta contém apenas os botões de habilidades e menu, sem controles de treinamento fora dele. A arena usa toda a janela.
- Esc abre/fecha o menu e congela a simulação; Tab não aciona o menu. Inputs pendentes são limpos e a retomada não inicia passos indevidos.
- Janelas largas e altas verificadas: arena sem margens de interface, menu centralizado e áreas de clique alinhadas. Trocar modo dentro do menu mantém a simulação pausada.
- Capturas `preview.png` e `menu-preview.png` inspecionadas; contador de FPS visível no canto superior direito.
- Ctrl esquerdo/direito, oito direções, toque curto, teclas simultâneas/opostas, latência, liberação do modificador e giro durante um passo verificados sem passos extras.
- Sair de Slow Motion para Boss Fight, Skill Practice e Endless restaura 1×; o histórico preserva o modo e a velocidade da tentativa anterior.
- Haki Saber: cooldown, ganho de energia limitado ao máximo e ausência de ganho fora do alcance verificados.
- Carregamento real dos 12 frames de Shanks e cinco texturas do mapa, vistas de caminhada, efeito de corte, fallback de morte e zoom ajustável exercitados no LÖVE.
- Os oito PNGs incluídos foram comparados byte a byte aos arquivos da pasta indicada; hashes em `assets/inventory.json`.
- Mesma posição e número de passos a 30, 60 e 144 FPS; IA e dano também comparados entre 30 e 144 FPS.
- A janela do jogo foi aberta pelo runtime e a captura `preview.png` foi inspecionada.
- Telas de calibração, controles, ajuda, pausa, resumo e viewport escalado exercitadas no LÖVE real.
- O arquivo `.love` empacotado passou nos mesmos testes.
- ZIP portátil extraído, EXE com as DLLs incluídas executado: relatório com **43 testes passaram**. A gravação do relatório foi confirmada no diretório próprio do EXE.
- ZIPs e `.love` verificados com teste de integridade; hashes e tamanhos em `dist/manifest.json`.
- Vídeos foram analisados visualmente por quadros e o deslocamento do cenário medido por fluxo óptico. Isso fornece estimativas de movimentação, não comprova hitboxes internas, cooldowns nem rotação oficial.

Veja `TEST-RESULTS.txt` para o relatório. Não foi realizada uma comparação controlada lado a lado com captura de input do GLA. A fidelidade quantitativa de combate ainda exige calibração; clava dupla/projéteis estão identificados como provisórios/demonstrativos.
