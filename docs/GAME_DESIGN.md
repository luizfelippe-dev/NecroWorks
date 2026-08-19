# NecroWorks — Game Design Document

## High concept

> Kill enemies. Recycle the corpses. Turn them into your army.

NecroWorks mistura:

- autobattler;
- roguelite;
- resource economy;
- factory/automation;
- army growth;
- buildcrafting.

## Fantasy

O jogador administra uma operação industrial necromântica.

O cadáver do inimigo não é apenas resultado do combate.

É matéria-prima.

```text
Threat
→ Corpse
→ Inventory
→ Production
→ Undead
→ Workforce / Army
```

## Pilares

### 1. Waste Nothing

Todo cadáver deve parecer aproveitável.

### 2. Army as production

A horda não é recrutada; ela é fabricada.

### 3. Industrial necromancy

A identidade não é "necromante medieval genérico".

É:

- fábrica;
- maquinário;
- processamento;
- linha de produção;
- eficiência;
- horror corporativo.

### 4. Different resources, different builds

Recursos não devem ser apenas cores diferentes.

Cada um deve criar comportamento de build distinto.

### 5. Power fantasy

Runs fortes podem ficar exageradas.

Mas o jogo precisa oferecer ameaças e decisões até o fim.

---

# Current playable loop

```text
Enemy
→ Corpse
→ Bones + Flesh
→ Skeleton / Zombie
→ Upgrade
→ Synergy
→ Elite
→ The Foreman
→ Victory / Defeat
```

---

# Resources

## Bones

Status: implemented.

Primary identity:

- Skeleton;
- cheap production;
- swarm;
- offense;
- assembly.

Current:

```text
+8 per Corpse
Skeleton = 5 Bones
```

## Flesh

Status: implemented foundation.

Primary identity:

- Zombie;
- HP;
- tanking;
- mutation;
- mass;
- regeneration.

Current:

```text
+2 per Corpse
Zombie = 6 Flesh
```

## Blood

Status: state exists, gameplay not implemented.

Intended identity:

- sacrifice;
- temporary buffs;
- vampirism;
- risk/reward;
- burst.

Do not add Blood generation until it has a sink.

## Souls

Status: state exists, gameplay not implemented.

Intended identity:

- Ghost;
- magic;
- ranged;
- rare effects;
- supernatural automation.

---

# Undead

## Skeleton

Role:

- base DPS;
- cheap;
- quick;
- scales well with current upgrades.

Stats:

```text
HP 100
DMG 10
CD 0.7
Speed 180
Cost 5 Bones
```

## Zombie V1

Role:

- frontline;
- tank;
- Flesh sink;
- protects Skeleton-heavy formations.

Stats:

```text
HP 220
DMG 6
CD 1.1
Speed 120
Cost 6 Flesh
```

Design intent:

```text
Zombie
→ survives longer
→ deals less DPS
→ stands in front
→ gives Skeletons more uptime
```

## Ghost — planned

Role:

- ranged/magic;
- Souls;
- bypasses or changes standard formation.

## Abomination — planned

Role:

- advanced mixed-resource unit;
- expensive;
- visually distinctive.

---

# Mixed army

Current prototype order:

```text
Enemy
← Zombies
← Skeletons
```

Zombie gets frontline priority.

Future:

- formation should understand roles/tags;
- ranged units should not use melee slot abstraction forever;
- tanks may attract/modify threat.

Do not overbuild this until Ghost/ranged exists.

---

# Upgrades

Current 10 were designed around Skeleton gameplay.

Future upgrade taxonomy should include:

```text
Bone upgrades
Flesh upgrades
Blood upgrades
Soul upgrades
Factory upgrades
Universal upgrades
Mutation / cross-resource upgrades
```

Avoid making every upgrade simple `+25%`.

Rule-changing upgrades are the long-term goal.

---

# Flesh upgrade direction

Candidate first set:

### Rotten Bulk

Zombie Max HP increases.

### Grave Hunger

Zombie Damage increases.

### Dead Weight

Large Zombie HP bonus at cost of movement/attack speed.

### Carrion Recovery

Zombie recovers HP under a defined condition.

### Packed Frontline

Zombie count/formation affects survivability.

Names and exact values are provisional.

---

# Synergies

Current Bone-oriented synergies:

- Overclocked Ossuary;
- Recycling Plant;
- Second Shift;
- Bone Assembly Line.

First Flesh/Bone cross-synergy:

### Meat Shield Protocol

```text
Rotten Bulk + Rapid Assault
→ each hit absorbed by a Zombie reduces every Skeleton attack timer by 0.12 s
```

This converts frontline durability into backline tempo and creates a concrete reason to build a mixed army.

Further synergy direction:

```text
Zombie tanks damage
→ Skeleton behind gains offensive bonus
```

or:

```text
Zombie dies
→ leaves Flesh / generates production value
```

Do not lock final implementation yet.

---

# Boss

## The Foreman

Wave 20.

Boss design intent:

- attack the horde;
- punish pure single-unit scaling;
- create multi-target danger.

Industrial Crush:

