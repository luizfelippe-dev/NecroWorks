# NecroWorks — AI Handoff

**Última atualização:** 17/08/2026

Este arquivo é a principal fonte de continuidade do projeto. Ele deve permitir que outra conversa continue o desenvolvimento sem depender do histórico completo.

---

# 1. Identidade

**Nome:** NecroWorks  
**Brand line:** Industrial Reanimation Solutions  
**Slogan:** Waste Nothing. Raise Everything.

Nome anterior do protótipo: `Corpse Factory`.

---

# 2. Visão do produto

NecroWorks é um roguelite 2D de autobattler, estratégia e automação necromântica.

Fantasia central:

> matar inimigos, reciclar cadáveres, transformar matéria-prima em um exército e escalar a operação até uma horda industrial.

Loop pretendido:

```text
Enemy
→ combate automático
→ Corpse
→ processamento
→ recursos
→ produção de Undead
→ crescimento do exército
→ Waves
→ upgrades
→ sinergias
→ elites/bosses
→ fim da run
```

Pilares:

- poucas regras, muitas interações;
- exército parcialmente descartável;
- cadáver como recurso econômico;
- identidade de necromancia industrial/corporativa;
- runs fáceis de entender e difíceis de otimizar;
- forte potencial visual e de compartilhamento;
- escopo viável para desenvolvimento solo.

---

# 3. Stack

- Godot 4.7.1
- GDScript
- 2D
- Single-player
- Windows como primeira plataforma
- Steam como distribuição comercial planejada
- Git + GitHub

O projeto trata warnings de GDScript com rigor. Preferir tipagem explícita e evitar inferência ambígua de `Variant`.

---

# 4. Estado de versão

**Última tag estável:** `v0.0.3`  
**Em desenvolvimento:** `v0.1.0 — First Run`

`v0.1.0` ainda não deve ser tagueada.

---

# 5. Estado atual — implementado

## Combate

- Skeleton e Enemy em Node2D.
- Movimento baseado em target.
- Enemy procura Skeleton mais próximo.
- Skeletons procuram Enemy atual.
- Retarget automático.
- HP individual de Skeleton.
- Cooldown individual de Skeleton.
- Dano.
- Enemy attack cooldown.
- Skeleton death.
- Enemy death.

## Economia

- Corpse.
- Clique/processamento de Corpse.
- Bones.
- `bones_per_corpse = 8` temporariamente.
- Skeleton Cost base = 5.
- Criação manual de Skeleton.
- Limite atual de 36 Skeletons.

## Waves

- Wave counter.
- Enemies por Wave.
- Enemies Remaining.
- Delay de 0.5 s entre Enemies.
- HP scaling.
- Damage scaling.
- Elite Wave a cada 5 Waves.
- Elite com 5 Enemies, HP multiplicado e dano extra.
- Upgrade selection obrigatória ao finalizar Wave.

## Upgrades

Pool atual: 10.

1. Sharpened Bones — +25% Skeleton Damage.
2. Bone Plating — +25 Max HP e +25 HP nos Skeletons vivos.
3. Efficient Recycling — +2 Bones/Corpse.
4. Rapid Assault — +15% Attack Speed.
5. Death March — +20% Movement Speed.
6. Mass Production — -1 Bone no custo de Skeleton, mínimo 1.
7. Heavy Bones — +50% Damage e -20% Attack Speed.
8. Bone Harvest — +20% chance por stack de +5 Bones extras.
9. Reassembly — +15% chance por stack de reviver com 50% HP.
10. Final Service — +20 de dano por stack quando Skeleton morre.

Três upgrades são sorteados sem repetição dentro da seleção.

Upgrades limitados deixam de aparecer ao atingir seus tetos.

## Sinergias

### Overclocked Ossuary

Heavy Bones + Rapid Assault.

Efeito:
20% de chance de Skeleton atacar duas vezes.

**Runtime validado.**

### Recycling Plant

Efficient Recycling + Bone Harvest.

Efeito:
dobra o bônus de Bone Harvest.

**Runtime validado.**

### Second Shift

Reassembly + Final Service.

Efeito:
quando Reassembly salva um Skeleton, o revive também causa 50% do dano de Final Service.

**Runtime validado.**

### Bone Assembly Line

Mass Production + Efficient Recycling.

Efeito:
25% de chance de produzir Skeleton grátis ao processar Corpse.

**Desbloqueio validado.**
O código do efeito está implementado, mas ainda falta registrar explicitamente um proc de Skeleton gratuito em playtest.

