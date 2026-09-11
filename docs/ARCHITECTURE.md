# NecroWorks — Architecture

**Atualizado:** 01/09/2026

# Stack

- Godot 4.7.1
- GDScript
- 2D
- Git/GitHub

# Estrutura atual

O projeto está organizado por domínio. `scripts/game/main_controller.gd` continua sendo o orquestrador da cena jogável, mas o estado da run pertence a `RunDirector`, as regras determinísticas ficam em políticas e catálogos, e a formatação do resumo final já saiu do controlador.

Responsabilidades que ainda precisam ser extraídas do controlador:

- Skeleton combat;
- Zombie combat;
- Enemy combat;
- coordenação dos nós de combate;
- Corpses;
- Resources;
- production;
- upgrades;
- synergies;
- metrics;
- runtime UI.

Repository layout:

```text
assets/
├── reference/
└── sprites/
    └── units/

scenes/
├── core/
│   └── app.tscn
├── units/
│   ├── enemy.tscn
│   ├── ghost.tscn
│   ├── lich.tscn
│   ├── skeleton.tscn
│   └── skeleton_archer.tscn
└── world/
    ├── corpse.tscn
    └── gameplay.tscn

scripts/
├── core/
│   ├── game_shell.gd
│   ├── localization_service.gd
│   ├── run_save_store.gd
│   └── settings_store.gd
├── economy/
├── factory/
│   ├── factory_progression_policy.gd
│   ├── army_doctrine_policy.gd
│   └── undead_production_policy.gd
├── game/
│   ├── enemy_archetype_catalog.gd
│   ├── enemy_wave_policy.gd
│   ├── main_controller.gd
│   └── run_director.gd
├── ui/
│   ├── production_controls_factory.gd
│   ├── run_summary_formatter.gd
│   ├── upgrade_status_formatter.gd
│   └── unit_health_bar.gd
├── units/
└── visual/
    ├── corpse_visual.gd
    ├── corpse_visual_catalog.gd
    ├── industrial_backdrop.gd
    ├── unit_animation_driver.gd
    └── unit_sprite_catalog.gd

tests/
├── balance/
├── combat/
├── core/
├── economy/
├── events/
├── factory/
├── game/
├── localization/
├── units/
├── upgrades/
└── visual/
```

F5 usa `scenes/core/app.tscn`. Para testar o gameplay diretamente com F6, a cena correta é `scenes/world/gameplay.tscn`. Os UIDs foram preservados durante a reorganização.

# Scenes

Known prototype scenes:

```text
scenes/world/gameplay.tscn
scenes/units/skeleton.tscn
scenes/units/enemy.tscn
scenes/world/corpse.tscn
```

`scenes/units/skeleton.tscn` and `scenes/units/enemy.tscn` now contain visible `Sprite2D` children, so their base art can be inspected in the 2D editor. Runtime archetype selection swaps textures through `scripts/visual/unit_sprite_catalog.gd`.

Zombie V1 still reuses the Skeleton Node2D scene structurally, but receives its own texture and combat state at runtime. This is acceptable for the prototype.

Later, Zombie and each commercial unit should receive dedicated scenes with animations, effects and audio hooks.

The factory background is hybrid. `assets/backgrounds/necroworks_factory_battlefield_v1.png` supplies the industrial fortress and combat floor; `scripts/visual/industrial_backdrop.gd` adds overscan, subtle parallax, fog bands, necromantic pulses and the production-area divider. The static layer carries detail while the procedural layer preserves motion and HUD alignment without requiring a large animation texture.

Prototype sprite source PNGs remain available at full resolution, while Godot import settings cap runtime textures at 512 px. This preserves editable source quality without loading unnecessary resolution for sub-200 px battlefield rendering.

# Resource state

```gdscript
bones
flesh
blood
souls
```

Current income:

```text
Corpse
→ Processing Directive
→ Balanced / Bone Focus / Flesh Focus
→ Bones and/or Flesh
```

Directive state lives in `processing_directive`; `processing_directive_locked` prevents mid-Wave changes. Wave 1 starts Balanced, controls unlock during the upgrade transition, and `start_wave()` locks the selected route. Pure yield/name validation lives in `scripts/economy/processing_directive_policy.gd`; `get_processing_yield()` is the orchestrator-facing entry point used by processing logic, HUD labels, buttons and economy validation.

