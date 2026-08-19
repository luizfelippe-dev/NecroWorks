# NecroWorks — Architecture

**Atualizado:** 19/08/2026

# Stack

- Godot 4.7.1
- GDScript
- 2D
- Git/GitHub

# Current structure

The prototype remains mostly centralized in `main.gd`.

This was deliberate for speed through `v0.1.0`.

Current responsibilities inside `main.gd` include:

- Skeleton combat;
- Zombie combat;
- Enemy combat;
- Boss;
- Waves;
- Corpses;
- Resources;
- production;
- upgrades;
- synergies;
- metrics;
- run end;
- runtime UI.

Do not perform a big rewrite without a concrete need.

Repository layout:

```text
main.tscn
main.gd
skeleton.tscn
enemy.tscn
corpse.tscn

assets/
├── reference/
└── sprites/
    └── units/

scripts/
├── core/
│   └── localization_service.gd
├── economy/
│   └── processing_directive_policy.gd
├── game/
│   ├── enemy_archetype_catalog.gd
│   └── enemy_wave_policy.gd
├── ui/
│   └── unit_health_bar.gd
└── visual/
    ├── corpse_processing_feedback.gd
    ├── industrial_backdrop.gd
    └── unit_sprite_catalog.gd

tests/
├── balance/
│   └── composition_scenario_runner.gd
├── economy/
│   └── processing_directive_runner.gd
├── factory/
│   └── corpse_processor_runner.gd
├── localization/
│   └── localization_runner.gd
└── visual/
    ├── corpse_processing_feedback_runner.gd
    └── unit_sprite_runner.gd
```

The current scene and script entry points intentionally stay at `res://`. Godot's F6 command runs the scene currently open in the editor; keeping these stable prevents stale-resource failures while the prototype is evolving.

`main.gd` remains the prototype orchestrator. New isolated behavior should live in a focused component.

# Scenes

Known prototype scenes:

```text
main.tscn
skeleton.tscn
enemy.tscn
corpse.tscn
```

`skeleton.tscn` and `enemy.tscn` now contain visible `Sprite2D` children, so their base art can be inspected in the 2D editor. Runtime archetype selection swaps textures through `scripts/visual/unit_sprite_catalog.gd`.

Zombie V1 still reuses the Skeleton Node2D scene structurally, but receives its own texture and combat state at runtime. This is acceptable for the prototype.

Later, Zombie and each commercial unit should receive dedicated scenes with animations, effects and audio hooks.

The factory background is procedural and lives in `scripts/visual/industrial_backdrop.gd`. Procedural rendering is an intentional prototype technique, not an architectural problem; static illustration layers can replace or complement it when final art direction requires richer depth.

Prototype sprite source PNGs remain available at full resolution, while Godot import settings cap runtime textures at 512 px. This preserves editable source quality without loading unnecessary resolution for sub-200 px battlefield rendering.

# Resource state

```gdscript
bones
flesh
blood
souls
```

Current income:

```text
Corpse
→ Processing Directive
→ Balanced / Bone Focus / Flesh Focus
→ Bones and/or Flesh
```

Directive state lives in `processing_directive`; `processing_directive_locked` prevents mid-Wave changes. Wave 1 starts Balanced, controls unlock during the upgrade transition, and `start_wave()` locks the selected route. Pure yield/name validation lives in `scripts/economy/processing_directive_policy.gd`; `get_processing_yield()` is the orchestrator-facing entry point used by processing logic, HUD labels, buttons and economy validation.

`scripts/visual/corpse_processing_feedback.gd` owns the transient processing token and yield popup. The token terminates above the Resources panel, which pulses when the queued transaction settles. The economy transaction remains synchronous inside `process_corpse()` after the processor cycle; visual timing adds no further delay and cannot change deterministic balance. `corpse_processing_feedback_started` is the integration boundary for future SFX.

# Localization

`localization/ui.csv` is the source-of-truth catalog imported by Godot for `en`, `pt_BR` and `es`. `project.godot` registers the generated Translation resources and uses English as fallback. `scripts/core/localization_service.gd` owns locale normalization so future Options UI does not need to know regional fallback rules. Programmatic HUD text uses translation keys and `main.gd` reacts to `NOTIFICATION_TRANSLATION_CHANGED` by refreshing the migrated UI slice.

Localization is intentionally incremental: only stable interface copy is migrated. The persistent runner verifies resource registration, regional normalization and live HUD refresh in all three supported languages.

# Corpse Processor queue

