# NecroWorks — Code Audit

**Revisado:** 21/08/2026

## Current verdict

The project is healthy for an early playable prototype and starts without parser/runtime errors.

The repository now separates modular assets/components while keeping stable Godot entry points at `res://`. The largest remaining risk is responsibility concentration inside `main.gd`.

## Improvements completed

- stable F5/F6 entry points explicitly preserved at the repository root;
- scenes grouped by domain;
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

`main.gd` owns combat, economy, waves, upgrades, synergies and most UI.

Do not split it by arbitrary line count. Extract one responsibility at a time only when it has a stable interface and a focused validation scenario.

Recommended extraction order:

1. data definitions for upgrades/synergies;
2. HUD construction and updates;
3. wave/enemy director;
4. resource/production service;
5. generic Undead runtime state when Ghost begins.

The first Wave Director boundary now exists as a stateless active-Enemy policy. Continue extracting only rules with a focused interface; spawning and lifecycle still belong to the orchestrator for now.

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

The next safe refactor is to migrate one legacy mirror at a time behind focused tests. Do not remove all compatibility dictionaries in one rewrite, and do not move every behavior into unit nodes while `main.gd` still owns encounter orchestration.

### P2 — Runtime-created UI

Programmatic UI enabled fast iteration but is harder to edit visually and localize. Stable panels should gradually move into dedicated scenes.

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

Advanced Mage/Elf cadence and targeting are isolated in `scripts/game/enemy_combat_policy.gd`; live-node orchestration remains in `main.gd`. `tests/combat/enemy_advanced_behavior_runner.gd` covers AOE cap/damage/suppression, role-based precision and localization.

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

The application now separates disk I/O from gameplay state: `RunSaveStore` owns validated versioned JSON, while `main.gd` produces and restores a documented checkpoint dictionary. Corrupt, absent and incompatible saves fail closed and disable Continue instead of partially mutating a run.

The current checkpoint is Wave-granular rather than frame-perfect. Active enemies, Corpse queues and fractional machine timers restart at the saved Wave boundary. This is intentional for V1, but the policy must be surfaced to playtesters and revisited before Steam cloud-save integration.

Settings and application-shell navigation have persistent automated coverage. Their milestone passed 26/26 on Godot 4.7.1.

### P1 — Application lifecycle (closed for V1)

The former `reload_current_scene()` restart path was unsafe once gameplay became a child of `app.tscn`: it could reload the shell instead of restarting combat. Gameplay now emits lifecycle requests when hosted and retains direct-scene fallbacks for F6. End-screen controls and the complete two-column summary are localized in all three supported languages and covered by navigation/localization assertions.

### Narrative events — first safe vertical slice

Event definitions are data-only and reward application remains at one validated orchestration boundary. Event IDs and selected choices are persisted instead of translated display strings, keeping saves locale-independent. Invalid or repeated choices cannot grant resources. The first catalog intentionally uses opportunity-cost rewards rather than permanent penalties until manual playtests establish how much interruption and variance the 20-Wave run supports.

The first event scenario raised persistent coverage to 27 runners; both Bone and Flesh balance runs still defeated the Foreman.

### P2 — Prototype unit scenes

Square placeholders are gone and all current combatants have temporary sprites. Zombie still reuses the Skeleton scene structurally, and none of the units have animation state machines, hit feedback or audio identity. Each commercial unit eventually needs a dedicated presentation scene even if combat data remains shared.

## Engineering rules going forward

- no new gameplay script in the repository root unless it is a required stable Godot entry point;
- no third copied family of HP/timer/slot dictionaries without reviewing the generic Undead trigger;
- no external-facing feature without a repeatable validation path;
- no UI text hardcoded long-term once localization work begins;
- no instant Doctrine replenishment that bypasses visible production queues;
- preserve the stable horizontal enemy lane until replaced by a tested combat model;
- update the project-state document, roadmap and changelog after each stable milestone.

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

- `main.gd` reached 10,746 lines and is no longer an acceptable long-term boundary. The v0.4.1 consolidation must extract a RunDirector, combat/army services and UI controllers before meta progression expands it again;
- upgrades still use a large match statement and should migrate to data plus focused effect handlers before the catalog expands again;
- Boss visuals reuse prototype archetype sprites and need dedicated presentation scenes;
- save schema migration beyond version 1 is still absent;
- full logging is too verbose for release builds and needs a debug-channel boundary.