`scripts/visual/corpse_processing_feedback.gd` owns the transient processing token and yield popup. The token terminates above the Resources panel, which pulses when the queued transaction settles. The economy transaction remains synchronous inside `process_corpse()` after the processor cycle; visual timing adds no further delay and cannot change deterministic balance. `corpse_processing_feedback_started` is the integration boundary for future SFX.

# Localization

`localization/ui.csv` is the source-of-truth catalog imported by Godot for `en`, `pt_BR` and `es`. `project.godot` registers the generated Translation resources and uses English as fallback. `scripts/core/localization_service.gd` owns locale normalization so future Options UI does not need to know regional fallback rules. Programmatic HUD text uses translation keys and `scripts/game/main_controller.gd` reacts to `NOTIFICATION_TRANSLATION_CHANGED` by refreshing the migrated UI slice.

Localization is intentionally incremental: only stable interface copy is migrated. The persistent runner verifies resource registration, regional normalization and live HUD refresh in all three supported languages.

# Corpse Processor queue

`corpse_processing_queue` stores a Corpse reference together with the processing directive selected when it entered the machine. Manual clicks enqueue instead of granting resources immediately. `update_corpse_processor()` advances the single processing lane and calls the existing deterministic transaction only when the base 0.65-second cycle completes.

The initial capacity is five. A full queue leaves additional Corpses on the battlefield, preserving player agency and preventing silent resource loss. Capacity and seconds-per-Corpse are explicit runtime values modified by the Factory Control upgrade layer without rewriting the transaction. Manual collection remains available before and after Automated Retrieval is unlocked.

# Factory Control

Factory Control is a run-scoped prototype layered over the Corpse Processor. Completed Waves award one Factory Point and Elite Waves award one additional point. The currency is intentionally separate from Bones/Flesh so machine investment does not directly consume the same stock used for emergency army production.

Automated Retrieval is locked by default, purchased once, and controlled by a reversible toggle. Its 0.25-second scan only enqueues valid Corpses while capacity remains. Queue Expansion and Processor Overclock each have three levels; their runtime effects modify the explicit processor capacity/cycle values already consumed by the queue.

`tests/factory/factory_automation_runner.gd` validates locked-state safety, Wave/Elite income, purchases, automatic queue filling, overflow preservation and upgrade effects. Costs and income are provisional balance values.

# Manual batch production

`production_quantity_selector` owns a shared 1–36 request quantity. `create_skeleton_batch()` and `create_zombie_batch()` validate the complete resource cost and available Undead capacity before creating anything. A rejected request therefore has no partial resource or army mutation.

Successful requests use the existing per-unit creation paths so HP, slots, metrics, sprites and combat dictionaries remain identical to single production. `batch_production_completed` is the presentation boundary for future assembler animation/audio. This is not yet a timed Skeleton Assembler or Flesh Vat queue.

# Army Doctrine automation

`scripts/factory/army_doctrine_policy.gd` is a stateless policy boundary for composition targets, the 36-unit cap, production priority, resource reserves and live deficits. `scripts/game/main_controller.gd` owns the run-scoped configuration and localized panel, and emits `army_doctrine_changed` only after a valid atomic update.

`ArmyDoctrinePolicy.get_replenishment_plan()` converts pending deficits, affordable quantities and available population into a deterministic Skeleton/Zombie plan. `scripts/game/main_controller.gd` discounts already queued units before planning, reserves resources through the public enqueue methods and exposes an explicit start/pause control. Committed orders remain in their machines when automation is paused; pausing prevents only future orders. `tests/factory/army_doctrine_runner.gd` protects configuration, while `tests/factory/army_doctrine_automation_runner.gd` validates planning, reserves, duplicate prevention, timed completion and loss replacement.

# Timed Undead production

`scripts/factory/undead_production_policy.gd` validates atomic orders and counts reserved units. The two runtime queues contain order dictionaries with original quantity, remaining quantity and snapshotted cost. Acceptance immediately reserves the full resource total; queued units also reserve army capacity.

Skeleton Assembler and Flesh Vat advance independently at 0.45 s and 0.80 s per unit. Completion uses prepaid creation paths, preserving the existing HP, slot, metric and combat registration logic without charging twice. A full machine accepts at most three orders, and queued units keep the defeat condition recoverable. `tests/factory/undead_production_queue_runner.gd` validates the transaction and timing contract.

