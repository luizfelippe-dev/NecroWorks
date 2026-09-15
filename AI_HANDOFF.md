# NecroWorks — Continuidade do Desenvolvimento

**Atualizado em:** 15/09/2026

## Estado atual

A v0.6.2 preserva a vertical slice técnica e revisa sua apresentação: menu ilustrado, HUD industrial com cartões e métricas alinhadas, sinergias roláveis e movimento procedural contínuo nas onze famílias. O ataque não é mais cancelado pelo flash de dano. Não foram produzidos frames novos de personagens; o shader trabalha sobre as poses V1, e a naturalidade ainda precisa de avaliação em uma run manual. Regras, economia e balanceamento permanecem intactos.

A auditoria de 14/09 reabriu confiabilidade, apresentação e validação comercial. O primeiro corte torna gameplay e temporizadores pausáveis, isola os checkpoints de testes e corrige o caminho consultado por Continuar. A auditoria anterior e seu gate técnico não comprovam prontidão comercial. Todos os novos itens e critérios estão na abertura de `docs/ROADMAP.md` (v0.6.3–v0.6.6).

## Ordem de continuação

1. seguir v0.6.4 por escala de interface e medição da primeira decisão; preparação, primeiro ciclo, consulta de sinergias e diagnóstico de gargalos já estão implementados;
2. preservar a suíte de confiabilidade e as fronteiras de apresentação concluídas na v0.6.3;
3. validar a experiência em run manual; o aceite técnico não certifica hardware mínimo nem prontidão comercial;
4. aprovar animação autoral de uma família e diferenciar os chefes;
5. revisar cartas, automação e testes de equilíbrio com investimentos equivalentes;
6. medir release real e conduzir teste cego antes da preparação Steam.

## Comandos

Narrativa, fábrica, rituais, doutrina, modificadores e loadout já possuem validação defensiva antes da restauração. O shell informa recuperação/proteção e falhas de gravação em três idiomas, com nova tentativa e pausa em caso de falha durante a run. As métricas por rota persistem no checkpoint; distribuição desconhecida de saves antigos é identificada como tal. A migração v1→v2 continua necessária e não deve ser removida.

```powershell
.\tools\validate_release.ps1 -GodotPath "C:\caminho\Godot_v4.7.1-stable_win64_console.exe"
```

- `F5`: aplicação completa.
- `F6`: gameplay direto.
- `Esc`: pausa.
- `F3`: depuração.

## Documentos principais

- `docs/RENDERED_PROFILING.md`: cenário reproduzível, comparação local de frames e limites da medição;

- `docs/PRESENTATION_UPDATE.md`: escopo, limitações e evidências da apresentação v0.6.2;
- `docs/PROJECT_STATE.md`: estado técnico;
- `docs/ROADMAP.md`: ordem e marcos;
- `docs/GAME_DESIGN.md`: regras e balanceamento;
- `docs/LORE.md`: mundo e narrativa;
- `docs/ARCHITECTURE.md`: fronteiras de código;
- `docs/ASSET_PROVENANCE.md`: origem e revisão dos assets;
- `docs/PLAYTEST_PROTOCOL.md`: validação com jogadores;
- `docs/RELEASE_GATES.md`: critérios de build e publicação.
