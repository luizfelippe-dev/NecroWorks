# NecroWorks — Devlog

## 14/08/2026 — Combat Prototype

Criado:

- Main;
- Skeleton;
- Enemy;
- movement;
- HP;
- damage;
- cooldown;
- auto combat.

## 14–16/08/2026 — Corpse Loop

Adicionado:

- Corpse;
- Bones;
- processing;
- Skeleton production;
- multiple Skeletons;
- individual HP/cooldown;
- Enemy respawn.

Loop validado:

```text
Enemy → Corpse → Bones → Skeleton
```

## 16/08/2026 — Movement V1

- Node2D;
- dynamic placeholder visuals;
- target movement;
- retarget;
- combat slots;
- debug HUD.

## 17/08/2026 — Waves

- Wave counter;
- scaling;
- Elite Waves;
- Wave HUD.

## 17/08/2026 — Upgrades

Primeiro 3, depois pool de 10.

- random selection;
- stacking;
- caps.

## 17/08/2026 — Synergies

- Overclocked Ossuary;
- Recycling Plant;
- Second Shift;
- Bone Assembly Line.

Run Metrics adicionadas.

## 17/08/2026 — Long Playtest

Chegou à Wave 21.

Conclusão:
sistemas estáveis, porém economia/poder muito generosos.

## 17/08/2026 — The Foreman

Wave 20 virou Boss.

Adicionado:

- The Foreman;
- 2200 HP;
- Industrial Crush;
- multi-target.

### Bug

Boss podia sair da tela.

### Fix

- horizontal lane;
- bounds;
- compact combat formation.

Fix validado.

## 17–18/08/2026 — Run Ending

Adicionado:

- Victory;
- Run Summary;
- Restart;
- Corpse tracking;
- formal Defeat;
- Game Over;
- Restart after defeat.

## 18/08/2026 — First Complete Run

A primeira run completa do estado normal foi testada com sucesso.

`v0.1.0 — First Run` está funcionalmente completo.

### Decisão

Não fazer balanceamento profundo ainda.

A economia Skeleton-only será substituída/expandida em seguida. O próximo balance pass importante deve considerar múltiplos recursos e pelo menos Skeleton + Zombie.

## Próximo trabalho

`v0.2.0 — Necromantic Economy`

Primeiro:

- resource foundation;
- Flesh/Blood/Souls state;
- Resource HUD.

Logo depois:

- Flesh processing;
- Zombie.
