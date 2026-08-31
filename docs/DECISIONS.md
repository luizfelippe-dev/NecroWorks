# NecroWorks — Decisions

**Atualizado:** 21/08/2026

---

## Engine

Godot 4.7.1 + GDScript.

Reason:
fast solo iteration and strong 2D workflow.

---

## Single-player / 2D first

Keep scope controlled for first commercial release.

---

## Placeholder before final art

Gameplay proof before expensive art production.

---

## Name

Project renamed from Corpse Factory to **NecroWorks**.

Brand:

```text
NecroWorks
Industrial Reanimation Solutions
Waste Nothing. Raise Everything.
```

---

## Core loop

Identity:

```text
Enemy
→ Corpse
→ Resource
→ Undead
```

Do not dilute this.

---

## Centralized `scripts/game/main_controller.gd`

Accepted through early prototype.

No big rewrite before pressure from actual features.

---

## Horizontal Enemy/Boss lane

Implemented after The Foreman could leave the screen.

Reason:
break the pursuit/formation feedback loop.

Includes:

- lane Y;
- X bounds;
- horizontal attack distance;
- compact formation.

---

## Upgrade model

3 random choices between Waves.

Stacking allowed unless capped.

---

## Synergy model

Synergies activate automatically when required upgrades are owned.

---

## First Boss

Wave 20 = The Foreman.

Boss needs to threaten groups.

---

## Victory

The Foreman defeated:

```text
finish_run(true)
```

---

## Defeat is economic, not immediate army wipe

The run continues if the player can still rebuild.

Initially:

- Bones;
- Corpses.

After Zombie:

- Bones;
- Flesh;
- Corpses.

This is intentional and supports recovery.

---

## Restart

Prototype uses:

```gdscript
get_tree().reload_current_scene()
```

Revisit only when persistent systems require it.

---

## Balance timing

**Decision:** postpone deep balance.

Reason:

- economy is still expanding;
- Zombie was just added;
- Blood/Souls not active;
- Skeleton-only balance would become obsolete.

Balance only enough to keep systems testable.

---

## Multi-resource design

Resources need gameplay identity.

```text
Bones → Skeleton / swarm / offense
Flesh → Zombie / durability / mutation
Blood → sacrifice / burst / vampirism
Souls → magic / Ghost / rare effects
```

Do not add resource generation before a meaningful sink is close.

---

## Zombie V1

Added as first Flesh sink.

Role:

```text
tank
frontline
slow
durable
low DPS
```

Current:

```text
220 HP
6 Damage
1.1 s CD
120 Speed
6 Flesh
```

---

## Zombie frontline priority

Zombie combat slots are resolved before Skeletons.

Reason:
make the role visible without needing a complex threat system yet.

---

## Generic Undead layer

Enemy/Boss should think in `Undead`, not only `Skeleton`.

Initial helper layer was added before Ghost.

No complete refactor yet.

---

## Blood next only after Flesh identity

Do not immediately implement every resource.

First:
Zombie-specific upgrades/synergy.

Then:
Blood sink → Blood generation.

---

## Visual target

The project concept image is the official visual target.

It can be followed closely because it was created specifically for NecroWorks.

Key layout:

- central combat;
- factory lower section;
- resources left;
- metrics/synergies right;
- Wave/Boss top;
- contextual upgrade cards.

---

## Commercial goal

Maximize probability of strong Steam performance.

Not a revenue guarantee.

Priority:

- hook;
- fun;
- differentiation;
- replayability;
- visual identity;
- marketability;
- polish;
- demo quality.

---

## Living Enemy factions

Opposition is built from living combat families rather than generic monsters:

```text
Human Warrior → durable frontline
Mage          → fragile ranged damage
Elf           → fast skirmisher
```

Their cultures, motives and alliances remain narrative design work; avoid reducing them to interchangeable skins.

Prototype availability is staged: Warrior on Wave 1, Mage on Wave 8 and Elf on Wave 11. Advanced AOE, control and precision behavior is deferred until the foundation is playtested.

---