- periodic;
- multi-target;
- works on Skeletons and Zombies.

---

# Living opposition

The enemies are not generic monsters. NecroWorks is opposed by living peoples whose roles create different tactical pressures.

Implemented prototype combat families:

```text
Human Warrior
→ durable frontline / standard melee pressure

Mage
→ fragile ranged attacker / high damage

Elf
→ fast skirmisher / rapid attacks
```

These labels describe combat identity, not a final moral alignment. The story should make the conflict more interesting than “living people are good” or “the necromancer is evil.” Every fallen attacker becoming factory input is central to both gameplay and narrative tension.

Current introduction curve:

```text
Wave 1  → Human Warrior
Wave 8  → Mage enters the reinforcement rotation
Wave 11 → Warrior / Mage / Elf rotation
Wave 20 → The Foreman
```

Prototype identity is communicated through labels and distinct colors. Final characters require dedicated art, animation, silhouettes, audio and richer behavior. Mage AOE/control and Elf precision targeting remain future evolutions, not current features.

## Enemy group escalation

Active-enemy pressure grows only after the player understands the basic loop:

```text
Waves 1–5   → 1 active Enemy
Waves 6–9   → up to 2
Waves 10–13 → up to 3
Waves 14–17 → up to 4
Waves 18–19 → up to 5
Wave 20     → 1 Boss
```

The first Elite on Wave 5 remains a single-target skill check. Wave 6 introduces group pressure. Defeated enemies are replenished until the Wave total is exhausted.

This curve is provisional and must be adjusted from run data; the intent is to prevent late Waves from becoming harmless one-at-a-time queues.

---

# Narrative direction — planned

NecroWorks needs an engaging story before the commercial vertical slice, presented both before a run and through discoveries during play.

Reserved pillars:

- the origin and real purpose of NecroWorks;
- the living coalition attacking the facility;
- the identity and agenda of The Foreman;
- corporate records, production logs and environmental storytelling between Waves;
- consequences of turning fallen enemies into the player’s workforce;
- revelations that advance during a run without stopping the factory/combat rhythm.

Full lore writing is intentionally deferred. Systems and content must leave space for this structure instead of committing to a shallow explanation now.

---

# Battlefield readability rules

Combat must remain visually separate from permanent HUD panels.

Current 1920×1080 rule:

```text
Right HUD begins near x=1540
Enemy/label safe limit = x=1450
```

No combatant name, health bar or body should render underneath Metrics or Active Synergies. Revisit this rule when the HUD moves to anchors/containers and other aspect ratios are supported.

The Run Summary must keep statistics, build/synergy information and actions in distinct regions. Long synergy lists may never share vertical space with the Restart button.

---

# Victory

The Foreman dies:

```text
finish_run(true)
→ Run Summary
→ Restart
```

# Defeat

Current defeat model is economic:

```text
no Undead
+ no Corpse
+ cannot afford Skeleton
+ cannot afford Zombie
→ Game Over
```

This is preferable to immediate army-wipe defeat.

## Last Stand — future

Potential later evolution:

- warning state;
- short recovery timer;
- emergency production;
- resource sacrifice.

Not implemented.

---

# Factory

Factory is a future pillar, not decoration.

Planned concepts:

- Corpse Processor;
- Skeleton Assembler;
- Flesh Vat;
- Blood Pump;
- Soul Extractor;
- automatic processing;
- queues;
- efficiency;
- routing;
- overload;
- production synergies.

Factory should create choices, not only remove clicks.

---

# Visual target

Official Visual Target V2: `assets/reference/necrodesignv2.png`. The original remains as historical reference; V2 is authoritative for future layout and art decisions.

Target structure:

- central battlefield;
- factory architecture behind/under combat;
- resource dashboard;
- production blocks;
- synergy/readout panels;
- upgrade cards;
- dark metal;
- toxic/necro green;
- bone motifs;
- industrial horror.
- readable Corpse Processor, Bone Storage, Flesh Vat and Skeleton Assembler machinery;
- persistent lower navigation for Factory and meta/system panels.

The user owns the conceptual reference image and authorizes close adaptation.

---

# Product review — commercial direction

## Verdict

The concept has a strong, explainable hook and a viable visual identity.

The current prototype proves the loop, but does not yet prove enough decision depth or production fantasy for a commercial launch.

## Strongest promise

> Every corpse becomes a production decision.

The player should repeatedly see:

```text
Enemy dies
→ body enters the operation
→ player routes/processes it
→ resources and machines react
→ a visibly different army leaves the line
```

## Main design risks

1. If Factory stays decorative, the game reads as another necromancer autobattler.
2. If every upgrade is a percentage increase, runs become mathematically different but experientially similar.
3. If corpses remain simple buttons, the best part of the fantasy lacks impact.
4. If enemies only scale HP/Damage, army composition has no real counter-pressure.
5. If the player mostly watches, the run needs meaningful routing, production and timing decisions.

## Required proof before vertical slice

