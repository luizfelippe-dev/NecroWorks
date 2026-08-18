# NecroWorks

> **Industrial Reanimation Solutions**  
> **Waste Nothing. Raise Everything.**

**NecroWorks** é um roguelite 2D de autobattler, estratégia, economia e automação necromântica desenvolvido em **Godot 4.7.1** com **GDScript**.

## High concept

> **Kill enemies. Recycle the corpses. Turn them into your army.**

Loop central:

```text
Enemy
→ Corpse
→ Processing
→ Resources
→ Undead
→ Army Growth
→ Upgrades
→ Synergies
→ Elites / Boss
→ Victory ou Defeat
```

## Estado atual

### `v0.1.0 — First Run`

Funcionalmente completo e validado:

- combate automático;
- Corpses;
- Bones;
- Skeleton production;
- Waves;
- Elite Waves;
- 10 upgrades;
- 4 sinergias;
- Run Metrics;
- Boss Wave 20;
- The Foreman;
- Victory;
- Defeat;
- Run Summary;
- Restart.

> O status exato da tag Git `v0.1.0` deve ser verificado com `git tag`. A documentação confirma o milestone funcional, não presume que a tag já foi publicada.

### `v0.2.0 — Necromantic Economy`

Em desenvolvimento e já validado parcialmente:

- resource foundation com Bones, Flesh, Blood e Souls;
- Corpse processado gera Bones + Flesh;
- HUD temporário de Resources;
- Debug oculto por padrão e alternável com `F3`;
- Zombie V1 implementado e testado;
- Enemy/Boss atacam Skeletons e Zombies;
- Zombies priorizados na frontline;
- Game Over considera Bones, Flesh, Skeletons, Zombies e Corpses.

## Economia atual

```text
CORPSE
├── + Bones
└── + Flesh
```

Valores atuais:

```text
Bones per Corpse: 8
Flesh per Corpse: 2

Skeleton Cost: 5 Bones
Zombie Cost: 6 Flesh
```

Blood e Souls já existem no estado do jogo, mas ainda não possuem geração/sink próprios.

## Undead atuais

### Skeleton

```text
HP: 100
Damage: 10
Attack Cooldown: 0.7 s
Movement Speed: 180
Cost: 5 Bones
Role: DPS / unidade base
```

### Zombie V1

```text
HP: 220
Damage: 6
Attack Cooldown: 1.1 s
Movement Speed: 120
Cost: 6 Flesh
Role: Tank / Frontline
```

O Zombie usa placeholder verde no protótipo.

## Boss atual

### The Foreman

Wave 20.

```text
HP: 2200
Damage: 28
Industrial Crush:
- aproximadamente a cada 4 s
- até 6 Undead
- 35 damage por alvo
```

Derrotá-lo encerra a run com Victory.

## Upgrades atuais

1. Sharpened Bones
2. Bone Plating
3. Efficient Recycling
4. Rapid Assault
5. Death March
6. Mass Production
7. Heavy Bones
8. Bone Harvest
9. Reassembly
10. Final Service

## Synergies atuais

- Recycling Plant
- Second Shift
- Bone Assembly Line
- Overclocked Ossuary

## Direção visual oficial

A interface conceitual criada para o próprio NecroWorks é o target visual principal.

Estrutura:

- battlefield central;
- Wave/Boss no topo;
- recursos à esquerda;
- Run Metrics e Active Synergies à direita;
- fábrica/produção na faixa inferior;
- cards de upgrade contextuais na parte inferior;
- metal escuro;
- verde necromântico;
- ossos;
- maquinário industrial;
- horror corporativo.

O protótipo ainda usa placeholders, mas novos sistemas devem respeitar essa direção.

## Stack

- Godot 4.7.1 stable
- GDScript
- 2D
- single-player
- Windows primeiro
- Steam como plataforma comercial inicial
- Git + GitHub

## Workflow

```text
implementar
→ testar
→ corrigir
→ documentar
→ commit
→ push
→ próxima funcionalidade
```

Consulte `docs/AI_HANDOFF.md` antes de continuar o desenvolvimento em outro chat.
