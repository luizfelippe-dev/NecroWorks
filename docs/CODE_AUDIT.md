# NecroWorks — Code Audit

**Revisado:** 01/09/2026

## Veredito atual

O projeto está saudável para um protótipo jogável e inicia sem erros de parser ou runtime.

Assets, cenas, regras, estado da run e componentes estão separados por domínio. F5 aponta para `scenes/core/app.tscn` e F6 pode executar `scenes/world/gameplay.tscn`. O maior risco restante é a concentração de combate, economia e construção de UI em `scripts/game/main_controller.gd`.

## Improvements completed

- entradas F5/F6 preservadas após a migração para `scenes/core` e `scenes/world`;
- scenes grouped by domain;
- estado e transições da partida extraídos para `scripts/game/run_director.gd`;
- formatação do resumo final extraída para `scripts/ui/run_summary_formatter.gd`;
- grade, spawn, compactação e posicionamento extraídos para `scripts/game/combat_formation_policy.gd`;
- coleções e ocupação do exército extraídas para `scripts/game/undead_army_registry.gd`;
- catálogo e disponibilidade dos 30 upgrades extraídos para `scripts/game/upgrade_catalog.gd`;
- identidade, requisitos e localização das dez sinergias extraídas para `scripts/game/synergy_catalog.gd`;
- custos, capacidade e ciclos da Fábrica extraídos para `scripts/factory/factory_progression_policy.gd`;
- status de aprimoramentos e controles básicos de produção extraídos para `scripts/ui`;
- três chefes com texturas próprias e limite de importação explícito;
- Cadáveres visuais classificados por origem e chefe;
- contrato de animações isolado em `scripts/visual/unit_animation_driver.gd`;
- preset Windows versionado e validado por configuração;
- fundo híbrido isolado em uma textura estática e um controlador procedural leve;
- checkpoint migrável separado do perfil permanente;
- catálogo de Codex isolado da interface e da localização;
- alias mínimo `main.tscn` preservando seleções F6 antigas sem duplicar a cena;
- seleção comum, dano e limpeza de lifecycle extraídos para `CombatRuntimeCoordinator`;
- recursos, Onda e métricas formatados por `GameplayHudPresenter`;
- exclusividade de Fábrica, Doutrina, Rituais, Fusões e modais controlada por `GameplayPanelCoordinator`;
- primeiro build Windows release gerado e iniciado com sucesso;
- perfil permanente v3 com progresso ao vivo e migração v1/v2;
- catálogos de operadores, contratos e desafios separados da interface;
- cartões de upgrade limitados por largura, quebra automática e recorte;
- visual reference isolated from runtime assets;
- health bar extracted as a reusable UI component;
- shared army occupancy renamed from Skeleton-specific terminology;
- `MAX_UNDEAD` now communicates the real mixed-army limit;
- main scene configured as the project entry point;
- runtime and targeted mechanic validations added during development.
- simultaneous Enemy runtime state introduced without duplicating scene controllers;
- Wave concurrency rules extracted to `scripts/game/enemy_wave_policy.gd`.
- Enemy archetype stats and Wave rotation extracted to `scripts/game/enemy_archetype_catalog.gd`.
- Corpse routing calculations extracted to `scripts/economy/processing_directive_policy.gd`.
- right-side HUD protected by an explicit combat-safe boundary;
- dynamic Run Summary content separated into two layout regions;
- stale Project Run scene UID repaired.
- temporary square rendering replaced with scene-visible `Sprite2D` assets;
- runtime texture lookup isolated in `scripts/visual/unit_sprite_catalog.gd`;
- procedural backdrop moved out of the repository root;
- persistent unit-sprite validation added.

## Priority risks

### P1 — Main orchestrator size

`scripts/game/main_controller.gd` ainda coordena combate, economia e a maior parte da UI, mas não é mais fonte das Ondas, formação, registro do exército, catálogos ou fórmulas básicas da Fábrica. O arquivo possui 10.296 linhas neste checkpoint; o tamanho continua sendo dívida conhecida, mas catálogos de arte, o driver de animação e a validação linguística permanecem fora dele.

Do not split it by arbitrary line count. Extract one responsibility at a time only when it has a stable interface and a focused validation scenario.

Próxima ordem segura:

1. serviço de processamento e produção com estado próprio;
2. controlador dedicado para Fábrica e Rituais;
3. remoção gradual dos espelhos legados após migração dos consumidores;
4. conversão progressiva da UI absoluta para containers responsivos.