# Blood, Souls and generic ranged Undead

`scripts/economy/necromantic_resource_policy.gd` owns deterministic Blood/Soul kill rewards, sacrifice cost and Fervor scaling. `scripts/units/undead_runtime_unit.gd` is the shared runtime component for Skeleton Warrior, Zombie Tank and Ghost. Each unit now owns recipe identity, production family, combat role, HP, damage, cooldown, speed, range, timer and formation slot.

`scripts/game/undead_recipe_catalog.gd` is the stable recipe-identity boundary. It formalizes Skeleton Warrior as the default Bone melee recipe, Zombie Tank as the default Flesh frontline recipe and Ghost as locked Soul support. Costs in this catalog describe base recipe identity; run upgrades continue to own current transactional values in `scripts/game/main_controller.gd`.

The localized Ritual panel exposes Blood Fervor, two Blood upgrades, Ghost production and two Soul upgrades. Crimson Assembly and Phantom Conduit use the existing synergy registry.

The Hematic Press is the first rare-resource Factory machine. Unlock state, a three-unit integer queue and a single cycle timer remain run-scoped in `scripts/game/main_controller.gd`. Flesh is reserved when an order enters the machine; completion adds Blood and updates the same lifetime-earned metric used by combat rewards. `tests/factory/hematic_press_runner.gd` protects the timed conversion contract.

Soul Extractor operates as a second independent queue. Corpse metadata snapshots enemy archetype and arcane yield at death. `enqueue_corpse_for_selected_route()` is the single routing boundary used by manual clicks and Automated Retrieval: eligible Mage/Elf/Foreman Corpses enter Soul extraction when arcane routing is active; all others retain material processing. A Corpse remains in the shared world list until either queue completes, while `is_corpse_queued()` prevents double ownership. Industrial Efficiency modifies costs/cycles through getters rather than mutating queue entries. `tests/factory/rare_resource_routing_runner.gd` validates the contract.

# Viewport policy

The 1920×1080 design canvas uses `stretch/aspect="keep"`. Smaller or differently proportioned embedded windows scale/letterbox the complete canvas instead of cropping the lower production floor. `tests/visual/layout_bounds_runner.gd` protects primary lower controls inside design bounds.

# Corpse tracking

```gdscript
var corpses: Array[Button] = []
```

Used for:

- processing;
- recovery;
- defeat condition.

# Physical Undead runtime state

```text
UndeadRuntimeUnit
├── unit_type / production_family / combat_role
├── current_hp / maximum_hp
├── damage / attack_cooldown / attack_timer
├── movement_speed / attack_range
└── formation_slot
```

Skeleton and Zombie arrays still identify production families for existing combat, metrics and upgrade rules. Their HP/timer/slot dictionaries are transitional mirrors used by current tests and future save migration; reads and writes pass through generic runtime helpers so the node remains synchronized.

# Shared slot state

Current shared occupancy map:

```text
occupied_undead_slots
```

It acts as a shared Undead occupancy map and is limited by `MAX_UNDEAD`.

# Generic Undead helpers

Current layer:

```text
get_total_undead_count()
get_all_undead_units()
get_closest_undead_to_enemy()
damage_undead()
```

Registration, HP mutation, attack timers and formation lookup now use this layer. New playable families must extend the runtime/catalog path instead of adding another HP/timer/slot dictionary family.

# Enemy group state

Regular Waves can now maintain more than one active Enemy:

```text
enemies
enemy_hps
enemy_max_hps
enemy_damages
enemy_speeds
enemy_attack_cooldowns
enemy_attack_ranges
enemy_attack_timers
enemy_lane_offsets
enemy_types
```

`enemy` remains a compatibility alias for the current primary/leftmost target while legacy formation, HUD and Boss logic are incrementally migrated. It is not the authoritative collection.

The active cap is isolated in `scripts/game/enemy_wave_policy.gd`. Spawned enemies fill the cap, keep independent health bars and are replenished after deaths until the Wave total is exhausted.

Archetype definitions and their introduction rotation live in `scripts/game/enemy_archetype_catalog.gd`. This keeps tuning data out of spawn/combat flow while dedicated Enemy scenes are still premature.

