# NecroWorks — Architecture

**Atualizado:** 17/08/2026

## Stack

- Godot 4.7.1
- GDScript
- 2D
- Single-player
- Git/GitHub

---

# Estado atual

O projeto ainda usa arquitetura centralizada para acelerar o protótipo.

A maior parte da lógica está em `main.gd`.

Esse modelo funcionou bem para provar o core, mas o script já concentra combate, Waves, upgrades, sinergias, economia, spawning, UI e métricas.

A decisão atual é:

> fechar `v0.1.0` antes de iniciar uma refatoração grande.

---

# Scene Tree relevante

```text
Main
├── Background
├── Skeleton
├── Enemy
├── BonesLabel
└── CreateSkeletonButton
```

Criados em runtime:

```text
Skeleton instances
Enemy instances
Corpse instances
WaveLabel
UpgradePanel
UpgradeButtons
SynergyLabel
DebugLabel
```

---

# Scenes reutilizáveis

## `skeleton.tscn`

Root:
`Node2D`

Uso:

- Skeleton inicial;
- Skeleton criado manualmente;
- Skeleton gratuito por automação.

Estado individual ainda é mantido pelo `main.gd`.

## `enemy.tscn`

Root:
`Node2D`

Uso:

- Enemy da Wave;
- Elite placeholder.

Boss futuro poderá inicialmente reutilizar a scene ou ganhar scene própria após o protótipo.

## `corpse.tscn`

Root:
`Button`

Uso:

- representa Corpse;
- processável por clique;
- gera recursos;
- pode ativar automações/sinergias.

---

# Responsabilidades atuais do `main.gd`

## Combat

- skeleton HP;
- enemy HP;
- damage;
- cooldown;
- closest target;
- movement;
- attack;
- death;
- revival;
- death effects.

## Skeleton Management

- `skeletons`;
- `skeleton_hps`;
- `skeleton_attack_timers`;
- `skeleton_slots`;
- `occupied_skeleton_slots`;
- spawn positions;
- combat positions;
- máximo de 36 Skeletons;
- criação manual/gratuita.

## Enemy Management

- Enemy atual;
- Enemy spawn;
- Enemy stats;
- Elite state;
- respawn dentro da Wave.

## Corpse / Resources

- Corpse spawn;
- Corpse processing;
- Bones;
- Bones per Corpse;
- Skeleton cost;
- Bone Harvest;
- Recycling Plant.

## Waves

- current wave;
- enemies total;
- enemies defeated;
- enemy scaling;
- Wave Complete;
- Elite Wave.

## Upgrades

- pool de 10;
- random choices;
- upgrade counts;
- apply upgrade;
- caps;
- UI.

## Synergies

- condições;
- unlock;
- active synergies;
- runtime effects;
- synergy HUD.

## Metrics

- enemies killed;
- corpses processed;
- Skeletons built;
- Skeletons lost;
- Skeletons revived;
- Bones earned.

## UI

- Bones;
- Skeleton Cost;
- Waves;
- Upgrades;
- Synergies;
- Debug.

---

# Estado de dados relevante

```text
enemy
enemy_hp
enemy_max_hp
enemy_damage

skeletons
skeleton_hps
skeleton_attack_timers
skeleton_slots
occupied_skeleton_slots

bones
bones_per_corpse
skeleton_cost

current_wave
enemies_total_this_wave
enemies_defeated_this_wave

upgrade_counts
current_upgrade_choices
active_synergies

run metrics
```

---

# Fluxo de combate

```text
Skeleton
→ procura Enemy
→ move para posição de combate
→ cooldown
→ ataque

Enemy
→ procura Skeleton mais próximo
→ aproxima
→ cooldown
→ ataque
```

---

# Fluxo de Wave

```text
start_wave()
→ spawn Enemy
→ Enemy dies
→ Corpse
→ count defeated
→ next Enemy
→ Wave complete
→ show upgrade
→ apply upgrade
→ check synergy
→ next Wave
```

---

# Fluxo econômico

```text
Corpse
→ process_corpse()
→ Bones
→ optional Bone Harvest
→ optional Recycling Plant
→ optional Bone Assembly Line
→ Skeleton production
```

---

# Fluxo de morte do Skeleton

```text
HP <= 0
→ Reassembly roll
    → revive?
        → optional Second Shift
    → no revive
        → Final Service
        → remove Skeleton
```

---

# Próxima extensão arquitetural — Boss

Recomendação para o protótipo:

- adicionar estado de Boss à lógica atual;
- não refatorar tudo antes de validar;
- implementar timer do ataque especial;
- definir Boss Wave;
- ao Boss morrer, finalizar run em vez de iniciar upgrade/next Wave.

Estados novos prováveis:

```text
run_finished
run_won
boss_active
boss_special_attack_timer
```

---

# Refatoração após v0.1.0

Após a primeira run completa, `main.gd` deve ser revisado.

Possível divisão:

```text
Main
├── RunManager
├── BattleManager
├── WaveManager
├── ResourceManager
├── UpgradeManager
├── SynergyManager
├── FactoryManager
├── UnitContainer
├── EnemyContainer
├── CorpseContainer
└── UI
```

Não é obrigatório usar exatamente essa árvore.

Objetivo da refatoração:

- diminuir acoplamento;
- facilitar novos tipos de unidade;
- facilitar novos recursos;
- permitir Bosses com comportamentos próprios;
- melhorar testabilidade;
- reduzir risco de regressão.

---

# Direção para entidades

Mais adiante:

```text
UnitBase
├── Skeleton
├── Zombie
├── Ghost
└── Abomination

EnemyBase
├── BasicEnemy
├── FastEnemy
├── TankEnemy
├── RangedEnemy
├── EliteEnemy
└── BossBase
```

Cada entidade deve começar a carregar seu próprio estado quando a diversidade tornar o modelo de Dictionaries em `main.gd` difícil de manter.

---

# Direção para upgrades

O protótipo usa IDs/String + `match`.

Quando a pool crescer significativamente, considerar:

- Resource customizado de Upgrade;
- data-driven upgrade definitions;
- rarity;
- tags;
- prerequisites;
- synergy tags;
- icon;
- localization key.

Evitar migrar cedo demais.

---

# Direção para save

Meta-progressão futura exigirá:

- SaveData;
- versionamento de save;
- unlock IDs estáveis;
- migração entre versões;
- proteção contra save inválido.

Isso deve entrar antes de public demo avançada.

---

# Performance

Risco futuro importante:

- dezenas/centenas de unidades;
- múltiplos effects;
- VFX;
- corpses;
- automação.

Mais tarde medir:

- frame time;
- node count;
- allocations;
- efeitos simultâneos;
- path/movement calculations;
- rendering.

Não otimizar antes de medir.

---

# Princípios

1. Gameplay estável tem prioridade sobre arquitetura bonita.
2. Refatorar quando a complexidade justificar.
3. Não duplicar estado sem necessidade.
4. Manter IDs estáveis para upgrades/sinergias.
5. Não misturar conteúdo futuro com `CHANGELOG`.
6. Criar sistemas data-driven quando o volume de conteúdo justificar.
7. Performance deve ser medida em runs reais com hordas.