Cada corte deve manter uma interface pequena e um runner específico. Spawn e ciclo de vida ainda pertencem ao orquestrador nesta etapa.

### P1 — Fixed 1920×1080 layout (cropping mitigated)

Most HUD coordinates are absolute. `stretch/aspect="expand"` can expose gaps or overlap on other aspect ratios.

Before public testing:

- move HUD into a `CanvasLayer`;
- use anchors/containers;
- validate 16:9, 16:10, ultrawide and Steam Deck-like resolutions;
- provide UI scaling.

`aspect="keep"` now prevents the production floor from being cropped in shorter embedded windows. This closes the reported cutoff, but does not close the responsive-layout risk.

### P1 — Parallel unit dictionaries

Legacy Skeleton/Zombie arrays and dictionaries remain compatibility mirrors, but `UndeadRuntimeUnit` is now authoritative for identity and current combat state across Skeleton Warrior, Skeleton Archer, Zombie Tank, Ghost, Lich and Lich Thrall. Archer and Lich proved that new roles can reuse shared runtime state without adding copied HP/timer/slot families.

The next safe refactor is to migrate one legacy mirror at a time behind focused tests. Do not remove all compatibility dictionaries in one rewrite, and do not move every behavior into unit nodes while `scripts/game/main_controller.gd` still owns encounter orchestration.

### P2 — Runtime-created UI

Programmatic UI enabled fast iteration but is harder to edit visually and localize. Stable panels should gradually move into dedicated scenes.

### Build externo — fechado para desenvolvimento local

`export_presets.cfg` aponta para `builds/windows/NecroWorks.exe`. Os templates oficiais Windows x86_64 do Godot 4.7.1 foram instalados e o primeiro release foi gerado com 113 MB. O executável abriu e encerrou em smoke test headless. Assinatura, instalador, Steam depot e teste em outra máquina continuam pertencendo à preparação comercial.

### P2 — Automated regression coverage

A persistent deterministic composition harness now exists at `tests/balance/composition_scenario_runner.gd`.
Economy routing has persistent coverage at `tests/economy/processing_directive_runner.gd`.
Unit texture resolution has persistent coverage at `tests/visual/unit_sprite_runner.gd`.
Localization switching and visible translated HUD coverage live at `tests/localization/localization_runner.gd`.
Corpse transaction feedback and cleanup live at `tests/visual/corpse_processing_feedback_runner.gd`.
Corpse queue capacity, delayed settlement and directive snapshots live at `tests/factory/corpse_processor_runner.gd`.
Factory currency, purchases, toggles and automatic collection live at `tests/factory/factory_automation_runner.gd`.
Atomic manual batch costs, counts and rejection paths live at `tests/factory/batch_production_runner.gd`.
Army Doctrine targets, deficits, reserves, priorities and localized planning UI live at `tests/factory/army_doctrine_runner.gd`.
Army Doctrine automatic queue execution, pause/resume, reserve preservation and replacement after losses live at `tests/factory/army_doctrine_automation_runner.gd`.
Hematic Press unlock, Flesh reservation, timed Blood output and localized Factory UI live at `tests/factory/hematic_press_runner.gd`.
Arcane Corpse routing, Soul extraction, efficiency scaling and Dark Refinery live at `tests/factory/rare_resource_routing_runner.gd`.
Maximum active-synergy text containment lives at `tests/visual/synergy_bounds_runner.gd`.
Timed Skeleton/Zombie queues, resource/capacity reservation and parallel completion live at `tests/factory/undead_production_queue_runner.gd`.
Blood/Soul pacing, rituals, Ghost combat and rare-resource synergies live at `tests/economy/blood_soul_runner.gd`.
Complete Bone/Flesh runs and active-Enemy cap stages live at `tests/balance/full_run_runner.gd`.
Viewport preservation and lower-HUD bounds live at `tests/visual/layout_bounds_runner.gd`.
Skeleton Archer recipe, queue, ranged formation, upgrades and Ossuary Ballistics live at `tests/units/skeleton_archer_runner.gd`.
Lich combat, Soul production, bounded Thralls, upgrades, anti-exploit rules and Soul Foundry live at `tests/units/lich_summoning_runner.gd`.

At that milestone the full headless regression contained 23 runners and passed on Godot 4.7.1. Corpse feedback cleanup uses elapsed time rather than a frame count, removing host-FPS nondeterminism.

