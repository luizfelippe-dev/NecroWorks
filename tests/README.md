# NecroWorks Test Harnesses

## Composition balance

Runs three deterministic, upgrade-free armies against Wave 8 using the real runtime combat:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/balance/composition_scenario_runner.gd
```

Baseline army size: 8.

| Scenario | Wave 8 kills | Survival time | Outcome |
|---|---:|---:|---|
| 8 Skeletons | 5 / 12 | 33.2 s | wiped |
| 8 Zombies | 5 / 12 | 70.2 s | wiped |
| 4 Skeletons + 4 Zombies | 7 / 12 | 51.2 s | wiped |

Interpretation:

- Skeletons provide damage but collapse quickly;
- Zombies materially extend survival but do not improve kill count alone;
- the mixed army converts frontline durability into more total kills;
- Wave 8 is not intended to be cleared by eight base units without upgrades, processing or reinforcement.

This is a regression baseline, not a final balance target. Run with the exact fixed-FPS command so simulated-time results remain comparable.

## Processing directives

Validates Balanced, Bone Focus and Flesh Focus yields, Wave locking, UI bounds, Corpse consumption and Efficient Recycling compatibility:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/economy/processing_directive_runner.gd
```

Current base yields:

| Directive | Per Corpse | Six-Corpse production capacity |
|---|---:|---:|
| Balanced | 8 Bones + 2 Flesh | 9 Skeletons + 2 Zombies |
| Bone Focus | 12 Bones + 0 Flesh | 14 Skeletons |
| Flesh Focus | 2 Bones + 6 Flesh | 2 Skeletons + 6 Zombies |

Wave 1 is fixed to Balanced. Directive controls unlock between Waves and lock again when the next Wave starts.

## Unit sprites

Validates that every current unit visual resolves to a real texture, respects the 512 px runtime import cap and that the main Skeleton/Enemy instances no longer use square debug visuals:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --path . `
  --script res://tests/visual/unit_sprite_runner.gd
```

## Corpse processing feedback

Validates settled rewards, directive-aware signal payload, animated feedback creation, Resources panel recovery and automatic transient-node cleanup:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/visual/corpse_processing_feedback_runner.gd
```

## Localization foundation

Validates English, PT-BR and Spanish resource registration, regional locale normalization and live HUD refresh:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/localization/localization_runner.gd
```

## Corpse Processor queue

Validates five-slot capacity, delayed resource settlement, full-queue rejection and directive snapshots:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/corpse_processor_runner.gd
```

## Factory automation

Validates locked auto-collection, Wave/Elite Factory Point income, purchases, reversible toggling, automatic queue refill and capacity/speed upgrades:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/factory_automation_runner.gd
```

## Manual batch production

Validates Skeleton/Zombie batch counts, total costs, emitted transaction payloads and all-or-nothing rejection for insufficient resources or army capacity:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/batch_production_runner.gd
```

## Army Doctrine planning

Validates atomic target configuration, 36-unit cap rejection, live deficits, minimum-resource reserves, priority synchronization and localized visible UI. It also confirms that planning does not trigger instant replenishment:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/army_doctrine_runner.gd
```
