# NecroWorks — Decisions

## Engine / Language

Godot 4.7.1 + GDScript.

## 2D / Single-player

Primeira versão permanece 2D e single-player para manter escopo viável.

## Placeholder first

Core gameplay é validado antes de arte final.

## Name

`Corpse Factory` foi substituído por **NecroWorks**.

Brand:

**Industrial Reanimation Solutions**  
**Waste Nothing. Raise Everything.**

## Core loop

```text
Enemy → Corpse → Resource → Undead
```

É a identidade central e não deve ser diluída.

## Centralized main.gd

Foi aceita centralização temporária para velocidade de prototipação.

Após `v0.1.0`, a expansão multi-unit deve iniciar refatoração incremental, sem big rewrite.

## Target-based movement

Movimentação global do exército foi substituída por perseguição baseada em target.

## Horizontal combat lane

Após bug no The Foreman:

- Enemy/Boss usa lane horizontal;
- limites de arena;
- distância horizontal;
- formação compactável.

Motivo:
eliminar feedback que arrastava Boss e Skeletons para fora da tela.

## Upgrade model

10 upgrades, 3 escolhas aleatórias, stacking permitido quando não há cap.

## Synergy model

Combinações desbloqueiam automaticamente efeitos adicionais.

## Metrics

Métricas básicas foram adicionadas antes do balanceamento.

## Boss

Wave 20 encerra a primeira run com The Foreman.

Boss precisa ameaçar a horda, não apenas um Skeleton.

## Victory

The Foreman derrotado → `finish_run(true)`.

## Defeat

Game Over só acontece quando não existe possibilidade imediata de reconstrução com Corpses/Bones.

## Restart

Protótipo usa reload completo da cena.

## Balance timing — 18/08/2026

**Decisão:** adiar o balance pass profundo até a base de economia multi-resource e primeiro novo Undead estarem implementados.

Motivo:
Skeleton-only não representa mais o estado futuro do combate e da economia. Ajustar profundamente agora causaria retrabalho.

Ainda podem ser feitos ajustes emergenciais se houver softlock ou bug de flow.

## v0.2.0 direction

A ordem será:

1. resource foundation;
2. Flesh;
3. Zombie;
4. Blood;
5. Souls/Ghost;
6. balance economy/combat.

## Visual target

A interface conceitual criada para o projeto é referência oficial.

Novas decisões devem considerar:

- battlefield central;
- resources left;
- metrics/synergies right;
- factory bottom;
- Wave/Boss top;
- dark metal;
- necromantic green;
- industrial/corporate language.

## Commercial principle

Objetivo: maximizar probabilidade de sucesso comercial na Steam, sem tratar receita como garantida.

Priorizar features que aumentem:

- diversão;
- diferenciação;
- replayability;
- legibilidade;
- valor percebido;
- capacidade de marketing.
