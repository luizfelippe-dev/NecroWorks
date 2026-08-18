# NecroWorks — Architecture

**Atualizado:** 18/08/2026

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
└── reference/

scripts/
├── game/
│   ├── enemy_archetype_catalog.gd
│   └── enemy_wave_policy.gd
└── ui/
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

Zombie V1 currently reuses the Skeleton Node2D scene as a placeholder and applies Zombie-specific state/visual behavior in `main.gd`.

This is acceptable for the prototype.

Later, Zombie should receive its own scene/art.

# Resource state

```gdscript
bones
flesh
blood
souls
```

Current income:

```text
Corpse → Bones + Flesh
```

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
