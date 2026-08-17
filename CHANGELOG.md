# Changelog

Todas as mudanças relevantes de **NecroWorks** são registradas neste arquivo.

O projeto segue versionamento incremental durante o protótipo. Funcionalidades ainda não fechadas em uma tag permanecem em **Unreleased**.

---

## [Unreleased] — v0.1.0 em desenvolvimento

### Added

- Upgrade selection entre Waves.
- Pool de 10 upgrades.
- Três opções aleatórias de upgrade por seleção.
- Upgrades acumuláveis.
- Sharpened Bones.
- Bone Plating.
- Efficient Recycling.
- Rapid Assault.
- Death March.
- Mass Production.
- Heavy Bones.
- Bone Harvest.
- Reassembly.
- Final Service.
- Sistema de sinergias.
- Recycling Plant.
- Second Shift.
- Bone Assembly Line.
- Overclocked Ossuary.
- HUD de sinergias ativas.
- Métricas da run:
  - Enemies Killed;
  - Corpses Processed;
  - Skeletons Built;
  - Skeletons Lost;
  - Skeletons Revived;
  - Bones Earned.

### Changed

- Bones por Corpse ajustado temporariamente para 8 durante prototipação.
- Dano base de Enemy ajustado temporariamente para 7.
- Próxima Wave agora aguarda escolha de upgrade.
- Skeleton Cost passa a ser exibido no HUD.
- Balanceamento geral permanece propositalmente provisório.

### Verified

- Overclocked Ossuary desbloqueou e realizou ataques duplos em playtest.
- Recycling Plant desbloqueou e dobrou o bônus de Bone Harvest.
- Second Shift desbloqueou e teve efeito observado em runtime.
- Bone Assembly Line teve desbloqueio validado; o proc de Skeleton gratuito ainda requer observação explícita em teste.
- Playtest longo alcançou Wave 21 sem erro de runtime aparente.

### Planned before v0.1.0 tag

- Boss Wave.
- Victory.
- Game Over.
- Run Summary.
- Restart Run.
- Teste completo da run.
- Atualização final de documentação.
- Balance pass inicial.

---

## [0.0.3] — 2026-08-17

### Added

- Wave counter.
- Quantidade definida de Enemies por Wave.
- Enemies Remaining.
- Delay entre Enemies.
- Estado Wave Complete.
- Scaling de HP por Wave.
- Scaling de dano por Wave.
- Elite Wave a cada 5 Waves.
- Wave HUD.
- Testes de progressão em Waves altas.

### Notes

O sistema foi validado funcionalmente antes do balanceamento definitivo.

---

## [0.0.2] — 2026-08-16

### Added

- Corpse.
- Bones.
- Processamento de Corpse.
- Criação de Skeleton.
- Múltiplos Skeletons.
- HP individual.
- Cooldown individual.
- Enemy respawn.
- Cenas reutilizáveis para Skeleton e Enemy.
- Migração de unidades de combate para Node2D.
- Visual placeholder garantido por código.
- Target-based movement.
- Enemy retarget.
- Debug HUD.

### Fixed

- Main não congela após a morte do último Skeleton.
- Unidades dinâmicas deixam de existir apenas logicamente e passam a ser renderizadas.
- Novos Skeletons deixam de nascer artificialmente na linha de frente.
- Movimentação global do exército foi substituída por perseguição baseada em alvo.

---

## [0.0.1] — 2026-08-14

### Added

- Projeto Godot inicial.
- Main scene.
- Background temporário.
- Skeleton temporário.
- Enemy temporário.
- Movimento automático.
- HP.
- Combate automático.
- Attack cooldown.
- Morte básica.
