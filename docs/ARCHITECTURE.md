# NecroWorks — Architecture

**Atualizado:** 18/08/2026

## Stack

- Godot 4.7.1
- GDScript
- 2D
- Git/GitHub

## Estado

A lógica continua majoritariamente centralizada em `main.gd`.

Isso foi intencional para provar `v0.1.0`.

O arquivo já concentra:

- combat;
- skeleton state;
- enemy state;
- corpse/resource;
- waves;
- upgrades;
- synergies;
- Boss;
- run end;
- UI;
- metrics.

## Scenes

```text
main.tscn
skeleton.tscn
enemy.tscn
corpse.tscn
```

## Runtime UI

- Wave HUD
- Upgrade UI
- Synergy HUD
- Debug HUD
- Run End panel

## Skeleton state

```text
skeletons
skeleton_hps
skeleton_attack_timers
skeleton_slots
occupied_skeleton_slots
```

## Corpses

Agora são rastreados em:

```gdscript
var corpses: Array[Button] = []
```

Isso permite saber se ainda existe matéria-prima para recuperação antes de declarar Game Over.

## Movement model

Enemy/Boss:

- lane horizontal;
- Y fixo;
- X limitado;
- target via distância horizontal.

Skeleton:

- spawn slot persistente;
- combat slot compactado;
- formação fecha buracos;
- target position limitada à arena.

## Wave / Boss

Wave 20 é Boss.

Estado:

```text
boss_active
boss_special_attack_timer
run_finished
run_won
```

Boss defeated:

```text
finish_run(true)
```

Defeat:

```text
Skeletons == 0
AND Corpses == 0
AND Bones < Skeleton Cost
→ finish_run(false)
```

Restart:

```gdscript
get_tree().reload_current_scene()
```

## Próxima necessidade arquitetural

`v0.2.0` adicionará múltiplos recursos e tipos de Undead.

O maior risco é continuar tratando tudo como "Skeleton" internamente.

Antes de adicionar muitos tipos, migrar progressivamente para um conceito genérico de **Undead Unit**.

Direção provável:

```text
Undead
├── Skeleton
├── Zombie
├── Ghost
└── Abomination
```

O Enemy deve mirar `undead_units`, não um array exclusivo de Skeletons.

## Refatoração recomendada

Fazer incrementalmente durante v0.2.0, não uma reescrita total.

Primeiro:

- resource state central;
- `undead_units`;
- unit type metadata.

Depois, quando estável:

- ResourceManager;
- WaveManager;
- UpgradeManager;
- FactoryManager.

## Data-driven futuro

Quando a quantidade crescer:

- Upgrade Resource;
- UnitDefinition Resource;
- EnemyDefinition Resource;
- tags;
- rarity;
- costs;
- icons;
- localization keys.

Não fazer prematuramente.

## Performance

Com mais Undead:

- medir node count;
- frame time;
- attack loops;
- visual effects;
- corpse count;
- path/movement work.

Otimizar somente após medição.
