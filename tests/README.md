# NecroWorks Test Harnesses

## Presentation v0.6.2

`tests/ui/presentation_layout_runner.gd` validates the new menu and dashboard in EN/PT-BR/ES: production batches of ten, measured control bounds, separate resource values, metric columns, progress bars, zombie-only production and accessibility.

`tests/visual/unit_animation_driver_runner.gd` checks continuous locomotion at 30/60/144 Hz, repeated move commands, independent hit feedback and terminal death. The sprite integration runner covers all eleven families. The synergy runner checks a clipped scroll area with all ten entries.

For real rendered evidence, run `tools/capture_presentation.gd` without `--headless`; it uses disposable save/profile paths and writes menu/HUD captures plus motion phase comparisons under `artifacts/presentation/`. These captures are not runtime assets.

## Composition balance

Runs three deterministic, upgrade-free armies against Wave 8 using the real runtime combat:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/balance/composition_scenario_runner.gd
```

Baseline army size: 8.

| Scenario | Wave 8 kills | Survival time | Outcome |
|---|---:|---:|---|
| 8 Skeletons | 5 / 12 | 33.2 s | wiped |
| 8 Zombies | 5 / 12 | 70.2 s | wiped |
| 4 Skeletons + 4 Zombies | 7 / 12 | 51.2 s | wiped |

Interpretation:

- Skeletons provide damage but collapse quickly;
- Zombies materially extend survival but do not improve kill count alone;
- the mixed army converts frontline durability into more total kills;
- Wave 8 is not intended to be cleared by eight base units without upgrades, processing or reinforcement.

This is a regression baseline, not a final balance target. Run with the exact fixed-FPS command so simulated-time results remain comparable.

## Processing directives

Validates Balanced, Bone Focus and Flesh Focus yields, Wave locking, UI bounds, Corpse consumption and Efficient Recycling compatibility:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/economy/processing_directive_runner.gd
```

Current base yields:

| Directive | Per Corpse | Six-Corpse production capacity |
|---|---:|---:|
| Balanced | 8 Bones + 2 Flesh | 9 Skeletons + 2 Zombies |
| Bone Focus | 12 Bones + 0 Flesh | 14 Skeletons |
| Flesh Focus | 2 Bones + 6 Flesh | 2 Skeletons + 6 Zombies |

Wave 1 is fixed to Balanced. Directive controls unlock between Waves and lock again when the next Wave starts.

## Unit sprites

Validates that every current unit visual resolves to a real texture, respects the 512 px runtime import cap and that the main Skeleton/Enemy instances no longer use square debug visuals:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --path . `
  --script res://tests/visual/unit_sprite_runner.gd
```

## Corpse processing feedback

Validates settled rewards, directive-aware signal payload, animated feedback creation, Resources panel recovery and automatic transient-node cleanup:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/visual/corpse_processing_feedback_runner.gd
```

## Localization foundation

Validates English, PT-BR and Spanish resource registration, regional locale normalization and live HUD refresh:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/localization/localization_runner.gd
```

## Corpse Processor queue

Validates five-slot capacity, delayed resource settlement, full-queue rejection and directive snapshots:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/corpse_processor_runner.gd
```

## Factory automation

Validates locked auto-collection, Wave/Elite Factory Point income, purchases, reversible toggling, automatic queue refill and capacity/speed upgrades:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/factory_automation_runner.gd
```

## Army Doctrine automation

Validates balanced/focused planning, explicit start and pause, resource reserves,
duplicate-order prevention, timed dual-machine completion and replacement after a
battlefield loss:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/army_doctrine_automation_runner.gd
```

## Manual batch production

Validates Skeleton/Zombie batch counts, total costs, emitted transaction payloads and all-or-nothing rejection for insufficient resources or army capacity:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/batch_production_runner.gd
```

## Army Doctrine planning

