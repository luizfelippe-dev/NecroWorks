# NecroWorks — Decisions

**Atualizado:** 18/08/2026

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
