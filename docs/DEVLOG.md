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

This is the latest stable gameplay checkpoint.

---

## Next

### Flesh Identity

Recommended next block:

- validate mixed-army choices after Meat Shield Protocol;
- test composition choice Skeleton vs Zombie.

Then:

- Blood sink;
- Blood generation;
- Soul/Ghost;
- representative balance pass.