## Narrative is required, full lore is deferred

NecroWorks needs a strong opening premise and story progression during runs before the vertical slice.

The full lore will be designed as its own pass. Current features must preserve room for an ambiguous living-versus-undead conflict, NecroWorks corporate history and in-run revelations.

---

## Simultaneous Enemy escalation

Wave 1 must remain readable. Group pressure begins after the first Elite checkpoint:

```text
1–5: 1 active
6–9: 2 active
10–13: 3 active
14–17: 4 active
18–19: 5 active
20: 1 Boss
```

This is a playtest baseline, not final balance. Each Enemy owns independent HP, attack cooldown, lane and health bar. Kills refill open group slots until the Wave total is exhausted.

---

## HUD reserves non-combat space

At the current fixed 1920×1080 prototype resolution, the right Metrics/Synergy rail starts near `x=1540`. Enemy spawn and horizontal movement are capped at `x=1450`, leaving room for bodies, health bars and identity labels.

This is a prototype safety boundary. Responsive layout later must derive the combat rectangle from actual HUD geometry.

---

## Run Summary uses separated information regions

Final statistics and build/synergy details use separate columns. The Restart action owns a dedicated bottom region.

Reason: dynamic synergy text must not overlap the primary action or obscure run results.

---

## Composition balance requires economic choice

The first deterministic Wave 8 comparison confirmed distinct combat roles but exposed that fixed `Corpse → Bones + Flesh` output makes a mixed army the default resource-efficient answer.

Decision: do not flatten unit stats to force artificial parity. A Factory processing directive now lets players bias Corpse output toward Bone, Flesh or a balanced result.

Initial values:

```text
Balanced    8B / 2F
Bone Focus  12B / 0F
Flesh Focus 2B / 6F
```

Focused yields deliberately guarantee immediate recovery: Bone Focus can build Skeletons and Flesh Focus can build one Zombie from a single Corpse.

---

## Processing directives are free but committed per Wave

Wave 1 uses Balanced as an onboarding baseline. After each Wave, the player may choose Balanced, Bone Focus or Flesh Focus for free while selecting the next upgrade. Starting the next Wave locks that directive until combat ends.

Reasoning:

- a currency fee would punish experimentation before the economy has enough sinks;
- unrestricted mid-Wave switching turns every Corpse into repetitive micro-optimization;
- Wave commitment creates prediction, risk and build identity without adding grind;
- the between-Wave decision aligns naturally with enemy previews and upgrade selection.

Revisit only after playtests show that one route dominates or that Wave commitment creates unrecoverable states.

---

## Hybrid scene-and-code presentation

Stable visual content belongs in scenes/assets; dynamic combat state and archetype selection remain in code. `scenes/units/skeleton.tscn` and `scenes/units/enemy.tscn` expose editable `Sprite2D` children, while the runtime catalog swaps Skeleton, Zombie, Warrior, Mage, Elf and Foreman textures.

The industrial background may remain procedural during prototyping. Final production can combine procedural layers, TileMaps, shaders and painted images; using code is not itself a quality problem, but hiding all stable layout/content from the editor would slow visual iteration.

---

## Corpse processing is queued and directive-safe

Manual Corpse clicks enter a single processing lane instead of granting resources instantly. The prototype starts with five queue slots and a 0.65-second cycle per Corpse.

Each entry snapshots the selected Bone/Flesh/Balanced directive when queued. Changing the next-Wave directive cannot rewrite already accepted work.

Reasoning:

- visible time and capacity make the Factory a system rather than a cosmetic panel;
- full queues create pressure without silently destroying resources;
- directive snapshots close a timing exploit and make yields predictable;
- explicit capacity and speed values create clean upgrade hooks;
- automatic collection remains a purchased unlock/toggle so early manual play teaches the loop.

Rebalance cycle time and capacity from playtest evidence rather than removing the queue abstraction.

---

## Factory Points are the run-scoped machine currency prototype

Completed Waves grant one Factory Point; Elite Waves grant one additional point. Current purchases are Automated Retrieval and three levels each of queue capacity and processing speed.