# Formation

Current priority:

```text
Zombie
→ front combat slots

Skeleton
→ behind Zombie
```

Combat-slot compaction keeps formations from leaving gaps after deaths.

`scripts/game/combat_formation_policy.gd` é a fonte da grade 6×6, limite de 36 unidades, coordenadas de spawn, prioridade vertical, compactação e limites da arena. `MainController` reúne os slots das unidades vivas na ordem Tank → melee → ranged → suporte e delega os cálculos para essa política. A separação permite testar geometria e limites sem instanciar a cena inteira.

`scripts/game/undead_army_registry.gd` mantém as coleções de Skeletons, Zombies, Ghosts e Liches, além dos mapas de formação e da ocupação dos 36 slots. Reserva, liberação, contagem e limpeza possuem uma única implementação. `MainController` ainda expõe os nomes anteriores como propriedades delegadas para preservar os consumidores existentes.

`scripts/game/upgrade_catalog.gd` é a fonte dos 30 IDs de upgrade, categorias, limites de pilha, marcos de disponibilidade e chaves de localização. `scripts/game/synergy_catalog.gd` concentra as dez sinergias, seus requisitos e a ordem de apresentação. `scripts/ui/upgrade_status_formatter.gd` converte o estado já calculado em texto localizado. O controlador conserva aliases públicos para compatibilidade de saves/testes e permanece responsável por aplicar os efeitos que mutam a run.

`scripts/factory/factory_progression_policy.gd` concentra custos, capacidade e tempos derivados dos níveis das máquinas. `scripts/ui/production_controls_factory.gd` cria o conjunto básico de controles de produção sem conhecer a partida. Essas duas fronteiras iniciam a separação da Fábrica e da UI sem alterar os nós e métodos públicos consumidos pelos testes.

## Bosses, Cadáveres e animações

`UnitSpriteCatalog` entrega famílias completas para Marechal da Sepultura, Auditor Arcano e Capataz. As imagens-fonte ficam separadas entre `assets/sprites/bosses` e `assets/sprites/units`, com limite de importação de 512 px para controlar memória e escala runtime.

`CorpseVisualCatalog` classifica restos comuns em blindados, arcanos ou ágeis e reserva uma família para cada chefe. `CorpseVisual` mantém o `Button` como área clicável, mas apresenta sprite, tonalidade e rótulo próprios. O processamento continua usando os metadados econômicos já existentes.

`UnitAnimationDriver` define cinco comandos estáveis: `idle`, `move`, `attack`, `hit` e `death`. As onze famílias consomem o contrato completo a partir de suas pastas V1, com escala de canvas própria para cada silhueta. `UnitSpriteCatalog` também fornece sequências de seis fases para caminhada e ataque. O driver percorre essas poses-chave, usa um `FrameBlend` transitório para suavizar a troca e interpola elevação, inclinação, antecipação, contato e recuperação; pedidos redundantes de caminhada não reiniciam o ciclo. A morte mantém o nó visível por 0,24 s, mas registro, slot, métricas e economia já foram resolvidos antes dessa espera visual.

# Movement

Enemy/Boss:

- horizontal lane;
- fixed/controlled Y;
- clamped X;
- target by horizontal distance.
- current right-side combat-safe maximum: `x=1450`.

This is a stability fix and should not be casually removed.

# Boss AOE

The Foreman collects:

```text
get_all_undead_units()
```

then damages random valid targets.

So Zombie support is already generic at Boss level.

# Defeat

Current logic:

```text
if army > 0:
	continue

if corpses > 0:
	continue

if bones >= skeleton_cost:
	continue

if flesh >= zombie_cost:
	continue

finish_run(false)
```

# UI

Current runtime UI:

- Resources block;
- Create Skeleton button;
- Create Zombie button;
- Wave HUD;
- Synergy HUD;
- Upgrade UI;
- Run End UI;
- compact Debug HUD.

Debug:

```text
F3
```

## Run-end presentation

The full-screen `RunEndPanel` now owns three independent regions:

```text
RunEndTitle
RunEndSummary       → statistics/economy
RunEndBuildSummary  → build/synergies/status
RestartRunButton    → isolated bottom action
```

This prevents dynamic synergy content from colliding with the Restart button.

## Project entry points

