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

Next design goal:

at least one Flesh/Bone cross-synergy.

Example direction:

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

Official target:

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

The user owns the conceptual reference image and authorizes close adaptation.

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