Advanced Mage/Elf cadence and targeting are isolated in `scripts/game/enemy_combat_policy.gd`; live-node orchestration remains in `scripts/game/main_controller.gd`. `tests/combat/enemy_advanced_behavior_runner.gd` covers AOE cap/damage/suppression, role-based precision and localization.

Emergency Reclamation currently uses a shared death-transaction helper called by four permanent unit families. `tests/upgrades/rare_upgrade_runner.gd` covers eligibility, one-time acquisition, per-Wave reset, resource-specific refund, repeat-loss blocking and temporary-unit exclusion.

Both deterministic complete-run strategies still reach and defeat the Foreman after advanced enemy behavior was enabled.

Elite identity is now snapshotted per Enemy in `enemy_elite_flags`, cleared through every existing lifecycle path and consumed only through `EnemyCombatPolicy`/the central incoming-damage boundary. This avoids deriving live instance behavior from mutable Wave globals.

`tests/combat/enemy_elite_variant_runner.gd` validates all three traits and Boss exclusion remains protected by `is_elite_wave`. The Elite milestone raised the suite to 24 runners; Bone and Flesh strategies still defeated the Foreman.

Before the demo, extend persistent coverage for:

- resource transactions;
- upgrade caps;
- synergy unlocks;
- defeat recovery;
- wave progression;
- save migration from future schema versions.

### P1 — Persistence boundary (foundation completed)

The application now separates disk I/O from gameplay state: `RunSaveStore` owns validated versioned JSON, while `scripts/game/main_controller.gd` produces and restores a documented checkpoint dictionary. Corrupt, absent and incompatible saves fail closed and disable Continue instead of partially mutating a run.

The current checkpoint is Wave-granular rather than frame-perfect. Active enemies, Corpse queues and fractional machine timers restart at the saved Wave boundary. This is intentional for V1, but the policy must be surfaced to playtesters and revisited before Steam cloud-save integration.

Settings and application-shell navigation have persistent automated coverage. Their milestone passed 26/26 on Godot 4.7.1.

### P1 — Application lifecycle (closed for V1)

The former `reload_current_scene()` restart path was unsafe once gameplay became a child of `scenes/core/app.tscn`: it could reload the shell instead of restarting combat. Gameplay now emits lifecycle requests when hosted and retains direct-scene fallbacks for F6. End-screen controls and the complete two-column summary are localized in all three supported languages and covered by navigation/localization assertions.

### Narrative events — first safe vertical slice

Event definitions are data-only and reward application remains at one validated orchestration boundary. Event IDs and selected choices are persisted instead of translated display strings, keeping saves locale-independent. Invalid or repeated choices cannot grant resources. The first catalog intentionally uses opportunity-cost rewards rather than permanent penalties until manual playtests establish how much interruption and variance the 20-Wave run supports.

The first event scenario raised persistent coverage to 27 runners; both Bone and Flesh balance runs still defeated the Foreman.

### P2 — Prototype unit scenes

Square placeholders are gone and all current combatants have sprites. Zombie still reuses the Skeleton scene structurally, but Skeleton Warrior and Zombie Tank now have complete state-texture families, hit feedback and the shared procedural audio layer. Advanced units, enemies and Bosses still need equivalent presentation passes; dedicated scenes remain useful where pivots or effects diverge.

## Engineering rules going forward

- no new gameplay script in the repository root unless it is a required stable Godot entry point;
- no third copied family of HP/timer/slot dictionaries without reviewing the generic Undead trigger;
- no external-facing feature without a repeatable validation path;
- no UI text hardcoded long-term once localization work begins;
- no instant Doctrine replenishment that bypasses visible production queues;
- preserve the stable horizontal enemy lane until replaced by a tested combat model;
- update the project-state document, roadmap and changelog after each stable milestone.

### v0.6.0-dev — onboarding e acessibilidade

O tutorial permaneceu no `GameShell`, sem criar dependência do gameplay em menus ou persistência local. As preferências chegam ao controlador por `configure_accessibility()` e são distribuídas somente aos adaptadores visuais. Essa fronteira mantém o combate determinístico e permite substituir sprites e VFX sem reimplementar acessibilidade.

A suíte possui 55 runners. Os novos cenários protegem migração de settings v1 para v2, tutorial de primeira execução, revisão da orientação, Movimento Reduzido e barras de Alto Contraste. A dívida estrutural principal continua sendo o tamanho do `main_controller.gd`; este bloco não acrescentou novas regras de gameplay ao controlador.

