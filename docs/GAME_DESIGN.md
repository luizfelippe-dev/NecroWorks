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

Factory Points are now the active run-scoped prototype currency. A completed Wave grants 1 point and an Elite Wave grants 1 bonus point. This keeps machine investment separate from emergency army production with Bones/Flesh. Income and prices remain provisional and require full-run playtests before becoming a permanent economy decision.

Current Corpse Processor branch:

```text
Automated Retrieval → one-time unlock for a reversible auto-collection toggle
Queue Expansion     → 3 levels / +2 queue slots per level
Processor Overclock → 3 levels / -0.10 s cycle time per level
```

Automation may fill only available queue slots. Overflow Corpses remain manually available on the battlefield.

Manual unit production now supports a shared typed quantity from 1 to 36. Buttons preview the total cost and execute only if the whole order can be afforded and placed. This removes repetitive clicking without making production autonomous.

Manual batch orders now reserve their full cost and population, then enter separate timed machines. Skeleton Assembler produces one unit every 0.45 s; Flesh Vat produces one every 0.80 s. Each supports three pending orders and both operate in parallel. These provisional values make Skeleton replacement faster while Zombie durability carries a throughput cost.

Army Doctrine V1 supports a combined maximum of 36 Undead, separate Skeleton/Zombie targets, Bones/Flesh reserves and Balanced/Skeleton-first/Zombie-first priority. The player explicitly starts or pauses replenishment. Missing units are discounted by existing queued production, then paid and committed through the same timed machines used by manual orders. Balanced shares scarce population capacity between both lines; focused priorities allocate it to the selected line first.

## Blood and Souls

Blood is a tempo resource. Blood Fervor consumes 3 Blood (2 with Crimson Assembly) to amplify all Undead damage for the current Wave. Hematic Extraction improves generation cadence; Crimson Infusion strengthens the buff.

Hematic Press V1 adds a costly alternate source: unlocking costs 3 Factory Points and each queued cycle converts 12 Flesh into 1 Blood over 2 seconds. The intent is not passive income; the player sacrifices three-dimensional Flesh value—Zombie bodies, reserves and future automation—to accelerate Ritual timing.

Souls are a composition/research resource. Four Souls summon a ranged Ghost. Spectral Focus increases Ghost damage, Ethereal Anchor increases durability, and Phantom Conduit improves casting cadence. Mage/Elf/Boss identities control Soul income so enemy composition affects economy.

Soul Extractor V1 turns those identities into visible routing. After a 4-Point unlock, arcane routing sends Mage/Elf Corpses to a separate 2.5-second queue for Souls; common Corpses and arcane routing when paused continue through material recovery. The player therefore gives up immediate army resources to accelerate Ghost/research access. Industrial Efficiency has three levels, reducing Hematic cost by 2 Flesh and Soul cycle time by 0.25 s per level. Hematic Press plus Efficiency II unlocks Dark Refinery for an additional 2-Flesh discount.

Full-run validation preserves current Bone/Flesh pacing: Balanced remains the Wave 1 recovery route, Bone Focus sustains high Skeleton turnover, and Flesh Focus supports a slower but durable Zombie army. Perfect automated play fills the army cap in both builds, so v0.3 machine/logistics sinks must address late stock saturation.

## Planned Undead roles

```text
Skeleton Warrior → cheap melee damage / base Bone recipe
Skeleton Archer  → ranged Bone damage / unlockable recipe (playable V1)
Zombie Tank      → durable frontline / Flesh recipe
Ghost            → ranged magic / Soul recipe (playable V1)
Lich             → rare caster-support / temporary summoner (playable V1)
```

The Lich costs 8 Souls after a 5-Factory-Point blueprint. Each summon costs 1 Soul, has a 10-second base cooldown, lasts 15 seconds and shares a global six-Thrall cap. Thralls occupy ordinary army capacity and therefore trade short-term tempo against permanent production. They do not trigger permanent Skeleton death upgrades or metrics. Grave Contract, Rapid Conjuration and Bound Servitude form the first summoner upgrade package; Soul Foundry improves future Thralls.

Skeleton Archer and Lich both use the generic Undead runtime instead of copied state families. Ossuary Ballistics connects the Archer blueprint to Heavy Bones + Death March and adds range rather than raw damage, reinforcing formation identity.

## Advanced living-enemy behavior

Human Warrior remains the readable baseline. Mage and Elf now create counter-pressure against dense and backline-heavy armies:

- Arcane Burst occurs every third Mage attack, hits the primary target plus up to two nearby Undead for half splash damage, and delays their next attack by 0.30 seconds;
- Precision Shot occurs every fourth Elf attack, prioritizes Lich, Ghost and Skeleton Archer roles over frontline units, then breaks ties by lowest HP ratio, and deals 135% damage.

These intervals allow the player to read and anticipate pressure instead of receiving constant unavoidable special attacks. Zombies still protect against ordinary attacks, but ranged/summoner compositions need redundancy and recovery.

## Rare upgrade foundation

Emergency Reclamation enters the ordinary three-card roll from Wave 8 onward and can be selected once. The first permanent Undead death in each Wave refunds 50% of its current production cost, rounded down with a minimum of one. It applies to Bone, Flesh and Soul recipes but ignores temporary Thralls.

The upgrade changes loss economics without preventing death. Its once-per-Wave limit preserves attrition, while recipe-aware refunds reward expensive composition choices without generating resources from free summons.

## Elite variants

Elite Waves retain their five-enemy structure on Waves 5, 10 and 15, but archetypes now intensify their existing counter-role:

- Bulwark Warrior takes 20% less incoming damage, extending frontline obstruction;
- Overcharged Mage casts Arcane Burst every second attack with 65% splash and 0.45-second suppression;
- Deadeye Elf casts Precision Shot every third attack for 150% damage.

The Elite trait is visible above the unit before combat contact. The intent is preparation and composition pressure, not surprise one-shots. The Foreman is a separate Boss ruleset and never inherits Elite modifiers.

## Menus, settings and localization

Required languages are PT-BR, English and Spanish. Translation keys/resources should be introduced before the UI expands into multiple Factory and meta-progression panels. Final translation and linguistic QA happen after interface copy stabilizes.

The vertical slice requires:

- Main Menu;
- Continue/New Run flow when saves exist;
- Pause Menu;
- Options for audio, display, language and accessibility basics;
- remappable controls where practical;
- persistent settings and versioned save data.

V1 status: Main Menu, Pause, Continue/New Run, language, master volume, fullscreen and versioned run checkpoints are implemented. Continue resumes from a recorded Wave with permanent strategic state; it does not promise a frame-perfect mid-combat resume.