`corpse_processing_queue` stores a Corpse reference together with the processing directive selected when it entered the machine. Manual clicks enqueue instead of granting resources immediately. `update_corpse_processor()` advances the single processing lane and calls the existing deterministic transaction only when the base 0.65-second cycle completes.

The initial capacity is five. A full queue leaves additional Corpses on the battlefield, preserving player agency and preventing silent resource loss. Capacity and seconds-per-Corpse are explicit runtime values modified by the Factory Control upgrade layer without rewriting the transaction. Manual collection remains available before and after Automated Retrieval is unlocked.

# Factory Control

Factory Control is a run-scoped prototype layered over the Corpse Processor. Completed Waves award one Factory Point and Elite Waves award one additional point. The currency is intentionally separate from Bones/Flesh so machine investment does not directly consume the same stock used for emergency army production.

Automated Retrieval is locked by default, purchased once, and controlled by a reversible toggle. Its 0.25-second scan only enqueues valid Corpses while capacity remains. Queue Expansion and Processor Overclock each have three levels; their runtime effects modify the explicit processor capacity/cycle values already consumed by the queue.

`tests/factory/factory_automation_runner.gd` validates locked-state safety, Wave/Elite income, purchases, automatic queue filling, overflow preservation and upgrade effects. Costs and income are provisional balance values.

# Manual batch production

`production_quantity_selector` owns a shared 1–36 request quantity. `create_skeleton_batch()` and `create_zombie_batch()` validate the complete resource cost and available Undead capacity before creating anything. A rejected request therefore has no partial resource or army mutation.

Successful requests use the existing per-unit creation paths so HP, slots, metrics, sprites and combat dictionaries remain identical to single production. `batch_production_completed` is the presentation boundary for future assembler animation/audio. This is not yet a timed Skeleton Assembler or Flesh Vat queue.

# Army Doctrine planning

`scripts/factory/army_doctrine_policy.gd` is a stateless policy boundary for composition targets, the 36-unit cap, production priority, resource reserves and live deficits. `main.gd` owns the run-scoped configuration and localized panel, and emits `army_doctrine_changed` only after a valid atomic update.

The policy can answer whether a unit cost would preserve the configured reserve, but it does not create units. Automatic replenishment must consume the Skeleton Assembler/Flesh Vat queues so production keeps visible time, capacity and player-controlled pause behavior. `tests/factory/army_doctrine_runner.gd` protects this planning/execution boundary.

# Timed Undead production

`scripts/factory/undead_production_policy.gd` validates atomic orders and counts reserved units. The two runtime queues contain order dictionaries with original quantity, remaining quantity and snapshotted cost. Acceptance immediately reserves the full resource total; queued units also reserve army capacity.

Skeleton Assembler and Flesh Vat advance independently at 0.45 s and 0.80 s per unit. Completion uses prepaid creation paths, preserving the existing HP, slot, metric and combat registration logic without charging twice. A full machine accepts at most three orders, and queued units keep the defeat condition recoverable. `tests/factory/undead_production_queue_runner.gd` validates the transaction and timing contract.

# Blood, Souls and generic ranged Undead

`scripts/economy/necromantic_resource_policy.gd` owns deterministic Blood/Soul kill rewards, sacrifice cost and Fervor scaling. `scripts/units/undead_runtime_unit.gd` is the first self-contained runtime unit record: `ghost.tscn` stores HP, damage, cooldown, speed, range, timer and formation slot on the unit instead of adding a third parallel dictionary family.

The localized Ritual panel exposes Blood Fervor, two Blood upgrades, Ghost production and two Soul upgrades. Crimson Assembly and Phantom Conduit use the existing synergy registry.

# Viewport policy

The 1920×1080 design canvas uses `stretch/aspect="keep"`. Smaller or differently proportioned embedded windows scale/letterbox the complete canvas instead of cropping the lower production floor. `tests/visual/layout_bounds_runner.gd` protects primary lower controls inside design bounds.

# Corpse tracking

```gdscript
var corpses: Array[Button] = []
```

Used for:

- processing;
- recovery;
- defeat condition.

# Skeleton state

```text
skeletons
skeleton_hps
skeleton_attack_timers
skeleton_slots
```

# Zombie state

```text
zombies
zombie_hps
zombie_attack_timers
zombie_slots
```

# Shared slot state

Current shared occupancy map:

```text
occupied_undead_slots
```

It acts as a shared Undead occupancy map and is limited by `MAX_UNDEAD`.

# Generic Undead helpers

Current layer:

```text
get_total_undead_count()
get_all_undead_units()
get_closest_undead_to_enemy()
damage_undead()
```