`project.godot` and `scenes/world/gameplay.tscn` must reference the same current scene UID. F5 and F6 were revalidated after synchronizing this UID; do not hand-edit only one side.

## Unit health presentation

`scripts/ui/unit_health_bar.gd` is a reusable child component attached at runtime.

It receives:

- current HP;
- Max HP;
- visual width;
- vertical offset;
- faction/accent color.

Updates currently cover:

- normal attacks;
- Industrial Crush;
- Final Service / Second Shift;
- Carrion Recovery;
- Reassembly;
- Max HP upgrades.

# Generic runtime direction

The first incremental extraction is implemented:

```text
Undead Unit
├── node
├── unit_type
├── production_family / combat_role
├── current_hp / maximum_hp
├── damage
├── cooldown
├── timer
├── speed
└── formation_slot
```

The chosen structure is a lightweight component plus a static recipe catalog. Behavior remains orchestrated by `scripts/game/main_controller.gd` during this bridge. Skeleton Archer is the first proving case: it shares the Bone-unit array and compatibility mirrors, while its recipe identity drives ranged positioning, per-unit stats and protected formation order.

# Skeleton Archer recipe and queue

`scenes/units/skeleton_archer.tscn` is a dedicated visual scene backed by `UndeadRuntimeUnit`. The blueprint is run-scoped, costs three Factory Points and unlocks an eight-Bone recipe. Archer orders enter the existing Skeleton Assembler, but each order snapshots its concrete `unit_type`; mixed Warrior/Archer orders therefore preserve FIFO completion without a third machine or queue.

The physical Skeleton array now represents the Bone production family. `combat_role="ranged_damage"` places Archers behind Zombies and melee Skeletons, and their target position is derived from the closest living Enemy minus the runtime attack range. Existing Bone upgrades update both current runtime instances and the base stats used by future Archers.

# Lich summon policy and temporary ownership

`scenes/units/lich.tscn` is a dedicated ranged `UndeadRuntimeUnit`. Its advanced Soul recipe is registered in `UndeadRecipeCatalog`, while `scripts/game/lich_summon_policy.gd` owns the pure cap/cooldown/lifetime/cost rules.

Temporary Thralls reuse the Bone-family runtime path and formation capacity, but declare `unit_type="lich_thrall"`, `is_temporary=true`, remaining lifetime and summon source. This keeps combat/targeting generic without creating another HP/timer/slot dictionary family. Their removal bypasses permanent Skeleton metrics and death-trigger upgrades, preventing free summons from feeding Reassembly or Final Service.

Lich attack timers and ability timers are separate runtime fields. Summoning checks population, global Thrall cap and Souls before spending; failed cap/resource attempts retry after one second. Upgrades are queried through policy inputs, and Soul Foundry affects only newly summoned Thralls so the result remains explicit and testable.

Ossuary Ballistics demonstrates recipe-aware synergy propagation: effective Archer range is computed in one helper and synchronized to current runtimes when the synergy unlocks.

# Advanced Enemy combat policy

`scripts/game/enemy_combat_policy.gd` contains pure cadence, role-priority and damage calculations for Mage Arcane Burst and Elf Precision Shot. `scripts/game/main_controller.gd` remains responsible for selecting live nodes, applying damage and presenting feedback.

Each Enemy owns an attack count beside its existing timer. The count is registered, cleared at Wave start and erased on death/cleanup. Mage attacks use the normal closest target except every third hit, when nearby targets are collected under a radius/cap. Elf attacks use normal frontline targeting except every fourth hit, when a role-first, HP-ratio-second selector searches the backline.

`enemy_ability_triggered` exposes archetype, ability and target count without coupling tests or future audio/VFX to temporary Labels.

# Rare upgrade trigger

Emergency Reclamation is the first rule-changing rare. Eligibility begins at Wave 8 and acquisition is capped at one. Its per-Wave boolean resets in `start_wave`; actual permanent death paths call one shared refund transaction before removing the unit. Recipe identity determines Bone/Flesh/Soul refund values. Temporary runtimes return before consuming the trigger.

# Elite variant state

`enemy_elite_flags` stores Elite identity per Enemy rather than deriving combat effects repeatedly from `current_wave`. Registration snapshots the flag; cleanup, death and Wave reset erase it with the other Enemy dictionaries.

