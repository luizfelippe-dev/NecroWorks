# NecroWorks — Devlog

## 14/08/2026 — Initial Combat

Created:

- Main;
- Skeleton;
- Enemy;
- HP;
- Damage;
- cooldown;
- auto combat.

---

## 14–16/08/2026 — Corpse Economy

Added:

- Corpse;
- Bones;
- processing;
- Skeleton production;
- multiple Skeletons.

Loop:

```text
Enemy → Corpse → Bones → Skeleton
```

---

## 16/08/2026 — Movement V1

- Node2D units;
- target movement;
- combat slots;
- dynamic placeholders;
- debug HUD.

---

## 17/08/2026 — Waves

- Wave counter;
- scaling;
- Elite Waves;
- Wave HUD.

---

## 17/08/2026 — Upgrade System

Built pool of 10 upgrades.

- 3 random choices;
- stacking;
- caps.

---

## 17/08/2026 — Synergies

Implemented:

- Overclocked Ossuary;
- Recycling Plant;
- Second Shift;
- Bone Assembly Line.

Run Metrics added.

---

## 17/08/2026 — Long Playtest

Reached Wave 21.

Conclusion:

- stable;
- economy too generous;
- horde snowballs heavily.

Deep balance postponed.

---

## 17/08/2026 — The Foreman

Wave 20 became Boss.

Added:

- The Foreman;
- 2200 HP;
- Industrial Crush;
- multi-target.

### Bug

Boss could leave screen.

### Fix

- horizontal lane;
- bounds;
- compact formation;
- horizontal attack distance.

Validated.

---

## 17–18/08/2026 — Run End

Added:

- Victory;
- Run Summary;
- Restart;
- Corpse tracking;
- Defeat;
- Game Over;
- Restart after Defeat.

Full run validated.

`v0.1.0 — First Run` became functionally complete.

---

## 18/08/2026 — Visual Target Defined

A dedicated AI concept image created by the user became the official visual target for NecroWorks.

Direction:

- industrial dark fantasy;
- central battlefield;
- factory layer;
- resources;
- metrics;
- synergies;
- upgrade cards;
- green necromantic accents;
- heavy metal machinery.

---

## 18/08/2026 — Resource Foundation

Added state:

```text
Bones
Flesh
Blood
Souls
```

Corpse now gives:

```text
Bones + Flesh
```

Temporary Resource HUD added.

### Bug

Previous test accidentally left Skeleton at 10000 HP.

Fix:

```text
Skeleton Max HP → 100
```

HUD overlap also fixed.

Debug was reduced and moved behind `F3`.

Validated.

---

## 18/08/2026 — Zombie V1

First new Undead added.

```text
HP: 220
Damage: 6
Cooldown: 1.1
Speed: 120
Cost: 6 Flesh
```

Added:

- Zombie production;
- Zombie state;
- Zombie HP;
- Zombie attack;
- Zombie death;
- Zombie metrics;
- frontline priority;
- mixed Undead target selection;
- Boss AOE compatibility;
- Defeat compatibility;
- Run Summary support.

### Validation

User confirmed everything functioning.

This checkpoint was superseded by the Enemy Groups milestone below.

---

## 18/08/2026 — Enemy Groups & Living Archetypes

Added:

- simultaneous Enemy groups from Wave 6 onward;
- independent HP, damage, movement speed, range and cooldown;
- Human Warrior;
- ranged Mage;
- fast Elf Skirmisher;
- individual names, colors and health bars;
- staged archetype introduction;
- single-target Foreman encounter preserved.

Validated on Waves 1, 6, 8, 11 and 20.

---

## 18/08/2026 — HUD & Run-End Stabilization

Fixed:

- Enemy spawn/movement no longer enters the right-side Metrics/Synergy panels;
- a dedicated `x=1450` combat-safe boundary now protects the HUD;
- final Run Summary split into Statistics and Build Summary columns;
- Restart button no longer overlaps Active Synergies;
- Project Run main-scene UID synchronized with `main.tscn`.

Visual validation completed at 1920×1080.

---

## Next

### Flesh Identity

Recommended next block:

- validate mixed-army choices after Meat Shield Protocol;
- test composition choice Skeleton vs Zombie.

### Enemy depth

- playtest Warrior/Mage/Elf pressure;
- add advanced behavior only after evidence: Mage AOE/control and Elf precision targeting;
- improve hit/death feedback.

Then:

- Blood sink;
- Blood generation;
- Soul/Ghost;
- representative balance pass.
