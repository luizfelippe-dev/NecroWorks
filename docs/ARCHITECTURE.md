# NecroWorks — Architecture

## Engine

**Godot:** 4.7.1  
**Linguagem:** GDScript  
**Tipo:** 2D

---

# Estado atual

A arquitetura ainda é propositalmente simples.

O protótipo concentra grande parte das regras em `main.gd` para permitir iteração rápida.

A prioridade atual é validar gameplay, não criar uma arquitetura final antecipadamente.

---

## Cena principal — `main.tscn`

Estrutura relevante atual:

```text
Main
├── Background
├── Skeleton
├── Enemy
├── BonesLabel
└── CreateSkeletonButton
```

Durante a execução também são criados dinamicamente:

- novos Skeletons;
- novos Enemies;
- Corpses;
- HUD de debug.

---

## `skeleton.tscn`

**Root:** `Node2D`

Função:

- cena reutilizável para Skeletons;
- instanciada dinamicamente quando o jogador gasta Bones;
- recebe estado de gameplay através do `main.gd`.

Visual:

- placeholder;
- visual temporário é garantido por código durante o protótipo.

---

## `enemy.tscn`

**Root:** `Node2D`

Função:

- cena reutilizável para Enemy;
- instanciada dinamicamente após morte do Enemy anterior;
- HP e comportamento principal são controlados atualmente pelo `main.gd`.

Visual:

- placeholder;
- visual temporário é garantido por código.

---

## `corpse.tscn`

**Root:** `Button`

Função:

- criado na posição de morte de Enemy;
- pode ser clicado;
- processamento concede Bones;
- é removido após processamento.

Esta implementação é temporária e prioriza velocidade de prototipação.

---

# `main.gd`

## Responsabilidades atuais

`main.gd` controla atualmente:

### Combate

- HP do Enemy atual;
- HP individual dos Skeletons;
- dano;
- cooldown do Enemy;
- cooldown individual dos Skeletons;
- ataque automático;
- morte de Skeleton;
- morte de Enemy.

### Movimentação

- seleção do Skeleton mais próximo para o Enemy;
- target acquisition;
- movimentação do Enemy;
- movimentação dos Skeletons;
- posições de combate;
- retarget após morte;
- posições de spawn da base.

### Entidades

- referência ao Enemy atual;
- lista de Skeletons vivos;
- registro de Skeletons;
- slots ocupados;
- criação dinâmica de Skeleton;
- criação dinâmica de Enemy;
- criação dinâmica de Corpse.

### Economia

- Bones;
- Bones por Corpse;
- custo de Skeleton;
- processamento de Corpse.

### UI / Debug

- atualização de `BonesLabel`;
- habilitação/desabilitação de `CreateSkeletonButton`;
- HUD de debug temporário.

### Visual provisório

- garante placeholder visível em Skeletons e Enemies instanciados em runtime.

---

# Estado de dados atual

Estruturas importantes usadas pelo protótipo:

```text
skeletons
skeleton_hps
skeleton_attack_timers
skeleton_slots
occupied_skeleton_slots
enemy
enemy_hp
bones
```

Os Skeletons utilizam o próprio Node como chave para estado individual durante o protótipo.

Essa solução é suficiente no estágio atual, mas poderá ser substituída por scripts próprios de unidade quando houver mais tipos de undead e atributos.

---

# Fluxo atual de combate

```text
Skeleton nasce na base
        ↓
procura Enemy atual
        ↓
move até posição de combate
        ↓
ataca automaticamente

Enemy
        ↓
procura Skeleton mais próximo
        ↓
move até o alvo
        ↓
entra em alcance
        ↓
ataca automaticamente
```

Após morte do Enemy:

```text
Enemy morre
    ↓
Corpse é criado
    ↓
Enemy é removido
    ↓
delay
    ↓
novo Enemy é instanciado
    ↓
Skeletons fazem retarget
```

---

# Fluxo econômico atual

```text
Enemy
  ↓
morte
  ↓
Corpse
  ↓
clique / processamento
  ↓
Bones
  ↓
Create Skeleton
  ↓
novo Skeleton
```

Este é o primeiro loop econômico funcional do projeto.

---

# Próxima expansão arquitetural — Waves

O próximo milestone adicionará estado de Wave ao protótipo.

A implementação inicial poderá continuar em `main.gd`.

Estado planejado:

```text
current_wave
enemies_in_wave
enemies_remaining
enemy_spawn_delay
wave_delay
wave_in_progress
```

Responsabilidades planejadas:

- iniciar Wave;
- determinar quantidade de Enemies;
- determinar HP/dano da Wave;
- contar Enemies derrotados/restantes;
- controlar delay entre Enemies;
- finalizar Wave;
- aguardar intervalo;
- iniciar próxima Wave;
- atualizar HUD.

Não criar `WaveManager` apenas por antecipação.

Se a lógica de Waves crescer a ponto de dificultar manutenção de `main.gd`, então separar.

---

# Arquitetura planejada futura

Quando a complexidade justificar, possível estrutura:

```text
Main
├── BattleManager
├── WaveManager
├── ResourceManager
├── UpgradeManager
├── FactoryManager
├── Units
├── Enemies
├── Corpses
└── UI
```

Possível direção para unidades:

```text
Unit
├── Skeleton
├── Zombie
├── Ghost
└── Abomination
```

Possível direção para inimigos:

```text
EnemyBase
├── NormalEnemy
├── EliteEnemy
└── Boss
```

Essas estruturas são apenas direção futura.

---

# Princípios arquiteturais

1. Não realizar refatorações grandes sem necessidade concreta.
2. Priorizar sistemas testáveis.
3. Evitar duplicar estado.
4. Manter gameplay funcional durante refatorações.
5. Separar responsabilidades quando o custo de manter tudo em `main.gd` superar a simplicidade atual.
6. Não iniciar arquitetura para Factory, upgrades avançados ou múltiplos recursos antes do core loop justificar.
