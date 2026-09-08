# NecroWorks — Continuidade do Desenvolvimento

**Atualizado em:** 08/09/2026

## Estado atual

A v0.5.0 está fechada. A v0.6.0 possui vertical slice funcional com 20 ondas, cinco famílias permanentes de mortos-vivos, três invasores, três chefes, Fábrica automatizada, progressão horizontal, narrativa, tutorial, localização, acessibilidade básica, arte por estados, VFX e áudio procedural.

As correções internas da auditoria estão implementadas: save transacional, checkpoint de início de onda, validação defensiva, recuperação e diagnóstico centralizados, gate de release, CI, matriz de resoluções, estresse e cinco estratégias. O quadro completo está em `docs/AUDIT_STATUS.md`.

## Ordem de continuação

1. executar uma run manual completa no build gerado pelo gate;
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

- `docs/PROJECT_STATE.md`: estado técnico;
- `docs/ROADMAP.md`: ordem e marcos;
- `docs/GAME_DESIGN.md`: regras e balanceamento;
- `docs/LORE.md`: mundo e narrativa;
- `docs/ARCHITECTURE.md`: fronteiras de código;
- `docs/ASSET_PROVENANCE.md`: origem e revisão dos assets;
- `docs/PLAYTEST_PROTOCOL.md`: validação com jogadores;
- `docs/RELEASE_GATES.md`: critérios de build e publicação.