Validates atomic target configuration, 36-unit cap rejection, live deficits, minimum-resource reserves, priority synchronization and localized visible UI. It also confirms that planning does not trigger instant replenishment:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/army_doctrine_runner.gd
```

## Timed Undead production queues

Validates atomic resource/population reservation, independent Skeleton Assembler and Flesh Vat timing, parallel unit completion, three-order limits, completion signals and localized queue UI:

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --fixed-fps 60 `
  --path . `
  --script res://tests/factory/undead_production_queue_runner.gd
```

## Blood, Souls and Ghost

Validates rare-resource rewards, Blood Fervor, Blood/Soul upgrades, both new synergies, Ghost production, magic damage, death and localized Ritual UI:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/economy/blood_soul_runner.gd
```

## Hematic Press

Validates Factory Point unlock, immediate Flesh reservation, three-unit queue,
two-second Blood cycles, completion signals, metrics and localized Factory UI:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/factory/hematic_press_runner.gd
```

## Rare-resource routing

Validates arcane Corpse identity, mutually exclusive material/Soul routing,
Soul Extractor timing, Industrial Efficiency and Dark Refinery:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/factory/rare_resource_routing_runner.gd
```

## Synergy panel bounds

Validates that the complete current synergy catalog remains inside the right HUD frame:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/visual/synergy_bounds_runner.gd
```

## Complete v0.2 balance gate

Runs real Bone/Skeleton and Flesh/Zombie strategies from Wave 1 through the Foreman, validating active-Enemy cap stages and distinct build outcomes:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/balance/full_run_runner.gd
```

## Responsive layout bounds

Validates preserved aspect mode and all primary lower-HUD controls inside the
conservative `y=1015` safe frame used by Godot's embedded 1920×1080 game view.
The gate covers panels, resource text, production controls, queue status and all
processing-directive buttons, including their runtime minimum sizes:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/visual/layout_bounds_runner.gd
```

The five-second local milestone clip is reproducible with `tests/visual/milestone_capture_runner.gd` and Godot's `--write-movie` option.

## Generic Undead runtime

Validates recipe identity, combat roles, component-owned HP and formation state for Skeleton Warrior and Zombie Tank, including compatibility mirrors and live damage:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/units/undead_runtime_runner.gd
```

## Skeleton Archer

Validates the Factory Point blueprint, locked/unlocked production, atomic Bone reservation, Skeleton Assembler completion, ranged recipe identity, rear target position, live damage, Bone Plating compatibility, Ossuary Ballistics range propagation and all three locales:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/units/skeleton_archer_runner.gd
```

## Lich summoning

Validates blueprint purchase, Soul recipe, ranged combat, separate ability cooldown, Soul spending, global Thrall cap, army capacity, temporary lifetime, permanent-metric/death-upgrade isolation, three Lich upgrades, Soul Foundry and all three locales:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/units/lich_summoning_runner.gd
```

## Complete regression

At the Elite milestone, the suite contained 24 `*_runner.gd` scenarios covering balance, combat, economy, Factory, localization, units, upgrades and visual bounds. Its current total is recorded at the end of this document.

## Advanced Enemy behavior

Validates Mage third-hit AOE damage/suppression, three-target cap, Elf fourth-hit role-based precision targeting, amplified damage, gameplay signals and all locales:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/combat/enemy_advanced_behavior_runner.gd
```

## Elite Enemy variants

Validates Wave 14 per-instance Elite identity, Warrior Bulwark mitigation, Overcharged Mage cadence/splash/suppression, Deadeye Elf cadence/targeting/damage, visible trait labels and all locales:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/combat/enemy_elite_variant_runner.gd
```

## Rare upgrade foundation

Validates Wave 8 eligibility, one-time selection, per-Wave Emergency Reclamation reset, Bone/Flesh refunds, repeat-loss blocking, temporary-Thrall exclusion and all locales:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/upgrades/rare_upgrade_runner.gd
```

## Application shell and persistence

