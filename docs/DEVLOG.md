# NecroWorks — Devlog

## 01/09/2026 — Conclusão da v0.5.0

Corrigi o contrato dos marcos permanentes: concluir a Onda 5 agora libera a Auto-coleta na própria run, sem exigir encerramento. O perfil evoluiu para o schema v3 e passou a registrar Onda, Cadáveres e vitória em tempo real. Perfis v1 e v2 são migrados preservando histórico e desbloqueios.

Fechei a camada horizontal com três operadores, três contratos iniciais e cinco desafios operacionais. O menu ganhou uma tela de configuração e o Codex passou a documentar tropas, inimigos e os três chefes. Cartões de aprimoramento agora respeitam largura fixa, quebra automática e recorte, eliminando invasão e sobreposição em 1920×1080. A suíte completa chegou a 53 runners aprovados, incluindo as runs Bone e Flesh.

O build Windows v0.5.0 foi exportado novamente e iniciou sem erros em smoke test headless. O executável possui 113.053.872 bytes e SHA-256 `9BDEA7F4B22C32594E68F7DEBBDE265175405CF010836B97A8DF634433F59AC1`.

## 25/08/2026 — Consolidação estrutural v0.4.1

Organizei todas as cenas por domínio, movi o controlador jogável para `scripts/game` e preservei os UIDs do Godot. F5 inicia pelo shell em `scenes/core/app.tscn`; F6 executa `scenes/world/gameplay.tscn` diretamente.

Extraí o estado e as transições da partida para `RunDirector` e a composição do resumo final para `RunSummaryFormatter`. Mantive propriedades de compatibilidade no controlador para não quebrar saves, cenas ou mecânicas durante a migração.

Na sequência, movi toda a geometria determinística do exército para `CombatFormationPolicy`: grade, capacidade, spawn, compactação, limites e distância ranged agora são validados sem carregar a cena.

Também centralizei coleções de unidades, reservas e liberação de slots em `UndeadArmyRegistry`, mantendo as propriedades anteriores como ponte de compatibilidade.

Os 30 upgrades e as dez sinergias agora possuem catálogos próprios. O controlador não monta mais pools, categorias, requisitos de combinação nem chaves de tradução manualmente; ele recebe opções válidas e aplica somente os efeitos da run.

Centralizei custos, capacidade e velocidade das máquinas em `FactoryProgressionPolicy`. A apresentação dos status de upgrade e a criação dos controles básicos de produção também saíram do controlador e agora vivem em `scripts/ui`.

O controlador caiu de 10.507 para menos de 10.000 linhas nesta etapa, sem remover as pontes de compatibilidade.

Depois da consolidação, avancei a apresentação: Marechal da Sepultura e Auditor Arcano receberam sprites próprios, completando o trio de chefes com o Capataz. Cadáveres comuns agora preservam famílias blindada, arcana ou ágil, enquanto cada chefe deixa restos reconhecíveis.

Também defini o contrato de animações com cinco estados e criei o preset Windows Desktop. A configuração de exportação passou, mas o build local aguarda os templates oficiais do Godot 4.7.1. A suíte cresceu para 41 runners.

Substituí o fundo inteiramente procedural por uma composição híbrida. A ilustração concentra a fortaleza e os materiais do cenário, enquanto o código mantém apenas parallax lento, névoa, pulsos de luz e o divisor alinhado ao HUD. O campo central permaneceu escuro e livre para suportar formações grandes sem esconder barras de vida.

O pacote oficial de templates foi localizado, mas possui cerca de 1,28 GB. Mantive o preset validado e documentei a instalação/exportação sem adicionar binários externos ao repositório. A suíte passa a ter 42 runners.

Iniciei a v0.5.0 pelo save: checkpoints novos usam schema v2 e carregam metadados de versão, tipo e data. O loader migra automaticamente o schema v1, adicionando defaults das camadas narrativas, modificadores e rituais sem tocar no arquivo original. Saves desconhecidos ou criados por versões futuras são rejeitados. A cobertura sobe para 43 runners.

