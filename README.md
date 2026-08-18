# NecroWorks

> **Industrial Reanimation Solutions**  
> **Waste Nothing. Raise Everything.**

**NecroWorks** é um roguelite 2D de autobattler, estratégia, automação e progressão incremental, desenvolvido em **Godot 4.7.1** com **GDScript**.

A fantasia central é transformar o campo de batalha em uma linha de produção necromântica:

```text
Enemy
→ Corpse
→ Processing
→ Resources
→ Undead
→ Bigger Army
→ Upgrades
→ Synergies
→ Elites / Boss
→ Victory ou Defeat
```

## Estado do projeto

**Milestone funcional atual:** `v0.1.0 — First Run`  
**Status:** funcionalmente completo e validado em playtest.  
**Próxima fase:** `v0.2.0 — Necromantic Economy`.

> O balanceamento atual ainda não é definitivo. Um balance pass completo será feito depois que a economia multi-resource e os primeiros novos Undead estiverem representados, para evitar balancear um sistema que logo mudará de forma significativa.

## O que já existe

- combate automático;
- movimentação por alvo;
- formação compactável;
- Skeletons com HP/cooldown individuais;
- Enemy respawn;
- Corpses;
- Bones;
- criação de Skeleton;
- Waves;
- Elite Waves;
- 10 upgrades;
- escolha de 3 upgrades aleatórios;
- 4 sinergias;
- métricas de run;
- Boss Wave 20;
- The Foreman;
- ataque AOE `Industrial Crush`;
- Victory;
- Game Over;
- Run Summary;
- Restart após vitória ou derrota;
- primeira run completa validada do início ao fim.

## Boss atual

### The Foreman

Wave 20.

- 1 Boss;
- 2200 HP;
- 28 Damage;
- visual maior/roxo no protótipo;
- `Industrial Crush` aproximadamente a cada 4 s;
- atinge até 6 Skeletons;
- 35 de dano por alvo;
- derrota encerra a run com Victory.

## Upgrades atuais

| Upgrade | Efeito |
|---|---|
| Sharpened Bones | +25% Skeleton Damage |
| Bone Plating | +25 Skeleton Max HP |
| Efficient Recycling | +2 Bones/Corpse |
| Rapid Assault | +15% Attack Speed |
| Death March | +20% Movement Speed |
| Mass Production | -1 Bone no custo de Skeleton |
| Heavy Bones | +50% Damage, -20% Attack Speed |
| Bone Harvest | chance de Bones extras |
| Reassembly | chance de Skeleton reviver |
| Final Service | dano ao Enemy quando Skeleton morre |

## Sinergias atuais

| Sinergia | Requisitos | Efeito |
|---|---|---|
| Recycling Plant | Efficient Recycling + Bone Harvest | dobra o bônus de Bone Harvest |
| Second Shift | Reassembly + Final Service | revive também causa parte do Final Service |
| Bone Assembly Line | Mass Production + Efficient Recycling | chance de produzir Skeleton grátis |
| Overclocked Ossuary | Heavy Bones + Rapid Assault | chance de Double Strike |

## Stack

- Godot 4.7.1
- GDScript
- 2D
- Windows
- single-player
- Steam como plataforma comercial inicial
- Git + GitHub

## Direção visual oficial

A referência visual definida para NecroWorks é uma interface dark-fantasy industrial/corporativa criada para o próprio projeto.

Estrutura desejada:

- battlefield central;
- Wave/Boss no topo;
- recursos na lateral;
- Run Metrics e Active Synergies à direita;
- área de produção/fábrica na parte inferior;
- cards de upgrade contextuais;
- metal escuro;
- verde necromântico;
- ossos;
- máquinas;
- sinalização industrial/corporativa.

Durante o protótipo, placeholders continuam aceitáveis. A migração visual será incremental.

## Desenvolvimento

```text
implementar
→ testar
→ corrigir
→ documentar
→ commit
→ próxima funcionalidade
```

Consulte `docs/ROADMAP.md` e `docs/AI_HANDOFF.md`.
