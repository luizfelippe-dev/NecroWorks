# NecroWorks — Decisions

**Atualizado:** 19/08/2026

---

## Engine

Godot 4.7.1 + GDScript.

Reason:
fast solo iteration and strong 2D workflow.

---

## Single-player / 2D first

Keep scope controlled for first commercial release.

---

## Placeholder before final art

Gameplay proof before expensive art production.

---

## Name

Project renamed from Corpse Factory to **NecroWorks**.

Brand:

```text
NecroWorks
Industrial Reanimation Solutions
Waste Nothing. Raise Everything.
```

---

## Core loop

Identity:

```text
Enemy
→ Corpse
→ Resource
→ Undead
```

Do not dilute this.

---

## Centralized `main.gd`

Accepted through early prototype.

No big rewrite before pressure from actual features.

---

## Horizontal Enemy/Boss lane

Implemented after The Foreman could leave the screen.

Reason:
break the pursuit/formation feedback loop.

Includes:

- lane Y;
- X bounds;
- horizontal attack distance;
- compact formation.

---

## Upgrade model

3 random choices between Waves.

Stacking allowed unless capped.

---

## Synergy model

Synergies activate automatically when required upgrades are owned.

---

## First Boss

Wave 20 = The Foreman.

Boss needs to threaten groups.

---

## Victory

The Foreman defeated:

```text
finish_run(true)
```

---

## Defeat is economic, not immediate army wipe

The run continues if the player can still rebuild.

Initially:

- Bones;
- Corpses.

After Zombie:

- Bones;
- Flesh;
- Corpses.

This is intentional and supports recovery.

---

## Restart

Prototype uses:

```gdscript
get_tree().reload_current_scene()
```

Revisit only when persistent systems require it.

---

## Balance timing

**Decision:** postpone deep balance.

Reason:

- economy is still expanding;
- Zombie was just added;
- Blood/Souls not active;
- Skeleton-only balance would become obsolete.

Balance only enough to keep systems testable.

---

## Multi-resource design

Resources need gameplay identity.

```text
Bones → Skeleton / swarm / offense
Flesh → Zombie / durability / mutation
Blood → sacrifice / burst / vampirism
Souls → magic / Ghost / rare effects
```

Do not add resource generation before a meaningful sink is close.

---

## Zombie V1

Added as first Flesh sink.

Role:

```text
tank
frontline
slow
durable
low DPS
```

Current:

```text
220 HP
6 Damage
1.1 s CD
120 Speed
6 Flesh
```

---

## Zombie frontline priority

Zombie combat slots are resolved before Skeletons.

Reason:
make the role visible without needing a complex threat system yet.

---

## Generic Undead layer

Enemy/Boss should think in `Undead`, not only `Skeleton`.

Initial helper layer was added before Ghost.

No complete refactor yet.

---

## Blood next only after Flesh identity

Do not immediately implement every resource.

First:
Zombie-specific upgrades/synergy.

Then:
Blood sink → Blood generation.

---

## Visual target

The conceptual image created by the user is the official visual target.

It can be followed closely because it was created specifically for NecroWorks.

Key layout:

- central combat;
- factory lower section;
- resources left;
- metrics/synergies right;
- Wave/Boss top;
- contextual upgrade cards.

---

## Commercial goal

Maximize probability of strong Steam performance.

Not a revenue guarantee.

Priority:

- hook;
- fun;
- differentiation;
- replayability;
- visual identity;
- marketability;
- polish;
- demo quality.

---

## Living Enemy factions

Opposition is built from living combat families rather than generic monsters:

```text
Human Warrior → durable frontline
Mage          → fragile ranged damage
Elf           → fast skirmisher
```

Their cultures, motives and alliances remain narrative design work; avoid reducing them to interchangeable skins.

Prototype availability is staged: Warrior on Wave 1, Mage on Wave 8 and Elf on Wave 11. Advanced AOE, control and precision behavior is deferred until the foundation is playtested.

---

## Narrative is required, full lore is deferred

NecroWorks needs a strong opening premise and story progression during runs before the vertical slice.

The full lore will be designed as its own pass. Current features must preserve room for an ambiguous living-versus-undead conflict, NecroWorks corporate history and in-run revelations.

---

## Simultaneous Enemy escalation

Wave 1 must remain readable. Group pressure begins after the first Elite checkpoint:

```text
1–5: 1 active
6–9: 2 active
10–13: 3 active
14–17: 4 active
18–19: 5 active
20: 1 Boss
```

This is a playtest baseline, not final balance. Each Enemy owns independent HP, attack cooldown, lane and health bar. Kills refill open group slots until the Wave total is exhausted.

---

## HUD reserves non-combat space

At the current fixed 1920×1080 prototype resolution, the right Metrics/Synergy rail starts near `x=1540`. Enemy spawn and horizontal movement are capped at `x=1450`, leaving room for bodies, health bars and identity labels.

This is a prototype safety boundary. Responsive layout later must derive the combat rectangle from actual HUD geometry.

---

## Run Summary uses separated information regions

Final statistics and build/synergy details use separate columns. The Restart action owns a dedicated bottom region.

Reason: dynamic synergy text must not overlap the primary action or obscure run results.

---

## Composition balance requires economic choice

The first deterministic Wave 8 comparison confirmed distinct combat roles but exposed that fixed `Corpse → Bones + Flesh` output makes a mixed army the default resource-efficient answer.