Separei a progressão permanente do checkpoint da run. O novo perfil guarda descobertas e as últimas 20 conclusões; salvar ou terminar uma partida incorpora a lore encontrada sem depender da existência posterior daquele checkpoint. O menu principal agora abre um Codex localizado com dez registros das rotas narrativas, ocultando o conteúdo ainda não descoberto. Mantive `main.tscn` como um alias mínimo para que cenas F6 antigas do editor continuem abrindo o gameplay organizado. A suíte chega a 45 runners.

## 01/09/2026 — Fechamento da v0.4.1 e projetos permanentes

Fechei as três pendências da consolidação. `CombatRuntimeCoordinator` assumiu seleção comum, dano e limpeza de ciclo de vida; `GameplayHudPresenter` passou a formatar os snapshots principais; `GameplayPanelCoordinator` eliminou a lógica repetida de fechar Fábrica, Doutrina, Rituais, Fusões e modais. Instalei somente os templates Windows oficiais do Godot 4.7.1 e gerei o primeiro release local: 113.020.464 bytes, com exportação e inicialização headless aprovadas.

O perfil permanente avançou para o schema v2 com migração do v1. Cinco marcos agora liberam projetos horizontais, mas cada tecnologia ainda precisa ser comprada normalmente durante a run. O histórico ganhou tela própria no menu e apresenta também os projetos disponíveis. Last Stand foi avaliado e adiado até existirem dados externos de derrota. A regressão completa chegou a 50 cenários; Bone e Flesh continuam derrotando o Capataz.

---

## 14/08/2026 — Initial Combat

Created:

- Main;
- Skeleton;
- Enemy;
- HP;
- Damage;
- cooldown;
- auto combat.

---

## 14–16/08/2026 — Corpse Economy

Added:

- Corpse;
- Bones;
- processing;
- Skeleton production;
- multiple Skeletons.

Loop:

```text
Enemy → Corpse → Bones → Skeleton
```

---

## 16/08/2026 — Movement V1

- Node2D units;
- target movement;
- combat slots;
- dynamic placeholders;
- debug HUD.

---

## 17/08/2026 — Waves

- Wave counter;
- scaling;
- Elite Waves;
- Wave HUD.

---

## 17/08/2026 — Upgrade System

Built pool of 10 upgrades.

- 3 random choices;
- stacking;
- caps.

---

## 17/08/2026 — Synergies

Implemented:

- Overclocked Ossuary;
- Recycling Plant;
- Second Shift;
- Bone Assembly Line.

Run Metrics added.

---

## 17/08/2026 — Long Playtest

Reached Wave 21.

Conclusion:

- stable;
- economy too generous;
- horde snowballs heavily.

Deep balance postponed.

---

## 17/08/2026 — The Foreman

Wave 20 became Boss.

Added:

- The Foreman;
- 2200 HP;
- Industrial Crush;
- multi-target.

### Bug

Boss could leave screen.

### Fix

- horizontal lane;
- bounds;
- compact formation;
- horizontal attack distance.

Validated.

---

## 17–18/08/2026 — Run End

Added:

- Victory;
- Run Summary;
- Restart;
- Corpse tracking;
- Defeat;
- Game Over;
- Restart after Defeat.

Full run validated.

`v0.1.0 — First Run` became functionally complete.

---

## 18/08/2026 — Visual Target Defined

A referência conceitual dedicada tornou-se o alvo visual oficial de NecroWorks.

Direction:

- industrial dark fantasy;
- central battlefield;
- factory layer;
- resources;
- metrics;
- synergies;
- upgrade cards;
- green necromantic accents;
- heavy metal machinery.

---

## 18/08/2026 — Resource Foundation

Added state:

```text
Bones
Flesh
Blood
Souls
```

Corpse now gives:

```text
Bones + Flesh
```

Temporary Resource HUD added.

### Bug

Previous test accidentally left Skeleton at 10000 HP.

Fix:

```text
Skeleton Max HP → 100
```

HUD overlap also fixed.

Debug was reduced and moved behind `F3`.

Validated.

---

## 18/08/2026 — Zombie V1

First new Undead added.

```text
HP: 220
Damage: 6
Cooldown: 1.1
Speed: 120
Cost: 6 Flesh
```

Added:

- Zombie production;
- Zombie state;
- Zombie HP;
- Zombie attack;
- Zombie death;
- Zombie metrics;
- frontline priority;
- mixed Undead target selection;
- Boss AOE compatibility;
- Defeat compatibility;
- Run Summary support.

### Validation

A validação manual confirmou o funcionamento esperado.

This checkpoint was superseded by the Enemy Groups milestone below.

---

## 18/08/2026 — Enemy Groups & Living Archetypes

Added:

- simultaneous Enemy groups from Wave 6 onward;
- independent HP, damage, movement speed, range and cooldown;
- Human Warrior;
- ranged Mage;
- fast Elf Skirmisher;
- individual names, colors and health bars;
- staged archetype introduction;
- single-target Foreman encounter preserved.

Validated on Waves 1, 6, 8, 11 and 20.

---

## 18/08/2026 — HUD & Run-End Stabilization

Fixed:

- Enemy spawn/movement no longer enters the right-side Metrics/Synergy panels;
- a dedicated `x=1450` combat-safe boundary now protects the HUD;
- final Run Summary split into Statistics and Build Summary columns;
- Restart button no longer overlaps Active Synergies;
- Project Run main-scene UID synchronized with `main.tscn`.

Visual validation completed at 1920×1080.

## 18/08/2026 — Composition Baseline

Added a persistent deterministic balance runner using real runtime combat.

Wave 8 with eight base units and no upgrades/reinforcement:

```text
Skeleton-only → 5 kills, 33.2 s
Zombie-heavy  → 5 kills, 70.2 s
Mixed 4+4     → 7 kills, 51.2 s
```

Conclusion: unit roles are distinct enough for the current milestone. The missing decision is economic routing because every Corpse currently provides both unit resources.

---

## 18/08/2026 — Processing Directive V1

First functional Factory decision added:

```text
Balanced    8B / 2F
Bone Focus  12B / 0F
Flesh Focus 2B / 6F
```

Added three live controls to the Corpse Processing panel, dynamic yield feedback and persistent economy validation. Flesh Focus was raised from the initial 5 Flesh draft to 6 so processing the last available Corpse can always produce a Zombie.

---

## 19/08/2026 — Wave Commitment & Basic Sprites

Processing routes are now a free between-Wave commitment instead of a live per-Corpse toggle:

```text
Wave 1             → Balanced onboarding
Between Waves      → choose next route
Active Wave        → route locked
```

This keeps experimentation accessible while removing repetitive optimal micro-management.

Square combat placeholders were replaced with transparent prototype sprites for Skeleton, Zombie, Human Warrior, Mage, Elf and The Foreman. Base scenes now expose `Sprite2D` content in the 2D editor; runtime texture selection is isolated in `scripts/visual/unit_sprite_catalog.gd` and covered by a persistent validation runner.

The procedural factory backdrop moved to `scripts/visual/`, leaving only stable entry points and base scenes at the repository root.

---

## 19/08/2026 — Corpse Processing Feedback V1

Corpse recycling now produces a short visible transaction without delaying the economy:

```text
Corpse click
→ directive-colored token travels to the processor
→ Resources panel pulses
→ actual Bones/Flesh yield rises above the factory
→ feedback node cleans itself up
```

The `corpse_processing_feedback_started` signal is reserved for the future SFX layer. A persistent visual runner validates rewards, signal payload, panel recovery and transient-node cleanup.

---

## 19/08/2026 — Localization Foundation V1

The project now has a Godot-native CSV localization pipeline with English, Brazilian Portuguese and Spanish resources. The first stable HUD slice—Resources, production, Corpse Processing, directives, run metrics and resource feedback—uses translation keys and refreshes live when the locale changes.

