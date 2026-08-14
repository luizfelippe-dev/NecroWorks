# Corpse Factory — Architecture

## Engine

Godot 4.7.1

Linguagem:

GDScript

---

# Estado atual

## Main

Cena:

main.tscn

Estrutura:

Main
├── Background
├── Skeleton
└── Enemy

Script:

main.gd

---

## main.gd

Atualmente controla:

- movimento do Skeleton;
- movimento do Enemy;
- distância;
- ataque;
- cooldown;
- HP;
- dano;
- morte.

Esta arquitetura é temporária.

Ela existe apenas para acelerar o primeiro protótipo.

---

# Arquitetura planejada

Quando o protótipo crescer, separar responsabilidades.

Possível estrutura futura:

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

Não realizar essa refatoração antes de haver necessidade real.

Evitar overengineering durante o protótipo.