`EnemyCombatPolicy` accepts the flag for cadence, splash, suppression, precision damage and Warrior mitigation. `apply_damage_to_enemy` is the single incoming-damage boundary for Bulwark. Mage/Elf attack selection reads the same snapshot, so concurrent enemies cannot inherit another instance's trait.

Presentation remains decoupled: identity and trait labels are created on the Enemy node, translation refresh updates both, and ability feedback uses the existing observable signal. Boss Wave 20 is excluded by `is_elite_wave`.

# Persistent balance validation

`tests/balance/composition_scenario_runner.gd` instantiates the real main scene and runs deterministic fixed-FPS combat scenarios. It intentionally uses runtime production, movement, targeting, damage and Wave code instead of duplicating formulas in a separate simulator.

`tests/economy/processing_directive_runner.gd` validates directive yields, Corpse consumption, button layout bounds and compatibility with dynamic Bone yield upgrades.

The runner must remain outside production scene dependencies and execute only through an explicit CLI test command.

# Refactor gate reached

Ghost supplied the trigger and the shared runtime bridge is now active. Do not remove the compatibility mirrors until all existing balance/factory tests and the future save format read the component directly.

# Data-driven future

Potential Resources:

```text
UnitDefinition
UpgradeDefinition
EnemyDefinition
SynergyDefinition
```

Useful fields:

- id;
- display_name;
- tags;
- stats;
- costs;
- rarity;
- icon;
- localization key.

Do this later.

# Performance

With large hordes, measure before optimizing:

- number of active Node2D units;
- per-frame loops;
- corpse count;
- UI updates;
- attack loops;
- AOE;
- VFX.

Potential future optimization:

- state arrays;
- reduced update frequency;
- object pooling;
- batching visuals.

Not required yet.

# Application shell and persistence

`scenes/core/app.tscn` is the F5 application entry point. It owns `GameShell`, the Main Menu, Pause and Options overlays, and instantiates `scenes/world/gameplay.tscn` as the gameplay child. Keeping `scenes/world/gameplay.tscn` independent preserves direct F6 iteration and all gameplay runners.

`SettingsStore` sanitiza e persiste idioma, volume, tela cheia, Movimento Reduzido, Alto Contraste e estado do tutorial em um `ConfigFile` v2. Arquivos v1 recebem os novos campos com defaults seguros em memória e são gravados no formato atual na próxima alteração. `RunSaveStore` grava checkpoints JSON v2 com versão da aplicação, tipo e data; versões desconhecidas são rejeitadas. `TransactionalJsonStore` escreve primeiro em `.tmp`, valida o JSON, move o arquivo anterior para `.bak` e só então promove o novo conteúdo. `MetaProgressionStore` compartilha essa fronteira e protege perfis de schemas futuros contra escrita. `scripts/game/main_controller.gd` continua responsável pelo estado da run, enquanto o shell controla disco, menus e ciclo da aplicação.

Checkpoints automáticos são confirmados antes do início de cada Onda. Salvar e Voltar reutiliza exatamente esse estado seguro: carregar reinicia a Onda registrada com exército e economia anteriores ao combate, sem tentar serializar inimigos, dano, Cadáveres ou timers parciais. O shell somente fecha a run depois que o armazenamento confirma a gravação.

`tests/core/persistence_runner.gd` protege sanitização, round-trip e restauração. `tests/core/save_reliability_runner.gd` força corrupção, fallback, falha de escrita, payload inválido, schema futuro e descarte de ganhos parciais. `tests/core/game_shell_runner.gd` cobre navegação, pausa e textos; `tutorial_runner.gd` cobre o primeiro uso e sua persistência; `accessibility_runner.gd` protege a aplicação das preferências no runtime. A suíte atual contém 78 cenários, incluindo onze famílias animadas, recuperação, áudio, resoluções, estresse e matriz de builds.

## Onboarding e acessibilidade

O tutorial pertence ao `GameShell`: ele aparece somente em Nova Partida, pausa a árvore sem interromper sua própria interface e registra conclusão no arquivo de configurações. Continue nunca reinicia o tutorial no meio de uma run. O botão de revisão permite reapresentá-lo sem apagar perfil ou checkpoint.