`LocalizationService` maps regional variants to the supported catalog and falls back to English. A dedicated runner changes languages at runtime and validates both translation lookup and visible HUD text. Remaining UI copy will migrate incrementally as each interface becomes stable.

---

## 19/08/2026 — Visual Target V2 & Corpse Processor Queue

`assets/reference/necrodesignv2.png` is now the authoritative visual reference. It strengthens the intended hierarchy between battlefield, processing machinery, resource storage, troop assembly, upgrades and navigation.

The first Factory machine now has actual timing and capacity. Manual Corpse clicks enter a five-slot queue and resolve through a 0.65-second processing lane. Each entry snapshots its directive, so a later selection cannot rewrite queued rewards. This establishes the technical seams required for capacity/speed upgrades and a separately purchased automatic-collection toggle.

Localization coverage was extended to the Wave panel, living enemy identities, Corpse states and Active Synergies.

---

## 19/08/2026 — Factory Control V1

A dedicated localized Factory panel now exposes the first machine-upgrade branch. Waves award Factory Points, with an extra point for Elite clears. Automated Retrieval is a purchased, reversible toggle; Queue Expansion and Processor Overclock each offer three increasingly expensive levels.

Automatic collection scans for available Corpses but never bypasses queue capacity or deletes overflow. The Factory panel yields to the Wave upgrade overlay so the two decision surfaces cannot overlap. Persistent validation covers currency income, locked-state behavior, purchases, toggling and automatic refill.

All values remain provisional until full-run playtests establish whether the player faces real timing and investment tradeoffs.

---

## 19/08/2026 — Manual Batch Production V1

The Undead Production panel now has a shared typed quantity selector. Skeleton and Zombie actions preview total cost and build the complete requested batch only when every resource and army slot is available.

The implementation reuses existing unit creation paths and emits a batch-level presentation hook. Deterministic validation confirms successful five-unit orders and zero-mutation rejection for insufficient resources/capacity.

This reduces click repetition but remains manual and instant. Timed Skeleton Assembler/Flesh Vat queues and Army Doctrine replenishment are intentionally still open.

---

## 19/08/2026 — Army Doctrine Planning V1

A localized Doctrine panel now stores target counts for Skeletons/Zombies, minimum Bones/Flesh reserves and Balanced or unit-first production priority. Its live summary compares the target with the current army and exposes missing units without changing combat state.

The stateless policy rejects invalid compositions above the 36-unit cap and provides reserve-safe spending checks for future machines. Automatic replenishment is intentionally disabled until timed Skeleton Assembler and Flesh Vat queues can make production throughput, scarcity and pause control visible.

---

## 19/08/2026 — Timed Undead Production Queues V1

Manual production buttons now submit atomic orders instead of spawning an entire batch instantly. The order reserves its full cost and future army slots, then Skeleton Assembler and Flesh Vat operate in parallel at 0.45 s and 0.80 s per unit respectively.

Each machine accepts three pending orders. A localized status line exposes remaining units and the current cycle timer, while queued rebuilding prevents a false defeat. Persistent validation covers reservations, independent timing, completion signals, queue limits and localized UI.

---

## 19/08/2026 — Necromantic Economy v0.2 Complete

The lower HUD cutoff was traced to stretch aspect expansion; the project now preserves the complete 1920×1080 canvas. Production copy now says “Produzir … (Fila)” instead of exposing implementation terminology.

Blood and Souls are active resources. A localized Ritual panel provides Blood Fervor, Hematic Extraction, Crimson Infusion, Ghost summoning, Spectral Focus and Ethereal Anchor. Crimson Assembly and Phantom Conduit complete the first rare-resource synergy pair.

Ghost is the first ranged player unit and the first unit whose complete runtime state lives on a reusable scripted node. Two deterministic full runs—Bone/Skeleton and Flesh/Zombie—defeated the Foreman with distinct production histories. Evidence reduced Blood/Soul inflation before the milestone closed. A five-second milestone clip was generated locally.

