# Changelog

## [Unreleased] — v0.2.0 Necromantic Economy

### Added

- Resource foundation:
  - Bones;
  - Flesh;
  - Blood;
  - Souls.
- Flesh generation from Corpse processing.
- Temporary multi-resource HUD.
- `F3` toggle for compact Debug HUD.
- Zombie V1.
- Zombie production using Flesh.
- Zombie HP / attack timer / slots / metrics.
- Generic Undead targeting for Enemy.
- Generic Undead targeting for The Foreman AOE.
- Zombie frontline priority.
- Zombie metrics in Run Summary.
- Defeat condition aware of Skeletons + Zombies + Bones + Flesh + Corpses.

### Current Zombie V1 values

```text
HP: 220
Damage: 6
Cooldown: 1.1 s
Speed: 120
Cost: 6 Flesh
```

### Current resource values

```text
Bones per Corpse: 8
Flesh per Corpse: 2
Skeleton Cost: 5 Bones
Zombie Cost: 6 Flesh
```

### Verified

- Resource HUD no longer overlaps the production buttons.
- Skeleton Max HP restored to 100 after accidental test value.
- Skeleton combat remains functional.
- Flesh is generated correctly.
- Zombie button unlocks with sufficient Flesh.
- Zombie spawns and moves.
- Zombie attacks.
- Enemy attacks Zombie.
- Zombie dies and releases slot.
- Mixed Skeleton + Zombie army functions.
- Zombie frontline priority works.
- Defeat logic remains functional with mixed Undead.

### Known limitations

- Blood has no source/sink yet.
- Souls has no source/sink yet.
- Skeleton-only upgrades do not yet have Zombie equivalents.
- Mixed formation is still prototype-level.
- Skeletons still attack through the current formation abstraction.
- No ranged/magic unit yet.
- Full balance pass intentionally postponed.
- `main.gd` remains large and centralized.

---

## [0.1.0] — First Run

### Added

- Automatic combat.
- Multiple Skeletons.
- Corpses.
- Bones.
- Skeleton production.
- Waves.
- Wave scaling.
- Elite Waves.
- 10 upgrades.
- 3 random upgrade choices between Waves.
- 4 synergies.
- Run Metrics.
- Boss Wave 20.
- The Foreman.
- Industrial Crush.
- Victory.
- Game Over.
- Run Summary.
- Restart after Victory/Defeat.
- Corpse tracking for defeat logic.

### Changed

- Enemy/Boss combat moved to a controlled horizontal lane.
- Skeleton combat formation compacts after deaths.
- Combat positions are clamped to arena bounds.
- Wave progression waits for upgrade selection.

### Fixed

- Main freeze after complete army wipe.
- Boss leaving the screen due to feedback between pursuit and formation.
- Formation gaps pulling combat outside the arena.
- Premature Game Over while player still has Corpses or enough Bones to rebuild.

### Verified

- Full run from Wave 1 to Wave 20.
- Elite Waves.
- The Foreman.
- Victory flow.
- Defeat flow.
- Run Summary.
- Restart.
- Overclocked Ossuary.
- Recycling Plant.
- Second Shift.
- Bone Assembly Line unlock.

### Balance

Balance is intentionally provisional.

Known issues:

- Bones can saturate.
- Army may snowball early.
- Late-game normal Enemies can lose pressure.
- Damage/attack-speed stacking can scale strongly.
- Boss/Elites will need reevaluation after multi-unit economy exists.

---

## [0.0.3] — Waves

- Wave counter.
- Enemies per Wave.
- HP/Damage scaling.
- Elite Waves.
- Wave HUD.

## [0.0.2] — Corpse Loop

- Corpse.
- Bones.
- Skeleton production.
- Multiple Skeletons.
- Node2D migration.
- Target movement.
- Dynamic placeholders.

## [0.0.1] — Combat Prototype

- Main.
- Skeleton.
- Enemy.
- HP.
- Damage.
- Cooldown.
- Auto combat.
