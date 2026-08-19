# NecroWorks — Code Audit

**Revisado:** 19/08/2026

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

### P1 — Fixed 1920×1080 layout

Most HUD coordinates are absolute. `stretch/aspect="expand"` can expose gaps or overlap on other aspect ratios.

Before public testing:

- move HUD into a `CanvasLayer`;
- use anchors/containers;
- validate 16:9, 16:10, ultrawide and Steam Deck-like resolutions;
- provide UI scaling.

The current overlap bugs are fixed at 1920×1080, but this does not close the responsive-layout risk.

### P1 — Parallel unit dictionaries

Skeleton and Zombie state is split across arrays and dictionaries. This is acceptable for two units but becomes fragile with Skeleton Archer, Lich or Ghost.

The first third playable unit is now the refactor trigger for a generic runtime unit record or component. Do not implement Archer or Lich as another copied dictionary family.

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

Before the demo, extend persistent coverage for:

- resource transactions;
- upgrade caps;
- synergy unlocks;
- defeat recovery;
- wave progression;
- save compatibility.

### P2 — Prototype unit scenes

Square placeholders are gone and all current combatants have temporary sprites. Zombie still reuses the Skeleton scene structurally, and none of the units have animation state machines, hit feedback or audio identity. Each commercial unit eventually needs a dedicated presentation scene even if combat data remains shared.

## Engineering rules going forward

- no new gameplay script in the repository root unless it is a required stable Godot entry point;
- no third copied family of HP/timer/slot dictionaries without reviewing the generic Undead trigger;
- no external-facing feature without a repeatable validation path;
- no UI text hardcoded long-term once localization work begins;
- preserve the stable horizontal enemy lane until replaced by a tested combat model;
- update `AI_HANDOFF.md`, roadmap and changelog after each stable milestone.