As opções de acessibilidade são propagadas por uma única chamada `configure_accessibility()`. Movimento Reduzido congela as camadas atmosféricas e substitui movimentos decorativos das unidades e do processamento por sinais visuais curtos. Alto Contraste reforça contornos no shell e as barras de vida. A simulação de combate permanece idêntica nas duas modalidades.

## Apresentação do combate

`CombatFeedback` recebe somente posições, valores e cores já resolvidos. Ele desenha rastros, números, anéis, mortes e alertas sem conhecer HP, alvos ou recompensas. O limite rígido de 48 nós transitórios impede crescimento da árvore em rajadas de horda. Movimento Reduzido encurta fades e elimina deslocamento/escala.

`CombatAudioManager` mantém dez `AudioStreamPlayer` reutilizáveis e seis eventos estáveis. As ondas são sintetizadas uma vez ao iniciar a cena; ataques e impactos usam cooldowns curtos para evitar dezenas de vozes no mesmo frame. A interface permite trocar os protótipos procedurais por arquivos finais sem tocar no combate.

The shell also owns the localized prologue before a New Run. End-of-run presentation remains inside `scripts/game/main_controller.gd`, but emits `restart_requested` and `return_to_menu_requested` when hosted by the shell. Direct F6 execution retains safe fallbacks to scene reload/application entry, so gameplay never assumes that a parent shell exists.

# Narrative event pipeline

`scripts/game/narrative_event_catalog.gd` is a pure catalog mapping trigger Waves to event IDs, localized presentation keys, valid choice IDs and deterministic reward dictionaries. `scripts/game/main_controller.gd` owns the live decision panel and applies rewards only after validating that the selected choice belongs to the active event.

Upgrade selection increments the next Wave first. Event Waves 4, 7, 11, 13 and 16 then pause at a decision; choosing a route records the event exactly once, emits the normal checkpoint and starts combat. Checkpoint state includes resolved choices, discoveries and a pending event ID, allowing Save/Continue to restore a decision without silently granting or skipping rewards.

`tests/events/narrative_event_runner.gd` protects triggers, invalid-choice rejection, rewards, persistent consequences, bounds, localization and pending-event restore. Full-run strategies resolve events through different economic routes.

# v0.4 content architecture

## Upgrade catalog

`scripts/game/main_controller.gd` exposes 30 stable upgrade IDs. Pool construction gates specialized cards by Wave and blueprint state, caps common stacking at three and limits each rare to one acquisition. Runtime mutations still use the existing single `apply_upgrade()` boundary, while `tests/upgrades/expanded_upgrade_catalog_runner.gd` protects uniqueness, availability, representative effects, rare hooks and localization.

`scripts/game/enemy_wave_policy.gd` is the single source of truth for regular growth, Elite scheduling and Boss profiles. `scripts/game/main_controller.gd` keeps thin compatibility methods for scenes and existing callers, but no longer owns these formulas. Returned Boss profiles are defensive copies so runtime mutations cannot corrupt the catalog. Simultaneous pressure remains independent from encounter size: intermediate Boss Waves have a one-enemy total, while the pressure curve preserves its regular thresholds for callers that inspect it directly.

## Three-Boss progression

`BOSS_PROFILES` is the authoritative Wave-to-profile map for Waves 10, 15 and 20. Each profile supplies identity, HP, damage and special-attack parameters. `EnemyArchetypeCatalog.get_boss_archetype()` provides movement and presentation data. Intermediate Boss deaths enter the normal upgrade transition; only Wave 20 calls `finish_run(true)`.

Bosses and Elites use disjoint Wave lists. This prevents accidental rule stacking and makes the encounter schedule explicit. `tests/combat/boss_progression_runner.gd` verifies identities, stat escalation, Corpse metadata, intermediate continuation and final victory.

## Persistent event consequences

`NarrativeEventCatalog` defines five incidents and ten choice-dependent discovery IDs. Reward dictionaries may grant resources or run modifiers. Enemy damage, Zombie HP, Ghost damage and faction pressure are snapshotted under `run_modifiers`, reapplied during restore and never stored as translated text. Iron Concord pressure grants +2 damage per level to Human Warriors and the Grave Marshal without affecting Mage or Elf families. Discovery IDs are locale-independent and persist in the Codex profile.

## Perfil permanente e Codex