### Apresentação audiovisual V1

VFX e SFX ficaram em dois componentes próprios. O controlador apenas envia eventos depois que o combate resolve ataque ou dano. A árvore visual possui teto de 48 transientes; o áudio reutiliza dez players e limita repetição de ataque/impacto. A suíte subiu para 57 runners, sem alterar resultados das estratégias Bone e Flesh.

### Ponte de animação e integridade linguística

O driver visual aceita texturas opcionais por estado e mantém a textura-base como fallback. Os primeiros concept sheets foram deliberadamente mantidos fora do catálogo de runtime: são fontes de pose com transparência válida, mas não possuem células uniformes. Essa decisão evita dívida visual escondida em recortes frágeis.

O catálogo de localização passou a ter auditoria exaustiva das 422 chaves e dos três idiomas. Isso fecha lacunas técnicas, campos vazios e divergências de importação; naturalidade, tom e consistência terminológica ainda exigem leitura editorial antes da demo. A suíte total sobe para 59 runners.

O Guerreiro Esqueleto é a primeira família a consumir a ponte completa. As cinco texturas ficam no catálogo visual e o controlador somente dispara estados nos eventos que já existiam. A retirada atrasada afeta apenas o nó visual: registro, métricas, slot e recuperação continuam resolvidos antes dos 0,24 s de morte. Esse desenho estabeleceu o padrão usado pelo Zumbi, sem criar uma segunda implementação de animação. Naquele corte, a regressão completa passou a 60 runners aprovados.

O Zumbi Tank reutiliza exatamente a mesma ponte, acrescentando somente seu conjunto de texturas e multiplicador de canvas. `kill_zombie()` segue o contrato de retirada visual já provado pelo Esqueleto. A suíte passou a 61 runners; não surgiu uma segunda máquina de estados nem uma nova família de dados de combate.

O Fantasma fecha a terceira família no mesmo catálogo e passa a ter uma cena visualmente autônoma. A integração acrescenta apenas seleção de asset, escala, gatilho de movimento e retirada visual; dano mágico, alcance, custo de Alma e cooldown permanecem intocados. A suíte chega a 62 runners.

O Guerreiro Humano inicia as famílias inimigas sem criar uma segunda máquina de estados. Ataque e impacto já eram emitidos pelo feedback comum; o corte adiciona as cinco texturas, escala e retirada visual depois que `CombatRuntimeCoordinator` limpa o estado. Vida, dano, defesa de Elite, cadência e composição das Ondas não mudaram. A suíte chega a 63 runners.

O Mago reutiliza essa fronteira e mantém Rajada Arcana inteiramente no `EnemyCombatPolicy`. A pose de conjuração contém somente a carga no cajado; trajetória e impacto continuam no feedback comum. A retirada de Guerreiro e Mago compartilha o mesmo caminho depois da limpeza do estado. A suíte chega a 64 runners.

### v0.4.0 closure — 24/08/2026

The content milestone is mechanically closed with focused runners and successful deterministic Bone/Flesh victories. Boss profiles, narrative events and fusion recipes are data-driven boundaries that can grow without new parallel state families.

The current complete regression is 30/30 on Godot 4.7.1.

Closed risks:

- intermediate Bosses no longer trigger the final victory path;
- Boss and Elite Waves cannot overlap;
- event consequences survive checkpoint restore;
- Fusion failure cannot consume resources;
- the upgrade pool contains 30 unique IDs and multiple one-time rares;
- new player-facing text exists in EN, PT-BR and ES.

Remaining structural debt for v0.5+:

- `scripts/game/main_controller.gd` chegou a 10.746 linhas e deixou de ser uma fronteira aceitável para manutenção. Ondas, chefes, estado da run, formação, exército, catálogos de build e formatação final já foram extraídos; depois da integração visual atual, o controlador está em 10.296 linhas. Ainda preciso mover coordenação de ataques/dano, ciclo de vida das unidades, economia e controladores de UI;
- upgrades still use a large match statement and should migrate to data plus focused effect handlers before the catalog expands again;
- Boss visuals reuse prototype archetype sprites and need dedicated presentation scenes;
- save schema migration beyond version 1 is still absent;
- full logging is too verbose for release builds and needs a debug-channel boundary.
