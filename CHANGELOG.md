# Changelog

## [Unreleased] — v0.2.0 em desenvolvimento

### Planned

- sistema multi-resource;
- Flesh;
- Blood;
- Souls;
- primeiro novo Undead;
- expansão da economia necromântica;
- início da adaptação da UI à direção visual oficial.

---

## [0.1.0] — First Run — funcionalmente validado

### Added

- Upgrade selection entre Waves.
- Pool de 10 upgrades.
- Três escolhas aleatórias por Wave.
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
- Synergy HUD.
- Run Metrics.
- Boss Wave 20.
- Primeiro Boss: The Foreman.
- Industrial Crush multi-target.
- Victory.
- Game Over.
- Run Summary.
- Restart Run após Victory e Defeat.
- Tracking de Corpses para condição de derrota.

### Changed

- Enemy/Boss passa a lutar em lane horizontal controlada.
- Formação de Skeletons fecha lacunas após mortes.
- Enemy/Boss e posições de combate possuem limites de arena.
- Próxima Wave aguarda escolha de upgrade.
- HUD exibe Skeleton Cost.
- Debug exibe Corpses e possibilidade de reconstrução.

### Fixed

- Main não congela após perda total do exército.
- Enemy/Boss não deve mais ser arrastado para fora da tela pelo feedback da formação.
- Formação não mantém buracos permanentes que puxavam o combate para fora da arena.
- Game Over não acontece enquanto ainda houver Corpse processável ou Bones suficientes para reconstruir.

### Verified

- primeira run completa validada;
- Waves 1–20 funcionais;
- Elite Waves funcionais;
- The Foreman funcional;
- Industrial Crush funcional;
- Victory funcional;
- Defeat funcional;
- Run Summary funcional;
- Restart funcional;
- Overclocked Ossuary observado em runtime;
- Recycling Plant observado em runtime;
- Second Shift observado em runtime;
- Bone Assembly Line teve unlock validado.

### Balance

Os números atuais **não representam balanceamento final**.

Problemas conhecidos:

- crescimento da horda pode acontecer cedo demais;
- economia de Bones pode saturar;
- muitos Enemies comuns deixam de pressionar uma horda grande;
- upgrades multiplicativos podem escalar rápido;
- Elite/Boss precisarão ser reavaliados quando existirem múltiplos tipos de Undead.

Decisão:
realizar o balance pass mais profundo depois da primeira expansão de economia/unidades.

---

## [0.0.3] — Waves

- Wave counter.
- Enemies per Wave.
- HP/Damage scaling.
- Elite Waves.
- Wave HUD.

---

## [0.0.2] — Corpse Loop

- Corpse.
- Bones.
- Skeleton production.
- múltiplos Skeletons.
- Node2D.
- target-based movement.
- dynamic visuals.

---

## [0.0.1] — Combat Prototype

- Main.
- Skeleton.
- Enemy.
- HP.
- Damage.
- cooldown.
- auto combat.
