# NecroWorks — Code Audit

**Revisado:** 18/08/2026

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

### P1 — Parallel unit dictionaries

Skeleton and Zombie state is split across arrays and dictionaries. This is acceptable for two units but becomes fragile with Ghost.

Ghost is the refactor trigger for a generic runtime unit record or component.

### P2 — Runtime-created UI

Programmatic UI enabled fast iteration but is harder to edit visually and localize. Stable panels should gradually move into dedicated scenes.

### P2 — Automated regression coverage

Targeted headless validations are currently temporary. Before the demo, create a persistent test harness for:

- resource transactions;
- upgrade caps;
- synergy unlocks;
- defeat recovery;
- wave progression;
- save compatibility.

### P2 — Placeholder unit scenes

Zombie still reuses the Skeleton scene and placeholder rendering. Each commercial unit needs its own scene, animation, hit feedback and audio identity.

## Engineering rules going forward

- no new gameplay script in the repository root unless it is a required stable Godot entry point;
- no third copied family of HP/timer/slot dictionaries without reviewing the generic Undead trigger;
- no external-facing feature without a repeatable validation path;
- no UI text hardcoded long-term once localization work begins;
- preserve the stable horizontal enemy lane until replaced by a tested combat model;
- update `AI_HANDOFF.md`, roadmap and changelog after each stable milestone.
