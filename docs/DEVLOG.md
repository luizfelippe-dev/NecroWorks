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

## 18/08/2026 — Composition Baseline

Added a persistent deterministic balance runner using real runtime combat.

Wave 8 with eight base units and no upgrades/reinforcement:

```text
Skeleton-only → 5 kills, 33.2 s
Zombie-heavy  → 5 kills, 70.2 s
Mixed 4+4     → 7 kills, 51.2 s
```

Conclusion: unit roles are distinct enough for the current milestone. The missing decision is economic routing because every Corpse currently provides both unit resources.

---

## 18/08/2026 — Processing Directive V1

First functional Factory decision added:

```text
Balanced    8B / 2F
Bone Focus  12B / 0F
Flesh Focus 2B / 6F
```

Added three live controls to the Corpse Processing panel, dynamic yield feedback and persistent economy validation. Flesh Focus was raised from the initial 5 Flesh draft to 6 so processing the last available Corpse can always produce a Zombie.

---

## 19/08/2026 — Wave Commitment & Basic Sprites

Processing routes are now a free between-Wave commitment instead of a live per-Corpse toggle:

```text
Wave 1             → Balanced onboarding
Between Waves      → choose next route
Active Wave        → route locked
```

This keeps experimentation accessible while removing repetitive optimal micro-management.

Square combat placeholders were replaced with transparent prototype sprites for Skeleton, Zombie, Human Warrior, Mage, Elf and The Foreman. Base scenes now expose `Sprite2D` content in the 2D editor; runtime texture selection is isolated in `scripts/visual/unit_sprite_catalog.gd` and covered by a persistent validation runner.

The procedural factory backdrop moved to `scripts/visual/`, leaving only stable entry points and base scenes at the repository root.

---

## 19/08/2026 — Corpse Processing Feedback V1

Corpse recycling now produces a short visible transaction without delaying the economy:

```text
Corpse click
→ directive-colored token travels to the processor
→ Resources panel pulses
→ actual Bones/Flesh yield rises above the factory
→ feedback node cleans itself up
```

The `corpse_processing_feedback_started` signal is reserved for the future SFX layer. A persistent visual runner validates rewards, signal payload, panel recovery and transient-node cleanup.

---

## 19/08/2026 — Localization Foundation V1

The project now has a Godot-native CSV localization pipeline with English, Brazilian Portuguese and Spanish resources. The first stable HUD slice—Resources, production, Corpse Processing, directives, run metrics and resource feedback—uses translation keys and refreshes live when the locale changes.

`LocalizationService` maps regional variants to the supported catalog and falls back to English. A dedicated runner changes languages at runtime and validates both translation lookup and visible HUD text. Remaining UI copy will migrate incrementally as each interface becomes stable.

---

## 19/08/2026 — Visual Target V2 & Corpse Processor Queue

`assets/reference/necrodesignv2.png` is now the authoritative visual reference. It strengthens the intended hierarchy between battlefield, processing machinery, resource storage, troop assembly, upgrades and navigation.

The first Factory machine now has actual timing and capacity. Manual Corpse clicks enter a five-slot queue and resolve through a 0.65-second processing lane. Each entry snapshots its directive, so a later selection cannot rewrite queued rewards. This establishes the technical seams required for capacity/speed upgrades and a separately purchased automatic-collection toggle.

Localization coverage was extended to the Wave panel, living enemy identities, Corpse states and Active Synergies.

---

## 19/08/2026 — Factory Control V1

A dedicated localized Factory panel now exposes the first machine-upgrade branch. Waves award Factory Points, with an extra point for Elite clears. Automated Retrieval is a purchased, reversible toggle; Queue Expansion and Processor Overclock each offer three increasingly expensive levels.

Automatic collection scans for available Corpses but never bypasses queue capacity or deletes overflow. The Factory panel yields to the Wave upgrade overlay so the two decision surfaces cannot overlap. Persistent validation covers currency income, locked-state behavior, purchases, toggling and automatic refill.

All values remain provisional until full-run playtests establish whether the player faces real timing and investment tradeoffs.

---

## 19/08/2026 — Manual Batch Production V1

The Undead Production panel now has a shared typed quantity selector. Skeleton and Zombie actions preview total cost and build the complete requested batch only when every resource and army slot is available.

The implementation reuses existing unit creation paths and emits a batch-level presentation hook. Deterministic validation confirms successful five-unit orders and zero-mutation rejection for insufficient resources/capacity.

This reduces click repetition but remains manual and instant. Timed Skeleton Assembler/Flesh Vat queues and Army Doctrine replenishment are intentionally still open.

---

## 19/08/2026 — Army Doctrine Planning V1

A localized Doctrine panel now stores target counts for Skeletons/Zombies, minimum Bones/Flesh reserves and Balanced or unit-first production priority. Its live summary compares the target with the current army and exposes missing units without changing combat state.

The stateless policy rejects invalid compositions above the 36-unit cap and provides reserve-safe spending checks for future machines. Automatic replenishment is intentionally disabled until timed Skeleton Assembler and Flesh Vat queues can make production throughput, scarcity and pause control visible.

---

## 19/08/2026 — Timed Undead Production Queues V1

Manual production buttons now submit atomic orders instead of spawning an entire batch instantly. The order reserves its full cost and future army slots, then Skeleton Assembler and Flesh Vat operate in parallel at 0.45 s and 0.80 s per unit respectively.

