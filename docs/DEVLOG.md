# NecroWorks — Devlog

## 14/08/2026 — Projeto iniciado

### Implementado

- Godot 4.7.1.
- Main.
- Background.
- Skeleton placeholder.
- Enemy placeholder.
- movimento.
- HP.
- ataque automático.
- cooldown.
- morte.

### Resultado

Primeiro combate automático funcional.

---

## 14/08/2026 — Corpse Processing

### Implementado

- Enemy gera Corpse.
- Corpse aparece na posição de morte.
- Corpse processável.
- Bones.
- Bones HUD.
- Create Skeleton.

### Primeiro loop

```text
Enemy → Corpse → Bones → Skeleton
```

---

## 15/08/2026 — Multiple Skeleton Combat

### Implementado

- múltiplos Skeletons;
- HP individual;
- cooldown individual;
- Enemy escolhe alvo;
- morte individual.

---

## 15/08/2026 — Continuous Enemy Spawning

### Implementado

- Enemy respawn;
- HP reset;
- Corpses persistem;
- reconstrução após perda total do exército.

### Bug corrigido

O Main não é mais congelado quando todos os Skeletons morrem.

---

## 16/08/2026 — Node2D Migration

Skeleton e Enemy migrados para Node2D.

Problema observado:

- entidades dinâmicas existiam e lutavam;
- algumas não eram renderizadas.

Correção:

- placeholder visual garantido por código.

---

## 16/08/2026 — Target-Based Combat Movement

### Implementado

- Skeleton persegue Enemy;
- Enemy persegue Skeleton mais próximo;
- spawn na base;
- slots de combate;
- retarget;
- HUD de debug.

### Resultado

Movement v1 estabilizado.

---

## 16/08/2026 — Project Rename

`Corpse Factory` passa a se chamar **NecroWorks**.

Brand:

**NecroWorks**  
*Industrial Reanimation Solutions*  
**Waste Nothing. Raise Everything.**

---

## 17/08/2026 — Wave System

### Implementado

- Wave counter;
- Enemies per Wave;
- Enemies Remaining;
- Enemy HP scaling;
- Enemy Damage scaling;
- delay de spawn;
- Wave Complete;
- Elite Wave a cada 5;
- Wave HUD.

### Playtest

O sistema avançou por muitas Waves sem travar.

### Descoberta

A economia original de 5 Bones/Corpse fazia a run entrar em reposição sem crescimento.

Ajuste temporário:

- Bones/Corpse: 8;
- Enemy base damage: 7.

O ajuste facilitou crescimento e testes.

---

## 17/08/2026 — First Upgrade Selection

### Implementado

- Wave aguarda escolha;
- 3 cards;
- Sharpened Bones;
- Bone Plating;
- Efficient Recycling.

### Resultado

Efeitos acumuláveis funcionando.

---

## 17/08/2026 — Upgrade Pool Expanded

Pool expandida para 10:

- Sharpened Bones;
- Bone Plating;
- Efficient Recycling;
- Rapid Assault;
- Death March;
- Mass Production;
- Heavy Bones;
- Bone Harvest;
- Reassembly;
- Final Service.

### Implementado

- 3 opções aleatórias;
- sem repetição dentro da seleção;
- upgrade counts;
- caps;
- efeitos runtime.

---

## 17/08/2026 — Synergies & Run Metrics

### Sinergias implementadas

#### Overclocked Ossuary

Heavy Bones + Rapid Assault.

20% de chance de Double Strike.

#### Recycling Plant

Efficient Recycling + Bone Harvest.

Dobra bônus do Bone Harvest.

#### Second Shift

Reassembly + Final Service.

Revive também causa parte do Final Service.

#### Bone Assembly Line

Mass Production + Efficient Recycling.

Chance de Skeleton gratuito ao processar Corpse.

### Métricas

Adicionado:

- Enemies Killed;
- Corpses Processed;
- Skeletons Built;
- Skeletons Lost;
- Skeletons Revived;
- Bones Earned.

---

## 17/08/2026 — Long Synergy Playtest

### Resultado

Playtest avançou até Wave 21.

Foram observados:

- Elite Waves;
- Overclocked Ossuary com múltiplos Double Strikes;
- Recycling Plant dobrando Bone Harvest;
- Second Shift disparando após Reassembly;
- Bone Assembly Line desbloqueada;
- Skeleton count alto;
- economia acumulando grande quantidade de Bones.

O processo foi encerrado manualmente durante Wave 21.

Não foi observado erro de runtime aparente no log analisado.

### Pendência

Bone Assembly Line:

- unlock confirmado;
- código de proc implementado;
- ainda falta observar explicitamente uma produção gratuita no log.

### Balanceamento

A run está fácil demais quando o exército cresce.

Isso é conhecido e intencionalmente deixado para um balance pass posterior.

---

## Próxima etapa

### Boss / First Run Ending

Planejado:

```text
Wave 20
→ Boss: The Foreman
→ ataque multi-target
→ Boss death
→ Victory
→ Run Summary
→ Restart
```

Também falta:

- Game Over;
- Restart após derrota;
- fluxo completo;
- balance pass inicial.

Objetivo:
fechar `v0.1.0 — First Run`.