This is the beginning of the future generic unit system.

# Enemy group state

Regular Waves can now maintain more than one active Enemy:

```text
enemies
enemy_hps
enemy_max_hps
enemy_damages
enemy_speeds
enemy_attack_cooldowns
enemy_attack_ranges
enemy_attack_timers
enemy_lane_offsets
enemy_types
```

`enemy` remains a compatibility alias for the current primary/leftmost target while legacy formation, HUD and Boss logic are incrementally migrated. It is not the authoritative collection.

The active cap is isolated in `scripts/game/enemy_wave_policy.gd`. Spawned enemies fill the cap, keep independent health bars and are replenished after deaths until the Wave total is exhausted.

Archetype definitions and their introduction rotation live in `scripts/game/enemy_archetype_catalog.gd`. This keeps tuning data out of spawn/combat flow while dedicated Enemy scenes are still premature.

# Formation

Current priority:

```text
Zombie
→ front combat slots

Skeleton
→ behind Zombie
```

Combat-slot compaction keeps formations from leaving gaps after deaths.

# Movement

Enemy/Boss:

- horizontal lane;
- fixed/controlled Y;
- clamped X;
- target by horizontal distance.
- current right-side combat-safe maximum: `x=1450`.

This is a stability fix and should not be casually removed.

# Boss AOE

The Foreman collects:

```text
get_all_undead_units()
```

then damages random valid targets.

So Zombie support is already generic at Boss level.

# Defeat

Current logic:

```text
if army > 0:
	continue

if corpses > 0:
	continue

if bones >= skeleton_cost:
	continue

if flesh >= zombie_cost:
	continue

finish_run(false)
```

# UI

Current runtime UI:

- Resources block;
- Create Skeleton button;
- Create Zombie button;
- Wave HUD;
- Synergy HUD;
- Upgrade UI;
- Run End UI;
- compact Debug HUD.

Debug:

```text
F3
```

## Run-end presentation

The full-screen `RunEndPanel` now owns three independent regions:

```text
RunEndTitle
RunEndSummary       → statistics/economy
RunEndBuildSummary  → build/synergies/status
RestartRunButton    → isolated bottom action
```

This prevents dynamic synergy content from colliding with the Restart button.

## Project entry points

`project.godot` and `main.tscn` must reference the same current scene UID. F5 and F6 were revalidated after synchronizing this UID; do not hand-edit only one side.

## Unit health presentation

`scripts/ui/unit_health_bar.gd` is a reusable child component attached at runtime.

It receives:

- current HP;
- Max HP;
- visual width;
- vertical offset;
- faction/accent color.

Updates currently cover:

- normal attacks;
- Industrial Crush;
- Final Service / Second Shift;
- Carrion Recovery;
- Reassembly;
- Max HP upgrades.

# Architectural risk

Adding a third/fourth unit type by copying Zombie functions may create excessive duplication.

Likely future direction:

```text
Undead Unit
├── node
├── unit_type
├── hp
├── max_hp
├── damage
├── cooldown
├── timer
├── speed
├── slot
└── tags
```

Possible structures:

- dictionary-based runtime state;
- UnitDefinition Resource;
- lightweight component script.

Do not decide prematurely.

# Persistent balance validation

`tests/balance/composition_scenario_runner.gd` instantiates the real main scene and runs deterministic fixed-FPS combat scenarios. It intentionally uses runtime production, movement, targeting, damage and Wave code instead of duplicating formulas in a separate simulator.

`tests/economy/processing_directive_runner.gd` validates directive yields, Corpse consumption, button layout bounds and compatibility with dynamic Bone yield upgrades.

The runner must remain outside production scene dependencies and execute only through an explicit CLI test command.

# Recommended refactor trigger

Start a real generic Undead refactor when at least one becomes true:

1. Ghost implementation requires different range/behavior.
2. A third unit copies too much code.
3. Upgrades need tags across multiple unit types.
4. formation logic becomes role-driven.

# Data-driven future

Potential Resources:

```text
UnitDefinition
UpgradeDefinition
EnemyDefinition
SynergyDefinition
```

Useful fields:

- id;
- display_name;
- tags;
- stats;
- costs;
- rarity;
- icon;
- localization key.

Do this later.

# Performance

With large hordes, measure before optimizing:

- number of active Node2D units;
- per-frame loops;
- corpse count;
- UI updates;
- attack loops;
- AOE;
- VFX.

Potential future optimization:

- state arrays;
- reduced update frequency;
- object pooling;
- batching visuals.

Not required yet.
