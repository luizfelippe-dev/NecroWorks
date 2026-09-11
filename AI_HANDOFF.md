# NecroWorks — Continuidade do Desenvolvimento

**Atualizado em:** 11/09/2026

## Estado atual

A v0.6.2 preserva a vertical slice técnica e revisa sua apresentação: menu ilustrado, HUD industrial com cartões e métricas alinhadas, sinergias roláveis e movimento procedural contínuo nas onze famílias. O ataque não é mais cancelado pelo flash de dano. Não foram produzidos frames novos de personagens; o shader trabalha sobre as poses V1, e a naturalidade ainda precisa de avaliação em uma run manual. Regras, economia e balanceamento permanecem intactos.

As correções internas da auditoria estão implementadas: save transacional, checkpoint de início de onda, validação defensiva, recuperação e diagnóstico centralizados, gate de release, CI, matriz de resoluções, estresse e cinco estratégias. O aceite está em `docs/VERTICAL_SLICE_ACCEPTANCE.md`; o quadro completo, em `docs/AUDIT_STATUS.md`.

## Ordem de continuação

1. executar uma run manual completa na v0.6.2, observando caminhada/ataque, lotes e rolagem das sinergias;
2. revisar PT-BR, inglês e espanhol com leitores nativos;
3. testar escala do Windows e hardware mínimo/recomendado;
4. conduzir a primeira rodada cega de 5–10 pessoas;
5. corrigir os três maiores problemas observados;
6. congelar o escopo da demo e produzir áudio/arte finais com direitos revisados;
7. preparar página, depot e Steam Playtest.

## Comandos

```powershell
.\tools\validate_release.ps1 -GodotPath "C:\caminho\Godot_v4.7.1-stable_win64_console.exe"
```

- `F5`: aplicação completa.
- `F6`: gameplay direto.
- `Esc`: pausa.
- `F3`: depuração.

## Documentos principais

- `docs/PRESENTATION_UPDATE.md`: escopo, limitações e evidências da apresentação v0.6.2;
- `docs/PROJECT_STATE.md`: estado técnico;
- `docs/ROADMAP.md`: ordem e marcos;
- `docs/GAME_DESIGN.md`: regras e balanceamento;
- `docs/LORE.md`: mundo e narrativa;
- `docs/ARCHITECTURE.md`: fronteiras de código;
- `docs/ASSET_PROVENANCE.md`: origem e revisão dos assets;
- `docs/PLAYTEST_PROTOCOL.md`: validação com jogadores;
- `docs/RELEASE_GATES.md`: critérios de build e publicação.