Reasoning:

- Bones and Flesh remain readable army-production resources;
- machine upgrades become strategic without directly blocking emergency unit creation;
- Wave/Elite income creates predictable pacing and makes Elite victories materially valuable;
- a separate currency gives later Factory branches a common budget.

This is a prototype decision, not a locked final economy. Full-run data must determine whether point income, costs and Elite bonuses create meaningful choices or simply unlock everything on schedule.

---

## Manual batch orders are atomic

The shared production quantity accepts 1–36 units. A Skeleton or Zombie batch executes only when both the full resource cost and all requested army slots are available.

Reasoning:

- quantity controls remove repetitive clicks without making composition automatic;
- total-cost previews make the commitment readable;
- partial fulfillment would create surprising army/resource outcomes;
- reusing single-unit creation paths preserves metrics and runtime state consistency.

This instant action is temporary prototype behavior. Timed Assembler/Vat queues must be designed separately rather than silently changing batch semantics.

---

## Army Doctrine replenishes only through timed production

The player configures Skeleton/Zombie targets, minimum Bones/Flesh reserves and a production priority, then explicitly starts or pauses replenishment. Automation discounts units already committed to queues and issues orders only through Skeleton Assembler/Flesh Vat.

Reasoning:

- instant replacement would erase battlefield attrition and emergency decisions;
- visible Assembler/Vat queues make throughput and bottlenecks legible;
- the same target can then produce different outcomes depending on upgrades and resources;
- separating policy from execution keeps the future automation testable and pausable.

Pausing prevents new orders but does not cancel paid, committed batches. This preserves transaction clarity and prevents resource refunds or disappearing future units from becoming an exploit.

---

## Production orders reserve resources and population atomically

A manual order reserves its complete Bone/Flesh cost and future army slots when accepted. Skeleton Assembler and Flesh Vat then complete one prepaid unit per cycle, independently.

Reasoning:

- later spending cannot invalidate an already accepted order;
- orders never produce a surprising partial batch because resources disappeared;
- reserved population prevents two machines from overcommitting the 36-unit cap;
- independent cycle times create a real composition/throughput tradeoff;
- the same transaction boundary can safely serve future Army Doctrine automation.

---

## Rare resources come from combat identities, not Corpse routing

Blood arrives from Elites/Bosses and paced normal kills. Souls arrive primarily from Mage/Elf kills and the Foreman. Blood Fervor is the first Blood sink; Ghost production plus Spectral Focus/Ethereal Anchor are the first Soul sinks.

Automated full runs showed the initial rare-resource rates were excessive. Normal Blood was reduced to one per eight kills before upgrades, Mage/Elf Soul drops were throttled, and Ghost cost became four Souls. These remain playtest values.

The Hematic Press adds an explicit industrial exception for Blood: after a 3-Factory-Point unlock, 12 Flesh can be committed to produce 1 Blood over 2 seconds. This does not silently modify Corpse yields; it creates a visible trade-off between Zombie production and Ritual tempo. Souls remain identity-bound until the Soul Extractor can preserve magical-enemy scarcity.

Soul Extractor preserves that scarcity by accepting only Corpses tagged from Mage, Elf or Foreman deaths. Routing is explicit and reversible: an arcane Corpse becomes either its normal Bone/Flesh material yield or timed Souls, never both. The unlock costs 4 Factory Points, the queue holds three Corpses, and efficiency reduces time without increasing Soul yield.

---

## Preserve the full design canvas before responsive reflow

The prototype uses a 1920×1080 absolute layout. `stretch/aspect="keep"` is required so embedded windows scale/letterbox the full canvas instead of clipping the lower menus. Container-based responsive reflow remains required before public testing.

---

## Lich summons are temporary capacity, not free permanent production

The Lich is unlocked for 5 Factory Points and produced for 8 Souls. Each Thrall costs another Soul, occupies the normal army cap, uses a global cap of six, expires after 15 seconds and is gated by a 10-second cooldown.

Reasoning:

- a summoner must create tactical tempo without replacing the factory economy;
- Soul consumption preserves Mage/Elf corpse-routing value;
- shared population prevents exponential board growth;
- duration and cooldown keep multiple Liches useful but bounded;
- temporary deaths cannot activate Reassembly/Final Service or permanent Skeleton metrics, closing recursive value exploits.

Summoner upgrades modify cap, cooldown and lifetime. Soul Foundry buffs future Thralls rather than retroactively rewriting active summons, keeping state transitions readable.

---

## Archer synergy improves geometry before raw DPS

Ossuary Ballistics requires the Archer blueprint, Heavy Bones and Death March, then adds 80 attack range to current and future Archers.

Reason: the Archer should win through protected formation and uptime. A range reward creates composition identity and counters battlefield congestion without adding another multiplicative damage stack.

---

## Enemy archetypes need behavioral counters, not only stat multipliers

Mage uses a predictable third-attack AOE/suppression pattern. Elf uses a predictable fourth-attack precision pattern that prioritizes summoner and ranged roles.

Reasoning:

- Warrior, Mage and Elf must change player decisions rather than only time-to-kill;
- periodic specials create anticipation and readable counterplay;
- Mage punishes excessive clustering;
- Elf punishes an unprotected high-value backline;
- role-based selection scales to future units without hardcoding scene names.

---

## Rare upgrades begin after the opening economy is established

Emergency Reclamation becomes eligible at Wave 8, is acquired once and triggers once per Wave. It refunds half the current recipe cost of the first permanent casualty. Temporary summons are excluded.

Reason: early Waves should teach the base loop before introducing exceptions. The effect softens one meaningful loss but preserves attrition, resource scarcity and the cost of repeated mistakes.

---

## Elite variants intensify the archetype's existing counter-role

Elite Warrior mitigates damage; Elite Mage accelerates and strengthens AOE/suppression; Elite Elf accelerates and strengthens precision targeting. Bosses remain a separate ruleset.

Reasoning:

- an Elite should be identifiable before its first attack;
- variants should deepen learned behavior instead of introducing unrelated mechanics;
- per-instance Elite flags support concurrent mixed archetypes safely;
- predictable cadence preserves counterplay;
- excluding Bosses prevents accidental stacking of encounter rule sets.

---

## Separate the application shell from the gameplay scene

F5 launches `scenes/core/app.tscn`; F6 may still launch `scenes/world/gameplay.tscn` directly. The shell owns menus, pause state, settings and file I/O. Gameplay owns the serializable run state and emits checkpoint requests.

Reasoning:

- preserves the stable scene contract used by every combat/economy runner;
- avoids coupling menu lifecycle to the large gameplay orchestrator;
- allows corrupt or incompatible saves to fail before gameplay is mutated;
- makes future Steam/platform integration replace the storage boundary without rewriting combat;
- Wave-granular checkpoints are more deterministic than attempting frame-perfect restoration during the prototype.

## Establish lore before the first combat frame

New Run opens a short localized prologue rather than dropping the player directly into Wave 1. It establishes the living kingdoms as invaders, NecroWorks as a forbidden industrial defense system and the Foreman as the run's approaching target.

Reasoning: the premise now frames Corpse recycling as an authored world and creates anticipation without interrupting combat. Longer lore remains reserved for optional in-run discoveries so repeat runs are not slowed by mandatory exposition.

## Put narrative decisions between Waves and after upgrades

The first events were placed before Waves 7 and 13 after the previous Wave's upgrade. The same boundary now supports all five v0.4 incidents: combat never pauses mid-attack and every event offers two mutually exclusive routes.

Reasoning:

- the player already expects a planning pause at this boundary;
- choices connect lore directly to Bones/Flesh/Blood/Souls/Factory Points;
- event IDs and rewards remain deterministic for save compatibility and balance tests;
- two incidents are enough to validate pacing before building a large content catalog;
- rewards use opportunity cost rather than surprise punishment during the first implementation.

## Separate Elites from Boss milestones