Validates settings sanitation, checkpoint round-trip/restore, localized Main/Pause/Options navigation and pause state:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/core/persistence_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/core/game_shell_runner.gd
```

Before the narrative-event slice, the suite contained 26 `*_runner.gd` scenarios and all passed in Godot 4.7.1 headless.

The shell runner also covers the localized prologue and verifies that hosted gameplay exposes Restart/Return lifecycle connections. The localization runner validates the translated two-column Run Summary and its final navigation buttons.

## Narrative events

Validates five Wave triggers, catalog ownership, invalid choices, economic rewards, persistent risk/Boss consequences, UI bounds, EN/PT-BR/ES text and pending-event checkpoint restore:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/events/narrative_event_runner.gd
```

## v0.4 catalog, Bosses and Fusions

Validates 30 unique upgrades, all three rare hooks, three escalating Bosses, intermediate-Boss continuation, final victory and both atomic Fusion recipes:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/upgrades/expanded_upgrade_catalog_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/combat/boss_progression_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --fixed-fps 60 --path . --script res://tests/economy/fusion_recipe_runner.gd
```

## v0.4.1 Run Director

Valida início, contagem, reposição, conclusão, avanço, encerramento e restauração do estado da partida sem depender da cena:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/game/run_director_runner.gd
```

## v0.4.1 Combat Formation

Valida capacidade, coordenadas da grade, compactação, limites da arena e distância ranged sem depender de nós vivos:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/combat/formation_policy_runner.gd
```

## v0.4.1 Undead Army Registry

Valida coleções por família, capacidade total, reserva/liberação de slots, contagem e limpeza do exército:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/game/undead_army_registry_runner.gd
```

## v0.4.1 Build Catalogs

Valida os 30 upgrades, dez sinergias, unicidade, categorias, localização, limites, disponibilidade e requisitos de combinação. A apresentação de status possui cobertura independente:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/upgrades/upgrade_catalog_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/upgrades/synergy_catalog_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/upgrades/upgrade_status_formatter_runner.gd
```

## v0.4.1 Factory and UI policies

Valida custos, capacidade, ciclos das máquinas e a construção independente dos controles básicos de produção:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/factory/factory_progression_policy_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/production_controls_factory_runner.gd
```

## v0.4.1 Boss, Corpse, Animation and Export presentation

Valida texturas próprias dos chefes, famílias de restos, contrato visual e configuração do preset Windows:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/unit_sprite_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/corpse_visual_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/unit_animation_driver_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/core/export_preset_runner.gd
```

## v0.4.1 Hybrid backdrop

Valida presença, resolução, cobertura, profundidade e movimento da composição industrial:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/hybrid_backdrop_runner.gd
```

Com o fundo híbrido, a suíte chegou a 42 cenários aprovados no Godot 4.7.1 headless em 31/08/2026; as runs determinísticas de Bone e Flesh permanecem como gates obrigatórios de balanceamento.

## v0.5.0 Save migration

Valida migração v1 → v2, preservação do estado, defaults novos e rejeição de schemas futuros:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/core/save_migration_runner.gd
```

Com a migração de checkpoint, a suíte chegou a 43 cenários `*_runner.gd`, todos aprovados no Godot 4.7.1 headless em 31/08/2026.

## v0.5.0 Perfil e Codex

Valida o perfil permanente separado da run, união de descobertas, limite das 20 entradas de histórico, catálogo das dez descobertas e navegação localizada do Codex:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/core/meta_progression_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/game/codex_catalog_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/core/game_shell_runner.gd
```

A fundação de perfil e Codex levou a suíte a 45 cenários aprovados no Godot 4.7.1 headless em 31/08/2026.

## Fechamento v0.4.1 e progressão v0.5.0

Valida a fronteira comum do combate, coordenação exclusiva dos painéis, apresentação do HUD, catálogo permanente, gates reais de gameplay e migração do perfil v1:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/combat/combat_runtime_coordinator_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/ui/gameplay_panel_coordinator_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/ui/gameplay_hud_presenter_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/game/meta_unlock_catalog_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/game/meta_unlock_gameplay_runner.gd
```

Depois da integração do Mago, a suíte continha 64 cenários `*_runner.gd`, todos aprovados no Godot 4.7.1 headless, incluindo as estratégias completas Bone e Flesh.

## Conclusão da v0.5.0

Valida desbloqueios no instante da conclusão da Onda, aplicação determinística do operador/contrato e limites fixos dos cartões de aprimoramento:

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/game/meta_progress_live_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/game/loadout_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/ui/upgrade_layout_runner.gd
```