Each machine accepts three pending orders. A localized status line exposes remaining units and the current cycle timer, while queued rebuilding prevents a false defeat. Persistent validation covers reservations, independent timing, completion signals, queue limits and localized UI.

---

## 19/08/2026 — Necromantic Economy v0.2 Complete

The lower HUD cutoff was traced to stretch aspect expansion; the project now preserves the complete 1920×1080 canvas. Production copy now says “Produzir … (Fila)” instead of exposing implementation terminology.

Blood and Souls are active resources. A localized Ritual panel provides Blood Fervor, Hematic Extraction, Crimson Infusion, Ghost summoning, Spectral Focus and Ethereal Anchor. Crimson Assembly and Phantom Conduit complete the first rare-resource synergy pair.

Ghost is the first ranged player unit and the first unit whose complete runtime state lives on a reusable scripted node. Two deterministic full runs—Bone/Skeleton and Flesh/Zombie—defeated the Foreman with distinct production histories. Evidence reduced Blood/Soul inflation before the milestone closed. A five-second milestone clip was generated locally.

---

## 20/08/2026 — Army Doctrine execution V1

Army Doctrine now turns target composition into paid orders on the existing timed Skeleton Assembler and Flesh Vat queues. Pending units count toward the target, preventing duplicate orders. Balanced allocation shares scarce capacity, focused priorities reserve it for the chosen line first, and minimum Bones/Flesh reserves are enforced before enqueue. A localized button starts or pauses future replenishment without cancelling committed production. Persistent coverage validates the complete loss-to-replacement loop.

---

## 20/08/2026 — Hematic Press V1

Factory Control now uses a 3×2 machine grid. Hematic Press creates the first explicit resource-conversion line: a 3-Factory-Point unlock, followed by timed 12-Flesh-to-1-Blood orders in a three-unit queue. Flesh is reserved immediately, progress remains visible, and produced Blood feeds the existing Ritual economy and metrics. The cost intentionally competes with two base Zombies per Blood.

Soul Extractor occupies the fifth card. Mage/Elf/Foreman Corpses retain arcane identity and can be diverted from material recovery into a separate timed Soul queue. The sixth card adds three Industrial Efficiency levels across both rare-resource lines. Efficiency II plus Hematic Press unlocks Dark Refinery. The right HUD synergy frame was expanded and validated against the complete eight-synergy list.

---

## 20/08/2026 — Skeleton Archer and Lich Summoner V1

The generic `UndeadRuntimeUnit` bridge now supports two genuinely different recipes without new parallel state families. Skeleton Archer uses the shared Bone assembler, a protected ranged formation and an unlockable blueprint. Lich is an 8-Soul ranged caster whose separate ability timer produces temporary Thralls under explicit Soul, population, cooldown, duration and global-cap constraints.

Temporary Thralls deliberately bypass permanent Skeleton build/loss metrics, Reassembly and Final Service. Three summoner upgrades and Soul Foundry establish the first Lich build. Ossuary Ballistics connects Archer research to Heavy Bones + Death March, bringing the current catalog to ten synergies.

Both units received original transparent prototype sprites, dedicated scenes and EN/PT-BR/ES interface coverage. The complete 21-runner headless regression passed. Corpse feedback cleanup validation was made time-based so results no longer depend on host frame rate.

---

## 20/08/2026 — Advanced enemies and first rare upgrade

Mage and Elf stopped being stat-only variants. Every third Mage attack now becomes Arcane Burst, damaging up to three clustered Undead and suppressing their attack timers. Every fourth Elf attack becomes Precision Shot, selecting exposed summoners and ranged units before tanks and dealing amplified damage. Both abilities have localized world feedback and an event hook for later VFX/SFX.

Emergency Reclamation establishes the rare/rule-changing upgrade path. From Wave 8 onward it may enter the upgrade roll once; after selection, the first permanent death per Wave returns half of that recipe's current production cost. Temporary Thralls are excluded.

The metrics panel was enlarged and the synergy panel moved down so Lich/Thrall rows cannot overlap its title. The bounds runner now loads every metric and all ten synergies. Two focused runners raised the full regression to 23/23 passing scenarios, while Bone and Flesh full-run strategies still defeat the Foreman.

---

## 21/08/2026 — Elite variants

Elite Waves now amplify archetype identity rather than only HP, damage and color. Warrior becomes Bulwark with 20% damage mitigation. Overcharged Mage casts its stronger Burst every second attack, and Deadeye Elf executes stronger Precision every third attack. Trait labels are visible and localized before engagement; The Foreman remains outside this ruleset.

Elite state is stored per Enemy and routed through the existing combat policy. A dedicated runner validates mitigation, cadence, splash, suppression, target selection, damage and translations. The full regression reached 24/24 passes, and both automated economy strategies still completed Wave 20.

---

## Next

### Production planning

Recommended next block:

- playtest Factory Point income and upgrade timing;
- playtest Army Doctrine during a complete manual run;
- measure whether automatic replenishment makes late Waves too safe;
- playtest Hematic Press cost and unlock timing;
- run a complete manual v0.3 playtest using Doctrine and rare-resource routing;
- run a complete manual Archer/Lich composition and record Soul pressure, summon uptime and battlefield readability;
- decide the first rare/rule-changing upgrade after the new composition has evidence.

### Enemy depth

- playtest Warrior/Mage/Elf pressure;
- add advanced behavior only after evidence: Mage AOE/control and Elf precision targeting;
- improve hit/death feedback.

Then: Factory Point pacing playtest during the next full manual run.
