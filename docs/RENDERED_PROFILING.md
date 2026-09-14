# Medição renderizada do gameplay

Atualizado em 14/09/2026.

## Cenário reproduzível

`tools/profile_rendered_gameplay.gd` executa o loop real do Godot, incluindo filhos, animações e desenho. Não instancia o shell nem grava o perfil ou a partida de quem joga. O cenário usa seed 6014, 20 esqueletos, 10 zumbis e 6 fantasmas na onda 18. Há 120 frames de aquecimento e 360 intervalos entre frames desenhados. O combate permanece ativo, portanto perdas durante a amostra são esperadas e registradas.

```powershell
& "C:\caminho\Godot_v4.7.1-stable_win64_console.exe" --path . --rendering-method gl_compatibility --resolution 1280x720 --fixed-fps 60 --script res://tools/profile_rendered_gameplay.gd --quit-after 1000 -- --label=hud_sample
```

Não usar `--headless`: o script rejeita essa configuração. O arquivo sai em `artifacts/performance/hud_sample.json`. A simulação avança a 60 passos por segundo simulado; vsync fica desligado para a amostra. Essa configuração não mede a experiência normal com sincronização vertical ligada.

## Comparação local — consolidação do HUD

Godot 4.7.1 debug, OpenGL Compatibility, Intel UHD Graphics 630, janela 1280×720 e viewport lógico 1920×1080. Antes: base e198c35 com as mesmas alterações locais preexistentes de cena/projeto. Depois: labels legadas removidas e refresh do dashboard consolidado.

| Intervalo entre frames | Antes | Depois |
|---|---:|---:|
| Média | 6,300 ms | 6,091 ms |
| P50 | 5,496 ms | 5,354 ms |
| P95 | 10,357 ms | 9,861 ms |
| P99 | 17,387 ms | 15,869 ms |

Ambas as amostras começaram com 36 aliados e terminaram com 33, quatro inimigos ativos, um abate e onda 18. Dados brutos locais: `hud_before.json` e `hud_after.json`.

É uma observação antes/depois, não uma demonstração estatística de ganho. Driver, caches, escalonamento e carga do sistema influenciam o resultado. Os intervalos incluem trabalho/agendamento do frame, não medem latência de GPU isolada. A memória registrada é a alocação estática monitorada pelo engine, não a RAM total do processo nem VRAM. Não converter essa amostra em requisitos mínimos ou FPS garantido.

## Próximas medições

- várias repetições antes/depois, alternadas e sem outras ferramentas de captura/teste em paralelo;
- export release com renderer padrão, vsync normal e hardware definido;
- sessões longas, outras resoluções e distribuição completa dos tempos de frame;
- memória total do processo e comportamento sob carga sustentada.

O runner headless de estresse continua útil como regressão parcial de CPU, mas não substitui esta medição nem QA manual.