Decision: do not flatten unit stats to force artificial parity. A Factory processing directive now lets players bias Corpse output toward Bone, Flesh or a balanced result.

Initial values:

```text
Balanced    8B / 2F
Bone Focus  12B / 0F
Flesh Focus 2B / 6F
```

Focused yields deliberately guarantee immediate recovery: Bone Focus can build Skeletons and Flesh Focus can build one Zombie from a single Corpse.

---

## Processing directives are free but committed per Wave

Wave 1 uses Balanced as an onboarding baseline. After each Wave, the player may choose Balanced, Bone Focus or Flesh Focus for free while selecting the next upgrade. Starting the next Wave locks that directive until combat ends.

Reasoning:

- a currency fee would punish experimentation before the economy has enough sinks;
- unrestricted mid-Wave switching turns every Corpse into repetitive micro-optimization;
- Wave commitment creates prediction, risk and build identity without adding grind;
- the between-Wave decision aligns naturally with enemy previews and upgrade selection.

Revisit only after playtests show that one route dominates or that Wave commitment creates unrecoverable states.

---

## Hybrid scene-and-code presentation

Stable visual content belongs in scenes/assets; dynamic combat state and archetype selection remain in code. `skeleton.tscn` and `enemy.tscn` expose editable `Sprite2D` children, while the runtime catalog swaps Skeleton, Zombie, Warrior, Mage, Elf and Foreman textures.

The industrial background may remain procedural during prototyping. Final production can combine procedural layers, TileMaps, shaders and painted images; using code is not itself a quality problem, but hiding all stable layout/content from the editor would slow visual iteration.

---

## Corpse processing is queued and directive-safe

Manual Corpse clicks enter a single processing lane instead of granting resources instantly. The prototype starts with five queue slots and a 0.65-second cycle per Corpse.

Each entry snapshots the selected Bone/Flesh/Balanced directive when queued. Changing the next-Wave directive cannot rewrite already accepted work.

Reasoning:

- visible time and capacity make the Factory a system rather than a cosmetic panel;
- full queues create pressure without silently destroying resources;
- directive snapshots close a timing exploit and make yields predictable;
- explicit capacity and speed values create clean upgrade hooks;
- automatic collection remains a purchased unlock/toggle so early manual play teaches the loop.

Rebalance cycle time and capacity from playtest evidence rather than removing the queue abstraction.

---

## Factory Points are the run-scoped machine currency prototype

Completed Waves grant one Factory Point; Elite Waves grant one additional point. Current purchases are Automated Retrieval and three levels each of queue capacity and processing speed.

Reasoning:

- Bones and Flesh remain readable army-production resources;
- machine upgrades become strategic without directly blocking emergency unit creation;
- Wave/Elite income creates predictable pacing and makes Elite victories materially valuable;
- a separate currency gives later Factory branches a common budget.

This is a prototype decision, not a locked final economy. Full-run data must determine whether point income, costs and Elite bonuses create meaningful choices or simply unlock everything on schedule.

---

## Manual batch orders are atomic

The shared production quantity accepts 1–36 units. A Skeleton or Zombie batch executes only when both the full resource cost and all requested army slots are available.

Reasoning:

- quantity controls remove repetitive clicks without making composition automatic;
- total-cost previews make the commitment readable;
- partial fulfillment would create surprising army/resource outcomes;
- reusing single-unit creation paths preserves metrics and runtime state consistency.

This instant action is temporary prototype behavior. Timed Assembler/Vat queues must be designed separately rather than silently changing batch semantics.

---

## Army Doctrine is planning-only until production has time and capacity

The player can configure Skeleton/Zombie targets, minimum Bones/Flesh reserves and a production priority. The current V1 calculates deficits and validates reserve-safe spending, but never creates a unit automatically.

Reasoning:

- instant replacement would erase battlefield attrition and emergency decisions;
- visible Assembler/Vat queues make throughput and bottlenecks legible;
- the same target can then produce different outcomes depending on upgrades and resources;
- separating policy from execution keeps the future automation testable and pausable.

Both production queues now exist. Replenishment may be activated next only through their public enqueue paths and must respect capacity, timing, reserves, army cap and an explicit pause/disable control.

---

## Production orders reserve resources and population atomically

A manual order reserves its complete Bone/Flesh cost and future army slots when accepted. Skeleton Assembler and Flesh Vat then complete one prepaid unit per cycle, independently.

Reasoning:

- later spending cannot invalidate an already accepted order;
- orders never produce a surprising partial batch because resources disappeared;
- reserved population prevents two machines from overcommitting the 36-unit cap;
- independent cycle times create a real composition/throughput tradeoff;
- the same transaction boundary can safely serve future Army Doctrine automation.

---

## Rare resources come from combat identities, not Corpse routing

Blood arrives from Elites/Bosses and paced normal kills. Souls arrive primarily from Mage/Elf kills and the Foreman. Blood Fervor is the first Blood sink; Ghost production plus Spectral Focus/Ethereal Anchor are the first Soul sinks.

Automated full runs showed the initial rare-resource rates were excessive. Normal Blood was reduced to one per eight kills before upgrades, Mage/Elf Soul drops were throttled, and Ghost cost became four Souls. These remain playtest values.

---

## Preserve the full design canvas before responsive reflow

The prototype uses a 1920×1080 absolute layout. `stretch/aspect="keep"` is required so embedded windows scale/letterbox the full canvas instead of clipping the lower menus. Container-based responsive reflow remains required before public testing.