---

## 20/08/2026 — Army Doctrine execution V1

Army Doctrine now turns target composition into paid orders on the existing timed Skeleton Assembler and Flesh Vat queues. Pending units count toward the target, preventing duplicate orders. Balanced allocation shares scarce capacity, focused priorities reserve it for the chosen line first, and minimum Bones/Flesh reserves are enforced before enqueue. A localized button starts or pauses future replenishment without cancelling committed production. Persistent coverage validates the complete loss-to-replacement loop.

---

## 20/08/2026 — Hematic Press V1

Factory Control now uses a 3×2 machine grid. Hematic Press creates the first explicit resource-conversion line: a 3-Factory-Point unlock, followed by timed 12-Flesh-to-1-Blood orders in a three-unit queue. Flesh is reserved immediately, progress remains visible, and produced Blood feeds the existing Ritual economy and metrics. The cost intentionally competes with two base Zombies per Blood.

Soul Extractor occupies the fifth card. Mage/Elf/Foreman Corpses retain arcane identity and can be diverted from material recovery into a separate timed Soul queue. The sixth card adds three Industrial Efficiency levels across both rare-resource lines. Efficiency II plus Hematic Press unlocks Dark Refinery. The right HUD synergy frame was expanded and validated against the complete eight-synergy list.

---

## 20/08/2026 — Skeleton Archer and Lich Summoner V1

The generic `UndeadRuntimeUnit` bridge now supports two genuinely different recipes without new parallel state families. Skeleton Archer uses the shared Bone assembler, a protected ranged formation and an unlockable blueprint. Lich is an 8-Soul ranged caster whose separate ability timer produces temporary Thralls under explicit Soul, population, cooldown, duration and global-cap constraints.

Temporary Thralls deliberately bypass permanent Skeleton build/loss metrics, Reassembly and Final Service. Three summoner upgrades and Soul Foundry establish the first Lich build. Ossuary Ballistics connects Archer research to Heavy Bones + Death March, bringing the current catalog to ten synergies.

Both units received original transparent prototype sprites, dedicated scenes and EN/PT-BR/ES interface coverage. The complete 21-runner headless regression passed. Corpse feedback cleanup validation was made time-based so results no longer depend on host frame rate.

---

## 20/08/2026 — Advanced enemies and first rare upgrade

Mage and Elf stopped being stat-only variants. Every third Mage attack now becomes Arcane Burst, damaging up to three clustered Undead and suppressing their attack timers. Every fourth Elf attack becomes Precision Shot, selecting exposed summoners and ranged units before tanks and dealing amplified damage. Both abilities have localized world feedback and an event hook for later VFX/SFX.

Emergency Reclamation establishes the rare/rule-changing upgrade path. From Wave 8 onward it may enter the upgrade roll once; after selection, the first permanent death per Wave returns half of that recipe's current production cost. Temporary Thralls are excluded.

The metrics panel was enlarged and the synergy panel moved down so Lich/Thrall rows cannot overlap its title. The bounds runner now loads every metric and all ten synergies. Two focused runners raised the full regression to 23/23 passing scenarios, while Bone and Flesh full-run strategies still defeat the Foreman.

---

## 21/08/2026 — Elite variants

Elite Waves now amplify archetype identity rather than only HP, damage and color. Warrior becomes Bulwark with 20% damage mitigation. Overcharged Mage casts its stronger Burst every second attack, and Deadeye Elf executes stronger Precision every third attack. Trait labels are visible and localized before engagement; The Foreman remains outside this ruleset.

Elite state is stored per Enemy and routed through the existing combat policy. A dedicated runner validates mitigation, cadence, splash, suppression, target selection, damage and translations. The full regression reached 24/24 passes, and both automated economy strategies still completed Wave 20.

---

## Next

### Production planning

At that milestone the next block was:

- playtest Factory Point income and upgrade timing;
- playtest Army Doctrine during a complete manual run;
- measure whether automatic replenishment makes late Waves too safe;
- playtest Hematic Press cost and unlock timing;
- run a complete manual v0.3 playtest using Doctrine and rare-resource routing;
- run a complete manual Archer/Lich composition and record Soul pressure, summon uptime and battlefield readability;
- decide the first rare/rule-changing upgrade after the new composition has evidence.

### Enemy depth

- playtest Warrior/Mage/Elf pressure;
- add advanced behavior only after evidence: Mage AOE/control and Elf precision targeting;
- improve hit/death feedback.

Then: Factory Point pacing playtest during the next full manual run.

---

## 21/08/2026 — Application shell and persistence V1

F5 now enters a dedicated application shell instead of launching combat immediately. Main Menu, Pause and Options form the first complete player-facing navigation loop, while direct F6 gameplay remains available for rapid development.

Locale, master volume and fullscreen preferences persist through a sanitized ConfigFile. A versioned JSON checkpoint supports Continue and restores Wave, resources, permanent army composition, upgrades, Factory progression and Army Doctrine. Checkpoints are emitted between Waves and may also be created from Pause.

Two new runners validate persistence and shell navigation. The complete 26-runner regression passed, including both deterministic Foreman victories.

---

## 21/08/2026 — Narrative entry and lifecycle polish

New Run now opens a localized prologue connecting the living kingdoms, the siege, the forbidden reanimation factory and the Foreman. The full Run Summary was migrated from hardcoded English to translation keys for EN/PT-BR/ES.

Restart and Return to Main Menu now use explicit gameplay-to-shell signals. Direct F6 execution keeps standalone fallbacks, while F5 no longer risks reloading the wrong scene at the end of a run. Navigation and localization runners cover the new contract.

---

## 21/08/2026 — First between-Wave narrative events

The Unregistered Grave Shipment interrupts the transition to Wave 7 and asks Production to choose 18 Bones or 8 Flesh plus 1 Blood. The Bound Arcanist appears before Wave 13 and offers 4 Souls or 2 Factory Points. Both incidents are localized in EN/PT-BR/ES.

Choices are validated against a pure catalog, recorded once and persisted in checkpoints—including a pending decision. The upgrade panel heading and acquisition count were also migrated to translation keys. A dedicated event runner raises the suite to 27 scenarios, while Bone and Flesh full runs still defeat the Foreman.

---

## 24/08/2026 — v0.4.0 Build Diversity & Content

O catálogo passou de 18 para 30 upgrades. Arqueiros, Zumbis e Fantasmas ganharam linhas próprias de dano, cadência, alcance e resistência; Preservação de Carne e Sifão de Almas ampliam rotas econômicas. Dízimo Carmesim e Patente Proibida completam três escolhas raras com Recuperação Emergencial.

A run agora tem três clímax: Marechal da Sepultura na onda 10, Auditor Arcano na 15 e Capataz na 20. Elites foram redistribuídos para 5, 9, 14 e 18. Os dois chefes intermediários não encerram a partida e deixam restos usados em decisões exclusivas.

O catálogo narrativo chegou a cinco incidentes. Uma Oferta Silenciosa introduz risco permanente; Restos do Marechal e Núcleo do Auditor transformam chefes em escolhas de build. Todos os efeitos persistentes entram no checkpoint.

Fusões Necromânticas formam uma nova área de decisão. Liga de Ossuário converte materiais comuns em Pontos de Fábrica; Formação Vinculada combina Sangue e Almas para produzir um Fantasma. Ambas validam custo e capacidade antes de alterar qualquer recurso.

A primeira lore completa define Vharos, Planta N-0, Diretor, Concordata de Ferro, Colégio do Lacre, Corte Verde e os três chefes. O texto também fixa o tom de horror corporativo e as regras usadas pelos eventos e pelo Codex persistente.

As runs determinísticas de Bone e Flesh seguem derrotando o Capataz. Testes dedicados cobrem 30 upgrades, três chefes, cinco eventos, persistência das consequências e fusões atômicas.
