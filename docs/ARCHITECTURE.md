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

Legacy name:

```text
occupied_skeleton_slots
```

It now acts as a shared Undead occupancy map.

Rename only when touching this architecture for a real reason.

# Generic Undead helpers

Current layer:

```text
get_total_undead_count()
get_all_undead_units()
get_closest_undead_to_enemy()
damage_undead()
```

This is the beginning of the future generic unit system.

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