`RunSaveStore` continua responsável apenas pelo checkpoint retomável da partida. `MetaProgressionStore` grava `user://necroworks_profile.json` com schema independente, descobertas, progresso agregado, desbloqueios, desafios, loadout e no máximo 20 resultados concluídos. Essa separação permite apagar ou substituir uma run sem perder progresso permanente.

`CodexCatalog` mantém IDs estáveis e suas chaves de título/corpo. O shell decide se mostra o texto localizado ou um registro bloqueado a partir do perfil. Além das dez descobertas de rota, o catálogo contém dez referências de tropas, inimigos e chefes liberadas pela maior Onda concluída. Eventos e saves trabalham somente com IDs, portanto a troca de idioma nunca altera o dado persistido.

O perfil usa schema v3 e reconstrói progresso compatível a partir dos históricos v1/v2. `MetaUnlockCatalog` deriva cinco projetos de Fábrica e quatro opções de loadout: Auto-coleta na Onda 5; Arqueiro e Engenheiro do Ossuário na 10; Extrator de Almas e Turno Noturno na 13; Prensa Hemática e Intendente da Peste após 30 Cadáveres na mesma run; Lich e Auditoria de Ferro após a primeira vitória. `ChallengeCatalog` expõe esses cinco marcos, enquanto `OperatorCatalog` e `StartingModifierCatalog` definem efeitos e disponibilidade sem depender da UI.

O gameplay emite `meta_progress_reported` ao concluir uma Onda, processar um Cadáver ou vencer. O shell aplica o evento atomicamente ao perfil, salva e devolve os direitos atualizados à partida. Por isso a Auto-coleta aparece imediatamente depois da Onda 5. F6 permanece irrestrito para desenvolvimento; no fluxo F5 as compras ainda consomem Pontos de Fábrica, portanto o perfil libera possibilidades e não tecnologias gratuitas.

## Fronteiras finais da v0.4.1

`CombatRuntimeCoordinator` concentra coleta de unidades válidas, seleção por eixo, transação básica de dano e limpeza consistente das coleções/dicionários no fim do ciclo de vida. Cadência, efeitos de upgrades e recompensas continuam no orquestrador até possuírem interfaces próprias.

`GameplayHudPresenter` recebe snapshots e devolve texto localizado para recursos, Onda e métricas. `GameplayPanelCoordinator` registra Fábrica, Doutrina, Rituais, Fusões e modais, garantindo que somente o painel compatível permaneça aberto. A criação visual ainda ocorre na cena atual, mas navegação e formatação deixaram de ser regras espalhadas pelo controlador.

## Fusion recipes

`scripts/game/fusion_recipe_catalog.gd` owns immutable recipe IDs, costs, rewards and localization keys. `can_execute_fusion_recipe()` performs the complete preflight; `execute_fusion_recipe()` mutates state only after validation. The current recipes either grant Factory Points or create a free Ghost through the standard runtime path. `tests/economy/fusion_recipe_runner.gd` protects atomic failure, outputs, population pressure and localization.

## Confiabilidade e operação da vertical slice

`TransactionalJsonStore` é a fronteira comum de escrita temporária, releitura, backup e substituição de checkpoint e perfil. `RunSaveStore` valida schema, IDs, números, filas, capacidade e métricas antes que o payload toque a cena. `MetaProgressionStore` diferencia ausência, corrupção recuperável e schema futuro, evitando transformar incompatibilidade em perda silenciosa.

`RunRecoveryEvaluator` concentra a pergunta “esta run ainda possui um caminho legal de recuperação?” usando tropas, filas, Cadáveres, capacidade, recursos, receitas avançadas e fusões. `RunDefeatAnalyzer` classifica a falha como ausência de frontline, processamento parado, produção sem recursos ou atrito; o resumo apenas localiza o diagnóstico.

Áudio obedece aos barramentos `Master`, `Music`, `SFX` e `UI`. A arte física da Fábrica é uma camada passiva atrás dos controles, sem assumir regras de produção. O gate em `tools/validate_release.ps1` descobre runners automaticamente e mantém logs/builds fora do Git.

`scripts/core/app_version.gd` é a fonte única da versão de produto. O menu mostra `v0.6.1`; checkpoint, `project.godot` e teste do preset Windows precisam coincidir com ela antes de qualquer build aceito.
