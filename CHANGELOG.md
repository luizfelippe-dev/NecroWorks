# Changelog

## [Unreleased] — v0.2.0 Necromantic Economy

### Added

- Resource foundation:
  - Bones;
  - Flesh;
  - Blood;
  - Souls.
- Flesh generation from Corpse processing.
- Temporary multi-resource HUD.
- `F3` toggle for compact Debug HUD.
- Zombie V1.
- Zombie production using Flesh.
- Zombie HP / attack timer / slots / metrics.
- Generic Undead targeting for Enemy.
- Generic Undead targeting for The Foreman AOE.
- Zombie frontline priority.
- Zombie metrics in Run Summary.
- Defeat condition aware of Skeletons + Zombies + Bones + Flesh + Corpses.
- Zombie-specific upgrade set:
  - Rotten Bulk;
  - Grave Hunger;
  - Dead Weight;
  - Carrion Recovery.
- First industrial-necromancy visual pass based on `assets/reference/necrodesign.png`:
  - procedural factory backdrop;
  - separated battlefield and production floor;
  - NecroWorks brand header;
  - framed Wave, Resources, Run Metrics and Synergy panels;
  - dedicated Corpse Processing and Undead Production modules;
  - dark-metal upgrade and production cards.
- Main scene configured for Project Run.
- Runtime health bars for Skeletons, Zombies, normal Enemies, Elites and The Foreman.
- Health bars update on damage, healing, revival and Max HP upgrades.
- Project structure clarified while preserving Godot-compatible root entry points:
  - `main.tscn`, `main.gd` and base prototype scenes remain at `res://` for reliable F6 current-scene execution;
  - `assets/reference` and `scripts/ui` hold modular resources.
- Reusable `UnitHealthBar` visual component.
- First Flesh/Bone cross-synergy, Meat Shield Protocol:
  - requires Rotten Bulk + Rapid Assault;
  - every hit absorbed by a Zombie reduces all Skeleton attack timers by 0.12 s.
- Simultaneous Enemy group foundation:
  - independent HP, cooldown, lane and health bar per active Enemy;
  - closest-target selection for Skeletons and Zombies;
  - defeated slots refill while the Wave still has remaining Enemies;
  - staged active caps from Wave 6 onward;
  - The Foreman remains a single-target Boss encounter.
- Living Enemy archetype foundation:
  - Human Warrior as the durable melee baseline;
  - Mage as a fragile, high-damage ranged attacker from Wave 8;
  - Elf Skirmisher as a fast attacker from Wave 11;
  - independent HP, damage, speed, attack range and cooldown per archetype;
  - temporary identity labels and color coding above each Enemy.
- Persistent deterministic composition balance runner for Skeleton-only, Zombie-heavy and mixed armies.
- Processing Directive V1:
  - Balanced yields 8 Bones / 2 Flesh;
  - Bone Focus yields 12 Bones / 0 Flesh;
  - Flesh Focus yields 2 Bones / 6 Flesh;
  - three live factory controls and dynamic yield feedback;
  - focused modes preserve one-Corpse emergency production.
  - per-route processing history in the final Run Summary.
- Processing directives now use Wave commitment:
  - Wave 1 starts in Balanced mode;
  - selection is free during the between-Wave upgrade phase;
  - the selected route is locked while combat is active.
- Persistent economy runner for directive yields, UI bounds and upgrade compatibility.
- First runtime character sprite pass for Skeleton, Zombie, Human Warrior, Mage, Elf and The Foreman.
- `skeleton.tscn` and `enemy.tscn` now expose visible `Sprite2D` children in the 2D editor.
- Runtime sprite selection centralized in `scripts/visual/unit_sprite_catalog.gd`.
- Procedural backdrop moved from the repository root to `scripts/visual/industrial_backdrop.gd`.
- Persistent visual runner validates every current unit texture and verifies square placeholders are gone.
- Runtime sprite imports are capped at 512 px while original transparent PNG sources are preserved.
- Corpse processing feedback V1:
  - clicked Corpses emit a directive-colored token toward the Resources intake;
  - the Resources panel reacts with a short color pulse;
  - the actual Bones/Flesh yield appears above the factory boundary;
  - resource transactions remain immediate and deterministic;
  - `corpse_processing_feedback_started` provides a future SFX integration hook.
- Persistent visual runner validates the complete feedback lifecycle and cleanup.
- Localization foundation V1:
  - Godot-native CSV catalog registered for English, PT-BR and Spanish;
  - localized Resources, production, Corpse processing, directives, metrics and yield feedback;
  - runtime locale changes refresh the localized HUD slice immediately;
  - `LocalizationService` normalizes regional locale variants and provides a safe English fallback;
  - persistent runner validates all three language routes.
- Localization coverage expanded to the Wave HUD, enemy identities, Corpse labels and Active Synergies.
- `necrodesignv2.png` adopted as the authoritative Visual Target V2.
- Corpse Processor Queue V1:
  - manual Corpse clicks enqueue work instead of yielding resources instantly;
  - base queue capacity is 5 with a 0.65-second single-lane processing cycle;
  - each queue entry snapshots its processing directive;
  - full queues preserve unqueued Corpses on the battlefield;
  - persistent runner validates capacity, delayed rewards and directive integrity.