## Run Metrics

HUD de debug registra:

- Enemies Killed;
- Corpses Processed;
- Skeletons Built;
- Skeletons Lost;
- Skeletons Revived;
- Bones Earned;
- quantidade de upgrades;
- quantidade de sinergias.

---

# 6. Último playtest relevante

Em 17/08/2026 foi executado um teste longo.

Resultados observados:

- Waves continuaram progredindo.
- Wave 5, 10, 15 e 20 funcionaram como Elite Waves.
- O teste chegou à Wave 21.
- Overclocked Ossuary disparou repetidamente.
- Recycling Plant dobrou o bônus de Bone Harvest.
- Second Shift disparou após Reassembly.
- Bone Assembly Line foi desbloqueada.
- Não houve erro de runtime aparente no log analisado.
- O teste foi encerrado manualmente durante Wave 21.

Problema de balanceamento conhecido:

- a economia atual permite crescimento muito rápido;
- o exército pode chegar próximo do limite cedo;
- Bones acumulam em excesso;
- Waves deixam de representar ameaça adequada quando a horda cresce.

**Decisão:** não realizar balanceamento definitivo antes de fechar a primeira run e principais sistemas.

---

# 7. Arquitetura atual

Cena principal relevante:

```text
Main
├── Background
├── Skeleton
├── Enemy
├── BonesLabel
└── CreateSkeletonButton
```

Criados dinamicamente:

- Skeletons;
- Enemies;
- Corpses;
- Wave HUD;
- Upgrade UI;
- Synergy HUD;
- Debug HUD.

Scenes:

- `main.tscn`
- `skeleton.tscn`
- `enemy.tscn`
- `corpse.tscn`

Script principal:

- `main.gd`

A maior parte da lógica ainda está centralizada em `main.gd`.

Isso foi intencional para prototipação, porém o arquivo já cresceu bastante. Após fechar `v0.1.0`, reavaliar separação em sistemas como Wave, Upgrade, Resource e Run State.

Não refatorar no meio da implementação do Boss sem necessidade.

---

# 8. Próxima tarefa imediata

## Boss Wave / First Run Ending

Direção aprovada:

- Wave 20 passa a ser o primeiro Boss da run.
- Boss provisório: `The Foreman`.
- Visual maior e facilmente identificável.
- HP significativamente maior.
- Ataque especial capaz de atingir vários Skeletons.
- Matar Boss encerra a run com Victory.
- Exibir Run Summary.
- Adicionar Restart.

Depois:

- Game Over;
- condição de derrota;
- restart após derrota;
- teste de run completa;
- balance pass inicial;
- fechar e taguear `v0.1.0`.

---

# 9. Próximos grandes milestones

Resumo:

```text
v0.1.0  First Run
v0.2.0  Necromantic Economy
v0.3.0  Factory / Automation
v0.4.0  Build Diversity & Content
v0.5.0  Meta Progression & Run Variety
v0.6.0  Vertical Slice / Presentation
v0.7.0  Steam Demo & Market Validation
v0.8.0  Alpha / Full Content
v0.9.0  Beta / Release Candidate
v1.0.0  Steam Launch
Post-Launch Updates
```

Ver `ROADMAP.md` para detalhes.

---

# 10. Regras de desenvolvimento

Fluxo:

```text
implementar
→ testar
→ corrigir
→ documentar
→ commit
→ push
```

Princípios:

1. Não implementar muitos sistemas não testados ao mesmo tempo.
2. Não produzir arte final antes do core loop estar provado.
3. Não balancear profundamente antes dos sistemas centrais existirem.
4. Não prometer receita; usar playtests, wishlists e comportamento real para validar potencial comercial.
5. Sempre atualizar este arquivo antes de trocar de conversa após milestones importantes.
6. `CHANGELOG.md` registra apenas o que existe ou está claramente em Unreleased.
7. Ideias futuras ficam em `GAME_DESIGN.md`/`ROADMAP.md`.

---

# 11. Conceitos futuros que não devem ser esquecidos

- Flesh.
- Blood.
- Souls.
- Zombie.
- Ghost.
- Abomination.
- Factory.
- Boss Corpses.
- Meta-progressão por desbloqueio de possibilidades.
- Personagens/arquétipos.
- Last Stand.
- Eventos.
- Receitas secretas.
- Steam Achievements.
- Demo pública.
- Steam Next Fest.