Elite pressure occurs on Waves 5, 9, 14 and 18. Bosses occupy Waves 10, 15 and 20. No Wave combines both rule sets.

Reasoning:

- each special encounter keeps a readable identity;
- pressure spikes remain distributed through the run;
- archetype-specific Elite tests can cover Warrior, Mage and Elf together on Wave 14;
- Boss balance is not distorted by hidden Elite modifiers.

## Treat Boss remains as build decisions

The Grave Marshal and Arcane Auditor leave normal clickable Corpses and also trigger exclusive decisions on the following Wave transition. Their rewards either reinforce a unit family or accelerate a different economy.

Reasoning: a Boss should change the run after the health bar reaches zero. The choice connects fiction, reward and build direction without adding a separate inventory layer.

## Keep fusions deterministic and atomic

Fusions use fixed recipes. Every cost and army-capacity requirement is checked before resources are consumed.

Reasoning: recipes create deliberate cross-resource sinks, but failed interaction must never lose materials. Fixed outputs also make balance and save compatibility easier to audit.

## Organizar cenas e scripts por domínio

As cenas não permanecem mais soltas na raiz. A aplicação fica em `scenes/core`, o campo de batalha em `scenes/world`, unidades em `scenes/units` e controladores/regras em `scripts/<domínio>`.

Motivos:

- caminhos indicam responsabilidade e reduzem ambiguidade;
- novos conteúdos não disputam espaço na raiz do repositório;
- UIDs preservados mantêm referências seguras no Godot;
- F5 e F6 continuam independentes e testáveis.

## Usar compatibilidade durante a desmontagem do controlador

`RunDirector` é dono do estado da run, mas `MainController` ainda expõe as propriedades antigas como delegações. A remoção dessas propriedades só acontecerá quando os consumidores migrarem para interfaces próprias.

Motivo: uma refatoração incremental com regressões específicas é mais segura que reescrever simultaneamente combate, saves, UI e automações.

## Manter regras puras fora do controlador e preservar a API pública

Os requisitos de sinergia, os custos e tempos derivados da Fábrica e a formatação dos status não dependem da árvore da cena. Essas regras agora vivem em catálogos, políticas e formatadores próprios; `MainController` fornece apenas o estado necessário e aplica o resultado.

Motivos:

- regras puras podem ser validadas sem iniciar uma run;
- a mesma fórmula atende gameplay e interface, evitando divergência de custo ou tempo;
- saves e testes continuam usando os nomes públicos atuais durante a migração;
- componentes de UI podem sair gradualmente do código sem uma reescrita arriscada da cena.

## Cadáveres preservam a origem sem exigir um sprite novo para cada inimigo

O protótipo usa a textura do inimigo abatido, transformada e tonalizada por uma família visual. Guerreiro pertence à família blindada, Mago à arcana e Elfo à ágil. Cada chefe mantém sua própria textura também nos restos.

Motivos:

- a origem do recurso fica legível no campo de batalha;
- chefes continuam reconhecíveis depois da derrota;
- a solução permite validar tamanho, clique e densidade antes de encomendar animações de morte completas;
- novos arquétipos podem compartilhar família sem perder seus metadados econômicos.

## Animação visual não controla a simulação

Idle, movimento, ataque, impacto e morte usam uma interface comum, mas não decidem dano, alvo, cooldown, recompensa ou remoção da unidade.

Motivo: a arte final pode substituir o movimento procedural por spritesheets sem alterar balanceamento, saves ou testes determinísticos.

## Migrar checkpoints antigos antes de validar a versão atual

`RunSaveStore` grava schema v2 e aceita schema v1 por uma migração determinística em memória. A migração adiciona metadados e defaults para seções que não existiam no começo do desenvolvimento. Arquivos com versão inválida ou superior à suportada não são carregados.

Motivos:

- atualizações não apagam automaticamente uma run válida;
- a migração fica separada da restauração do gameplay;
- saves futuros não são interpretados por uma versão antiga do executável;
- cada nova versão poderá acrescentar uma etapa pequena e testável à cadeia.