## Tutorial e acessibilidade

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/core/tutorial_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/accessibility_runner.gd
```

Os cenários validam exibição apenas em Nova Partida, navegação, persistência, revisão, cenário estático em Movimento Reduzido e barras de vida em Alto Contraste.

## VFX e SFX de combate

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/combat_feedback_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/audio/combat_audio_runner.gd
```

Os cenários protegem conteúdo, limpeza e teto da camada transitória, integração com dano, acessibilidade, seis streams procedurais, pool de vozes e controle de repetição.

## Direção de animação e integridade linguística

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/animation_art_direction_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/localization/catalog_integrity_runner.gd
```

O primeiro cenário valida presença, dimensões e transparência dos concept sheets do Esqueleto e do Zumbi. O segundo percorre as 432 chaves do catálogo, rejeita duplicatas e campos vazios e compara as traduções importadas dos três idiomas com o CSV-fonte.

## Famílias animadas — cinco estados

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/skeleton_animation_assets_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/zombie_animation_assets_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/ghost_animation_assets_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/human_warrior_animation_assets_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/mage_animation_assets_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/elf_animation_assets_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/grave_marshal_animation_assets_runner.gd
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/visual/unit_sprite_runner.gd
```

Os cenários validam os 45 assets de Esqueleto, Zumbi, Fantasma, Guerreiro Humano, Mago, Elfo, Marechal, Auditor e Capataz importados em 512×512, alfa real, catálogo, escalas próprias, troca efetiva de pose e retirada visual sem bloquear slot, progressão da Onda ou conclusão da run.

`tests/visual/human_warrior_animation_assets_runner.gd` protege os cinco estados do primeiro invasor. `unit_sprite_runner.gd` também mata o inimigo inicial e confirma que ele sai da coleção antes dos 0,24 s reservados à pose final.

`tests/visual/mage_animation_assets_runner.gd` protege os cinco estados arcanos. O runner integrado cria e elimina um Mago de runtime, confirmando que sua morte visual não retém estado de combate.

`tests/visual/elf_animation_assets_runner.gd` protege os cinco estados da arqueira. O ciclo integrado confirma que o Elfo sai da coleção antes da pose final, sem reter alvo, slot ou progressão.

`tests/visual/grave_marshal_animation_assets_runner.gd` protege os cinco estados do primeiro chefe finalizado. A regressão conjunta confirma escala ampliada, resolução do Cadáver e transição da Onda independentes da morte visual.

## Salvamento transacional e retomada

```powershell
Godot_v4.7.1-stable_win64_console.exe --headless --path . --script res://tests/core/save_reliability_runner.gd
```

O cenário corrompe arquivos deliberadamente, valida recuperação pelo backup, rejeição de payload incompleto, falha de escrita sem fechar a run, proteção contra schema futuro e retomada sem ganhos parciais da Onda.

A suíte atual contém 79 cenários `*_runner.gd`. Além das estratégias completas Bone e Flesh, cobre confiabilidade de save, recuperação/derrota, ambiente e buses, Fábrica, onze famílias visuais, seis resoluções, horda de 36 unidades, cinco perfis de build e a apresentação localizada da v0.6.2.

## Gate único

```powershell
.\tools\validate_release.ps1 -GodotPath "C:\caminho\Godot_v4.7.1-stable_win64_console.exe"
```

O gate exige `PASS` em cada runner, rejeita erros de script mesmo com exit code zero, salva logs ignorados pelo Git, exporta o Windows release, inicia um smoke test e grava SHA-256. A matriz de builds pode ser executada isoladamente por `tests/balance/vertical_slice_build_matrix_runner.gd`.

O runner de exportação também exige que `AppVersion`, `project.godot`, checkpoint e as versões de arquivo/produto do Windows estejam sincronizados. Esse contrato impede publicar uma build final ainda marcada como desenvolvimento.