- at least three army archetypes with different play patterns;
- one actual production-routing decision;
- multiple enemy roles that reward changing composition;
- rule-changing synergies, not only stat stacking;
- a satisfying corpse-processing animation/audio loop;
- readable escalation from one unit to an industrial horde;
- a run that creates at least one memorable build story.

---

# Balance philosophy

Do not balance final numbers while large system pillars are missing.

Current goal:

- units must feel different;
- resources must have sinks;
- no obvious softlocks;
- enough challenge to test systems.

Deep balance after:

- Skeleton;
- Zombie;
- Blood gameplay;
- Soul/Ghost;
- representative upgrade pool.

## Composition baseline — Wave 8

A deterministic eight-unit, no-upgrade, no-reinforcement scenario produced:

```text
8 Skeletons           → 5/12 kills, wiped at 33.2 s
8 Zombies             → 5/12 kills, wiped at 70.2 s
4 Skeletons + 4 Zombies → 7/12 kills, wiped at 51.2 s
```

The roles are meaningfully different: Skeletons provide damage, Zombies provide time, and mixed armies convert both into more progress.

The more important finding was economic: fixed Bones + Flesh output made producing both unit types automatic rather than strategic. Processing Directive V1 now lets the player bias output toward Bone, Flesh or a balanced result.

## Processing Directive V1.1 — Wave commitment implemented

The player selects the factory output for the next Wave during the between-Wave upgrade phase:

```text
Balanced    → 8 Bones + 2 Flesh
Bone Focus  → 12 Bones + 0 Flesh
Flesh Focus → 2 Bones + 6 Flesh
```

Design intent:

- Balanced preserves flexibility and naturally supports mixed armies;
- Bone Focus accelerates Skeleton production and offensive tempo;
- Flesh Focus guarantees one Zombie per Corpse and favors durable frontline growth;
- both focused modes can immediately rebuild at least one unit from the last available Corpse, avoiding an accidental no-production softlock.
- selection is free, but the route is locked for the full Wave;
- Wave 1 always uses Balanced to teach the base economy before introducing specialization;
- commitment prevents per-Corpse micro-management and asks the player to anticipate enemy composition.

Efficient Recycling increases the Bone component before directive modifiers are applied, so the upgrade remains useful in every mode.

The Run Summary records how many Corpses used each route so playtests can distinguish an actual processing strategy from the final selected button.

---

# Factory automation vision

Automation should remove repetitive clicking without removing army planning. The preferred model is an **Army Doctrine**: the player defines a target composition and the Factory attempts to maintain it.

Example:

```text
Target frontline  → 5 Zombies
Target backline   → 30 Skeletons
Zombie dies       → Flesh Vat queues one replacement
Skeleton dies     → Skeleton Assembler queues one replacement
```

The system must respect:

- available Bones, Flesh and future resources;
- the Undead population cap;
- machine throughput and queue capacity;
- production priority when multiple roles are missing;
- an optional minimum resource reserve;
- unlocked unit recipes;
- player pause/disable controls.

Target composition is strategically stronger than an unrestricted instant quantity field because it expresses intent over time. A bulk production order remains useful as a secondary manual tool, preferably with controller-friendly stepper buttons rather than free text only.

## Automation progression

```text
Manual Corpse click
→ Auto-collect unlock
→ processing queue
→ faster/multiple processing
→ production orders
→ Army Doctrine auto-replenishment
→ specialized production lines
```

Automatic processing and replenishment must have visible queues, machine activity and resource transactions. Hidden instant automation would weaken the Factory fantasy.

## Factory upgrade panel

A dedicated button should open a Factory panel without permanently covering the battlefield. Candidate run-scoped upgrade branches:

- Corpse Processor: collection radius, queue capacity and processing speed;
- Skeleton Assembler: throughput, batch size and Bone efficiency;
- Flesh Vat: Zombie production speed, durability recipes and recovery;
- Logistics: target composition slots, priority rules and resource reserve;
- Advanced Research: Archer, Lich and future unit recipes;
- Routing: specialized directives and multi-output processing.

The currency for Factory upgrades is still an open design question. Do not automatically charge Bones/Flesh if that makes upgrading compete too directly with producing the army; Wave/Elite-earned Factory points are a candidate for prototyping.

## Planned Undead roles

```text
Skeleton Warrior → cheap melee damage / base Bone recipe
Skeleton Archer  → ranged Bone damage / unlockable recipe
Zombie Tank      → durable frontline / Flesh recipe
Lich             → rare caster-support / unlockable advanced recipe
```

The Lich may summon temporary Skeletons, but summoning needs a cooldown, cap or resource cost so it cannot create infinite exponential growth. Adding Archer or Lich requires the generic Undead runtime refactor first; duplicating another full family of arrays and dictionaries is not acceptable.

## Menus, settings and localization

Required languages are PT-BR, English and Spanish. Translation keys/resources should be introduced before the UI expands into multiple Factory and meta-progression panels. Final translation and linguistic QA happen after interface copy stabilizes.

The vertical slice requires:

- Main Menu;
- Continue/New Run flow when saves exist;
- Pause Menu;
- Options for audio, display, language and accessibility basics;
- remappable controls where practical;
- persistent settings and versioned save data.