- Factory Control V1:
  - dedicated localized Factory panel and navigation button;
  - one Factory Point per completed Wave plus one bonus point for Elite Waves;
  - Automated Retrieval purchase and reversible auto-collection toggle;
  - three queue-capacity levels and three processing-speed levels with escalating costs;
  - automatic retrieval respects queue capacity and never destroys overflow Corpses;
  - persistent runner validates locks, earnings, purchases, toggling and queue refill.
- Manual Batch Production V1:
  - shared 1–36 quantity selector supports typing and arrow adjustment;
  - Skeleton/Zombie buttons display requested quantity and total resource cost;
  - a batch is all-or-nothing when resources or army slots are insufficient;
  - `batch_production_completed` exposes a future machine-feedback/audio hook;
  - persistent runner validates costs, counts, capacity rejection and insufficient-resource rejection.

### Current Zombie V1 values

```text
HP: 220
Damage: 6
Cooldown: 1.1 s
Speed: 120
Cost: 6 Flesh
```

### Current resource values

```text
Bones per Corpse: 8
Flesh per Corpse: 2
Skeleton Cost: 5 Bones
Zombie Cost: 6 Flesh
```

### Verified

- Resource HUD no longer overlaps the production buttons.
- Skeleton Max HP restored to 100 after accidental test value.
- Skeleton combat remains functional.
- Flesh is generated correctly.
- Zombie button unlocks with sufficient Flesh.
- Zombie spawns and moves.
- Zombie attacks.
- Enemy attacks Zombie.
- Zombie dies and releases slot.
- Mixed Skeleton + Zombie army functions.
- Zombie frontline priority works.
- Defeat logic remains functional with mixed Undead.
- Zombie upgrade effects validated together in a running scene.
- Project and main scene start without parser/runtime errors after the visual pass.
- Health values and rendered bars validated for damaged Skeleton, Zombie and Enemy instances.
- Project starts correctly after all source/resource paths were reorganized.
- Wave 6 group state, independent HP, refill behavior and Wave 20 single-Boss cap validated headlessly.
- Wave 1 Warrior, Wave 8 Mage reinforcement, Wave 11 mixed group and Foreman archetype validated headlessly.
- Enemy bodies, names and health bars remain outside the right HUD rail at 1920×1080.
- Run Summary statistics, build details, synergy list and Restart action render without overlap.
- F5 Project Run and F6-compatible scene entry point share the current `main.tscn` UID.
- Wave 8 composition baseline confirms distinct Skeleton damage, Zombie durability and mixed-army performance.

### Fixed

- Enemies could spawn and fight behind the Run Metrics and Active Synergies panels.
- Long Run Summary and Active Synergies text overlapped the Restart button.
- `project.godot` referenced a stale main-scene UID after scene reimport.

### Known limitations

- Blood has no source/sink yet.
- Souls has no source/sink yet.
- Skeleton-only upgrades do not yet have Zombie equivalents.
- Mixed formation is still prototype-level.
- Skeletons still attack through the current formation abstraction.
- No ranged/magic unit yet.
- Full balance pass intentionally postponed.
- `main.gd` remains large and centralized.

---

## [0.1.0] — First Run

### Added

- Automatic combat.
- Multiple Skeletons.
- Corpses.
- Bones.
- Skeleton production.
- Waves.
- Wave scaling.
- Elite Waves.
- 10 upgrades.
- 3 random upgrade choices between Waves.
- 4 synergies.
- Run Metrics.
- Boss Wave 20.
- The Foreman.
- Industrial Crush.
- Victory.
- Game Over.
- Run Summary.
- Restart after Victory/Defeat.
- Corpse tracking for defeat logic.

### Changed

- Enemy/Boss combat moved to a controlled horizontal lane.
- Skeleton combat formation compacts after deaths.
- Combat positions are clamped to arena bounds.
- Wave progression waits for upgrade selection.

### Fixed

- Main freeze after complete army wipe.
- Boss leaving the screen due to feedback between pursuit and formation.
- Formation gaps pulling combat outside the arena.
- Premature Game Over while player still has Corpses or enough Bones to rebuild.

### Verified

- Full run from Wave 1 to Wave 20.
- Elite Waves.
- The Foreman.
- Victory flow.
- Defeat flow.
- Run Summary.
- Restart.
- Overclocked Ossuary.
- Recycling Plant.
- Second Shift.
- Bone Assembly Line unlock.

### Balance

Balance is intentionally provisional.

Known issues:

- Bones can saturate.
- Army may snowball early.
- Late-game normal Enemies can lose pressure.
- Damage/attack-speed stacking can scale strongly.
- Boss/Elites will need reevaluation after multi-unit economy exists.

---

## [0.0.3] — Waves

- Wave counter.
- Enemies per Wave.
- HP/Damage scaling.
- Elite Waves.
- Wave HUD.

## [0.0.2] — Corpse Loop

- Corpse.
- Bones.
- Skeleton production.
- Multiple Skeletons.
- Node2D migration.
- Target movement.
- Dynamic placeholders.

## [0.0.1] — Combat Prototype

- Main.
- Skeleton.
- Enemy.
- HP.
- Damage.
- Cooldown.
- Auto combat.
