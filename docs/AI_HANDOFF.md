# NecroWorks — AI Handoff

**Atualizado em:** 20/08/2026
**Objetivo:** permitir continuar o projeto em outro chat sem perder decisões, estado técnico ou próximos passos.

---

# 1. Identidade do jogo

**Nome:** NecroWorks  
**Descriptor:** Industrial Reanimation Solutions  
**Slogan:** Waste Nothing. Raise Everything.

High concept:

> **Kill enemies. Recycle the corpses. Turn them into your army.**

Core loop:

```text
Enemy
→ Corpse
→ Processing
→ Necromantic Resources
→ Undead Production
→ Army Growth
→ Waves
→ Upgrades
→ Synergies
→ Elites / Boss
→ Victory ou Defeat
```

---

# 2. Tecnologia

- Engine: Godot 4.7.1 stable
- Language: GDScript
- 2D
- single-player
- Windows primeiro
- Steam como plataforma comercial inicial
- Git/GitHub
- warnings tratados com rigor; preferir tipos explícitos

### Estilo de trabalho

O usuário prefere:

- arquivos completos para substituir;
- passos exatos;
- um milestone estável por vez;
- evitar overengineering;
- implementar → testar → corrigir → documentar → commit/push.

---

# 3. Estado atual do projeto

## `v0.1.0 — First Run`

Funcionalmente completo e validado.

Possui:

- combate automático;
- Skeleton;
- Enemy;
- Corpses;
- Bones;
- produção de Skeletons;
- múltiplos Skeletons;
- Waves;
- Elite Waves;
- scaling;
- upgrades;
- synergies;
- Boss;
- Victory;
- Defeat;
- Run Summary;
- Restart.

### Importante sobre Git

O milestone `v0.1.0` está funcionalmente fechado.

**Não assumir que a tag Git foi publicada.**

Ao continuar em outro PC/chat, verificar:

```powershell
git status
git tag
git remote -v
```

Se necessário:

```powershell
git pull origin main
```

O remote historicamente foi `corpse-factory.git`; havia intenção de renomear para `necroworks.git`. Confirmar no GitHub antes de alterar `origin`.

---

# 4. Milestone atual — v0.2.0 Necromantic Economy

## Resource Foundation — validado

Estados atuais:

```gdscript
var bones: int = 0
var flesh: int = 0
var blood: int = 0
var souls: int = 0
```

Economia atual:

```text
Corpse
→ +8 Bones
→ +2 Flesh
```

Blood e Souls existem no estado, mas permanecem em 0.

HUD atual:

```text
RESOURCES
BONES: X
FLESH: X
BLOOD: X
SOULS: X
```

Produção:

```text
CREATE SKELETON
5 BONES

CREATE ZOMBIE
6 FLESH
```

Debug:

- oculto por padrão;
- `F3` mostra/esconde;
- compacto;
- não repetir métricas/recursos desnecessariamente.

---

# 5. Undead atuais

## Skeleton

```text
HP: 100
Damage: 10
Attack Cooldown: 0.7
Speed: 180
Cost: 5 Bones
Role: DPS / unidade base
Placeholder: branco
```

## Zombie V1 — IMPLEMENTADO E VALIDADO

```text
HP: 220
Damage: 6
Attack Cooldown: 1.1
Speed: 120
Cost: 6 Flesh
Role: Tank / Frontline
Placeholder: verde
```

Zombie:

- usa Flesh;
- possui array/state próprios;
- possui HP próprio;
- possui attack timer próprio;
- possui slot próprio;
- conta em Run Metrics;
- morre e libera slot;
- Enemy pode atacá-lo;
- The Foreman pode acertá-lo;
- possui prioridade de frontline.

## Zombie-specific upgrades — IMPLEMENTADOS E VALIDADOS

```text
Rotten Bulk
→ +40 Zombie Max HP e +40 HP nos Zombies existentes

Grave Hunger
→ +20% Zombie Damage

Dead Weight
→ +70 Zombie Max HP e -10% Movement Speed

Carrion Recovery
→ Zombies recuperam 4 HP após cada ataque
```

Todos são stackable. Carrion Recovery respeita `zombie_max_hp`.

### Estado de formação mista

Conceito atual:

```text
Enemy →

Zombies       ← frontline
Skeletons     ← atrás
```

A formação é abstrata; Skeleton ainda pode atacar ao chegar ao seu combat slot.

Não refinar melee/ranged ainda, a menos que esteja bloqueando o próximo sistema.

---

# 6. Estrutura de estado atual

### Skeleton

```text
skeletons
skeleton_hps
skeleton_attack_timers
skeleton_slots
```

### Zombie

```text
zombies
zombie_hps
zombie_attack_timers
zombie_slots
```

### Shared slots

```text
occupied_undead_slots
```

O dicionário foi renomeado para refletir que os slots são compartilhados por todo Undead.

### Corpses

```gdscript
var corpses: Array[Button] = []
```

---

# 7. Generic Undead layer já iniciada

O código atual possui helpers de exército misto:

```text
get_total_undead_count()
get_all_undead_units()
get_closest_undead_to_enemy()
damage_undead()
```

Isso foi o primeiro passo para não manter o Enemy preso ao conceito de Skeleton.

Próximo refactor arquitetural deve continuar nessa direção.

Não fazer big rewrite de `main.gd`.

---

# 8. Enemy movement / combat fix importante

Bug histórico:

- The Foreman saía da tela;
- Skeletons podiam ser arrastados junto.

Causa:

```text
Enemy persegue Skeleton
+
Skeleton combat target depende da posição do Enemy
→ feedback de movimento
→ ambos saem da arena
```

Correção validada:

- Enemy/Boss usa lane horizontal;
- Y controlado;
- X limitado;
- distância de ataque horizontal;
- formação compactável;
- posições de combate limitadas.

Não remover esse comportamento sem substituir por uma solução igualmente estável.

---

# 9. Waves

Valores atuais conhecidos:

```gdscript
const BASE_ENEMIES_PER_WAVE: int = 5
const ENEMIES_PER_WAVE_GROWTH: int = 1

const BASE_ENEMY_HP: int = 100
const ENEMY_HP_GROWTH: int = 20

const BASE_ENEMY_DAMAGE: int = 7
const ENEMY_DAMAGE_GROWTH: int = 1

const ELITE_WAVE_INTERVAL: int = 5
```

Elite:

- a cada 5 Waves;
- Wave 20 não é Elite porque é Boss.

### Grupos simultâneos — implementado e validado

Inimigos possuem HP, attack timer, lane e barra de vida independentes.

```text
Waves 1–5   → 1 ativo
Waves 6–9   → até 2
Waves 10–13 → até 3
Waves 14–17 → até 4
Waves 18–19 → até 5
Wave 20     → 1 Boss
```

Ao morrer um integrante do grupo, a vaga é reposta após o spawn delay enquanto ainda houver inimigos no total da Wave.

Estado autoritativo:

```text
enemies
enemy_hps
enemy_attack_timers
enemy_lane_offsets
```

`enemy` permanece temporariamente como alias do alvo principal para compatibilidade incremental.

### Arquétipos vivos — primeira versão implementada

```text
Wave 1  → Human Warrior
Wave 8  → Mage entra na rotação
Wave 11 → Warrior / Mage / Elf
Wave 20 → The Foreman
```

Papéis atuais:

```text
Human Warrior → mais HP, melee, mais lento
Mage          → menos HP, ranged, dano alto
Elf           → rápido, ataques frequentes
```

Cada instância possui stats próprios em:

```text
enemy_max_hps
enemy_damages
enemy_speeds
enemy_attack_cooldowns
enemy_attack_ranges
enemy_types
```

Definições e rotação ficam em `scripts/game/enemy_archetype_catalog.gd`.

Ainda não implementados: Mage AOE/control e Elf precision targeting. Não documentar esses comportamentos como prontos.

---

# 10. The Foreman

Wave 20.

```text
HP: 2200
Damage: 28
Size: 140x140
Color: purple/dark
```

Industrial Crush:

```text
Interval: ~4 s
Targets: até 6 Undead
Damage: 35 por alvo
```

Boss AOE usa a camada genérica de Undead e pode atingir Skeleton/Zombie.

Boss defeat:

```text
finish_run(true)
```

---

# 11. Game Over

A derrota não é simplesmente `army == 0`.

A run deve continuar se ainda for possível reconstruir.

Condição atual:

```text
Wave ativa
AND total Undead == 0
AND Corpses == 0
AND Bones < Skeleton Cost
AND Flesh < Zombie Cost
→ Defeat
```

Isso permite recuperação com:

- Corpse;
- Bones;
- Flesh.

---

# 12. Run Metrics

Atuais:

```text
Enemies Killed
Corpses Processed

Skeletons Built
Skeletons Lost
Skeletons Revived

Zombies Built
Zombies Lost

Bones Earned
Flesh Earned

Army Remaining
Upgrades
Synergies
```

---

# 13. Upgrades atuais

1. Sharpened Bones
2. Bone Plating
3. Efficient Recycling
4. Rapid Assault
5. Death March
6. Mass Production
7. Heavy Bones
8. Bone Harvest
9. Reassembly
10. Final Service

Problema atual:

**quase todos foram desenhados na era Skeleton-only.**

Não aplicar automaticamente os mesmos bônus ao Zombie sem decisão de design.

A próxima fase deve começar a introduzir identidade própria de Flesh/Zombie.

---

# 14. Synergies atuais

## Overclocked Ossuary

Heavy Bones + Rapid Assault

- chance de Double Strike.

## Recycling Plant

Efficient Recycling + Bone Harvest

- dobra bônus de Bone Harvest.

## Second Shift

Reassembly + Final Service

- Reassembly causa parte do Final Service.

## Bone Assembly Line

Mass Production + Efficient Recycling

- chance de Skeleton grátis ao processar Corpse.

## Meat Shield Protocol

Rotten Bulk + Rapid Assault

- quando um Zombie recebe dano, todos os Skeleton attack timers são reduzidos em 0.12 s;
- primeira sinergia cross-resource;
- cria valor concreto para composição mista frontline + backline.

Unlock validado.

---

# 15. Balanceamento

## Decisão atual

O usuário pediu para **balancear de verdade depois**, não agora.

Motivo:

- sistema acabou de ganhar Zombie;
- Blood/Souls ainda não possuem gameplay;
- economia ainda vai mudar;
- balancear Skeleton-only profundamente seria retrabalho.

Problemas conhecidos:

- Bones podem saturar;
- Army cresce cedo;
- normal Enemies perdem pressão;
- upgrades de Skeleton podem snowball;
- late game precisa de mais formas de ameaçar hordas.

Pode corrigir números somente se houver:

- softlock;
- exploit absurdo que impede testar;
- bug de flow;
- unidade completamente inútil.

---

# 16. Direção visual oficial

A referência oficial é `assets/reference/necrodesignv2.png` (Visual Target V2). `necrodesign.png` permanece apenas como histórico. V2 melhora a hierarquia das máquinas, estoques, criação de tropas, navegação inferior e cards de upgrade.

Estrutura desejada:

```text
┌──────────────────────────────────────────────────────┐
│ Logo          Wave / Boss             Run Metrics   │
│                                      Synergies      │
│                                                      │
│               BATTLEFIELD                            │
│                                                      │
├──────────────────────────────────────────────────────┤
│ Corpse Processing / Resources / Undead Production    │
├──────────────────────────────────────────────────────┤
│ Resources    Upgrade Cards         Synergy Details   │
└──────────────────────────────────────────────────────┘
```

Visual:

- dark fantasy industrial;
- corporate necromancy;
- metal escuro;
- verde necromântico;
- ossos;
- máquinas;
- esteiras;
- painéis;
- fábrica ao fundo.

Não parar o desenvolvimento inteiro para reproduzir a UI final agora.

Novos sistemas devem apenas evitar decisões que contradigam essa estrutura.

### Primeira passagem visual — implementada

- fundo procedural com silhueta fabril, chaminés, tanques e luzes verdes;
- battlefield separado da faixa inferior de fábrica;
- header NecroWorks e slogan;
- painéis de Wave, Run Metrics e Active Synergies;
- módulos de Resources, Undead Production e Corpse Processing;
- produção e cards com metal escuro e acentos por categoria;
- sprites temporários substituem os quadrados de Skeleton, Zombie, Warrior, Mage, Elf e The Foreman;
- o backdrop continua procedural e temporário.

### Barras de vida — implementadas e validadas

- Skeleton, Zombie, Enemy, Elite e The Foreman;
- acompanham dano e cura reais;
- atualizam em Reassembly, Carrion Recovery e upgrades de Max HP;
- Boss recebe barra maior e cor própria;
- componente isolado em `scripts/ui/unit_health_bar.gd`.

### Primeira Flesh/Bone synergy — implementada e validada

```text
Meat Shield Protocol
Rotten Bulk + Rapid Assault
→ cada hit recebido por um Zombie reduz em 0.12 s
  o attack timer de todos os Skeletons vivos
```

Objetivo: transformar a frontline de Zombie em tempo ofensivo para a backline de Skeletons.

### Organização do projeto — atualizada

```text
assets/reference
assets/sprites/units
scripts/ui
scripts/visual
```

`main.tscn` e `main.gd` permanecem na raiz como entry points estáveis para F5/F6.

### Correções de legibilidade — implementadas e validadas

- o trilho de HUD direito começa próximo de `x=1540`;
- Enemy spawn/movement foi limitado a `x=1450` para manter corpo, nome e HP fora dos painéis;
- Run Summary final foi dividido em duas colunas;
- `RunEndBuildSummary` contém build, sinergias e status;
- Restart fica em uma região inferior isolada;
- validação visual realizada em 1920×1080.

### Entry point F5/F6

O UID de `main.tscn` mudou durante a reimportação e o `project.godot` ainda apontava para o UID anterior. Ambos agora estão sincronizados no UID atual.

Ao mover/reimportar a cena principal, sempre testar:

```text
F5 → Project Run
F6 → Current Scene
```

---

# 17. Próxima tarefa recomendada

## v0.2.0 — Flesh Identity / Zombie Build

Zombie V1, Phase 1 (Zombie-specific upgrades) e Phase 2 (primeira Flesh synergy) estão funcionando.

Próximo objetivo:

### Phase 2B — Composition validation

Testar se Skeleton-only, Zombie-heavy e exército misto produzem decisões e resultados realmente diferentes.

Revisar Flesh pacing e os novos limites de inimigos simultâneos somente com evidência de runs comparáveis.

O próximo bloco recomendado continua sendo um playtest comparativo de composição e pressão dos arquétipos. Não iniciar arte final antes de confirmar que Warrior/Mage/Elf e Skeleton/Zombie geram decisões interessantes.

### Composition baseline — concluído

Runner persistente: `tests/balance/composition_scenario_runner.gd`.

Wave 8, oito unidades, sem upgrades/reposição:

```text
Skeleton-only → 5 kills / 33.2 s
Zombie-heavy  → 5 kills / 70.2 s
Mixed 4+4     → 7 kills / 51.2 s
```

Não houve ajuste de stats: os papéis estão distintos. O problema identificado foi a ausência de escolha econômica no rendimento fixo do Corpse; a diretiva descrita abaixo foi implementada para resolver esse ponto.

### Processing Directive V1 — implementado e validado

```text
Balanced    → 8 Bones + 2 Flesh
Bone Focus  → 12 Bones + 0 Flesh
Flesh Focus → 2 Bones + 6 Flesh
```

- seleção feita por três botões no painel Corpse Processing;
- Wave 1 permanece Balanced;
- botões desbloqueiam entre Waves e travam quando a próxima Wave começa;
- a troca não custa recursos: o custo estratégico é o compromisso pela Wave inteira;
- HUD mostra modo, cadáveres e rendimento atual;
- `scripts/economy/processing_directive_policy.gd` centraliza a regra pura;
- `get_processing_yield()` expõe a regra ao orquestrador;
- Efficient Recycling atualiza o componente de Bones em todos os modos;
- Focus modes garantem produção emergencial com um único Corpse;
- Run Summary registra contagem de Corpses por rota;
- teste persistente: `tests/economy/processing_directive_runner.gd`.

### Basic Unit Sprites — implementado e validado

- `skeleton.tscn` e `enemy.tscn` possuem `Sprite2D` visível no editor;
- `scripts/visual/unit_sprite_catalog.gd` seleciona Skeleton, Zombie, Human Warrior, Mage, Elf e Foreman;
- quadrados temporários e `placeholder_unit.gd` foram removidos;
- `tests/visual/unit_sprite_runner.gd` valida texturas e ausência de `DebugVisual`;
- os sprites são temporários, sem animação, VFX de ataque ou hit feedback.

### Corpse Processing Feedback V1 — implementado e validado

- Corpse clicado gera token visual na cor da diretiva;
- token viaja até a borda superior do painel de Resources;
- painel de Resources recebe pulso curto;
- popup mostra o ganho real, incluindo futuros bônus de Bones;
- após a fila V1, recursos entram quando o ciclo de processamento termina; a animação não adiciona atraso extra à transação;
- signal `corpse_processing_feedback_started` funciona como hook para SFX;
- runner: `tests/visual/corpse_processing_feedback_runner.gd`.

### Localization Foundation V1 — implementada e validada

- catálogo principal: `localization/ui.csv`;
- idiomas registrados: `en`, `pt_BR` e `es`, com fallback em inglês;
- `scripts/core/localization_service.gd` normaliza variantes como `pt-BR`, `es_MX` e `en_US`;
- primeiro recorte migrado: Resources, produção, Corpse Processing, diretivas, métricas e popup de rendimento;
- a HUD atualiza quando `TranslationServer` troca o idioma;
- runner: `tests/localization/localization_runner.gd`.

Isto é a fundação, não a tradução integral. Textos de combate, telas de resultado, upgrades e menus devem migrar para chaves à medida que suas interfaces forem estabilizadas.

### Corpse Processor Queue V1 — implementada e validada

- clique manual envia o Corpse para uma fila visível;
- capacidade inicial: 5 Corpses;
- ritmo inicial: 0,65 segundo por Corpse;
- recursos são concedidos somente quando o processamento termina;
- a diretiva é capturada na entrada da fila, impedindo troca retroativa de rendimento;
- fila cheia rejeita nova entrada sem destruir o Corpse;
- auto-coleta continua bloqueada para um futuro upgrade/toggle;
- runner: `tests/factory/corpse_processor_runner.gd`.

Próximo passo: desenhar o desbloqueio de auto-coleta e o primeiro upgrade de capacidade/velocidade dentro do painel de Factory.

### Factory Control V1 — implementado e validado

- botão `FÁBRICA` abre/fecha um painel central localizado;
- cada Wave concluída concede 1 Ponto de Fábrica;
- Waves Elite concedem +1 ponto adicional;
- Coleta Automática custa 2 pontos, começa bloqueada e pode ser ligada/desligada depois da compra;
- Expansão da Fila possui 3 níveis, +2 espaços por nível e custo crescente;
- Sobrecarga do Processador possui 3 níveis, -0,10 s por ciclo e custo crescente;
- auto-coleta só preenche espaços livres e preserva Corpses excedentes;
- o painel fecha quando a seleção de upgrade de Wave aparece;
- runner: `tests/factory/factory_automation_runner.gd`.

Próximo passo: playtestar o ritmo dos Pontos de Fábrica e iniciar produção em lote/Army Doctrine sem transformar automação em reposição instantânea.

### Manual Batch Production V1 — implementada e validada

- `SpinBox` compartilhado aceita quantidade de 1 a `MAX_UNDEAD` (36);
- valor pode ser digitado ou ajustado pelas setas;
- botões de Skeleton/Zombie exibem quantidade e custo total;
- lote é atômico: recursos ou vagas insuficientes produzem zero unidades;
- produção individual continua sendo o caso `quantidade = 1`;
- signal `batch_production_completed(unit_type, quantity, total_cost)` reserva integração visual/sonora;
- runner: `tests/factory/batch_production_runner.gd`.

Isto ainda é produção manual instantânea. Não marcar Skeleton Assembler/Flesh Vat queues como concluídos; essas máquinas precisarão de tempo, fila e feedback próprios.

Próximo passo: desenhar Army Doctrine com composição-alvo e reserva mínima de recursos antes de ativar reposição automática.

### Army Doctrine Planning V1 — implementada e validada

- botão `DOUTRINA` abre/fecha painel localizado em PT-BR, inglês e espanhol;
- composição-alvo separada para Skeletons e Zombies, limitada ao `MAX_UNDEAD` combinado;
- reservas mínimas configuráveis para Bones e Flesh;
- prioridades Balanced, Skeletons First e Zombies First;
- resumo ao vivo mostra meta, exército atual e déficits;
- `scripts/factory/army_doctrine_policy.gd` isola validação, cálculo de déficit, ordem futura e gasto seguro acima da reserva;
- aplicação inválida é atômica e não altera a configuração anterior;
- runner: `tests/factory/army_doctrine_runner.gd`.

A V1 nasceu somente como planejamento e não criava tropas automaticamente. As seções seguintes registram as filas temporizadas e a execução posterior da Doutrina com capacidade, reservas e controle de pausa.

### Timed Undead Production Queues V1 — implementadas e validadas

- os botões da faixa inferior agora enfileiram pedidos manuais;
- pedido aceito reserva imediatamente todo o custo e as vagas futuras;
- Skeleton Assembler produz 1 unidade a cada 0,45 s;
- Flesh Vat produz 1 unidade a cada 0,80 s;
- máquinas trabalham em paralelo e aceitam até 3 pedidos cada;
- a UI localizada mostra unidades restantes e timer atual;
- unidades enfileiradas impedem derrota falsa durante reconstrução;
- `scripts/factory/undead_production_policy.gd` isola validação e contagem reservada;
- runner: `tests/factory/undead_production_queue_runner.gd`.

### Army Doctrine Execution V1 — implementada e validada

- botão localizado inicia ou pausa a reposição;
- déficits descontam Skeletons/Zombies já enfileirados;
- prioridades Balanced, Skeletons First e Zombies First distribuem capacidade escassa;
- reservas mínimas são verificadas antes da reserva atômica do pedido;
- produção usa somente `enqueue_skeleton_production()` e `enqueue_zombie_production()`;
- pausar impede pedidos futuros, mas preserva ordens já pagas;
- runner: `tests/factory/army_doctrine_automation_runner.gd`.

Próximo passo: playtestar a Doutrina durante uma run manual completa e avançar para máquinas/roteamento de Blood e Souls.

### Necromantic Economy v0.2 — concluída e validada

- viewport usa `stretch/aspect="keep"`, impedindo corte da faixa inferior;
- botões usam “Produzir … (Fila)” para comunicar ação e tempo;
- Blood: geração por kills/Elite/Boss, Blood Fervor, Hematic Extraction e Crimson Infusion;
- sinergia Blood: Crimson Assembly;
- Souls: geração controlada por Mage/Elf/Foreman;
- Ghost V1: custo 4 Souls, ranged magic, HP próprio, health bar e formação traseira;
- upgrades Soul: Spectral Focus e Ethereal Anchor;
- sinergia Soul: Phantom Conduit;
- primeiro runtime genérico em `scripts/units/undead_runtime_unit.gd`;
- duas runs determinísticas completas (Bone e Flesh) venceram o Foreman;
- Blood/Soul foram desacelerados após evidência de inflação;
- clip local de 5 s: `.godot/necroworks_v020_milestone.avi`;
- runners novos: `blood_soul_runner.gd`, `full_run_runner.gd` e `layout_bounds_runner.gd`.

O próximo trabalho da v0.3.0 é validar o ritmo da Doutrina em uma run manual e aprofundar máquinas, roteamento, eficiência e sinergias da Factory.

### Rare-resource Factory V1 — implementada localmente

- painel Factory reorganizado em grade 3×2;
- desbloqueio custa 3 Pontos de Fábrica;
- cada ordem reserva 12 Flesh e produz 1 Blood após 2 s;
- fila suporta 3 unidades e mostra timer ao vivo;
- Blood produzido atualiza recursos e métrica total;
- runner: `tests/factory/hematic_press_runner.gd`.

- Soul Extractor custa 4 Pontos de Fábrica;
- Mage/Elf/Foreman geram cadáveres arcanos elegíveis;
- rota arcana envia esses cadáveres para uma fila separada de 3 slots;
- processamento material e extração de Soul são mutuamente exclusivos;
- Eficiência Industrial possui 3 níveis e melhora as duas máquinas raras;
- Hematic Press + Eficiência II libera Refinaria Sombria;
- painel de sinergias comporta as 8 sinergias atuais;
- runners: `rare_resource_routing_runner.gd` e `synergy_bounds_runner.gd`.

Próximo passo recomendado: run manual completa da v0.3 e, se o ritmo estiver saudável, iniciar receitas/unidades da v0.4.

### Factory Automation / Army Doctrine — direção registrada

O usuário quer reduzir cliques repetitivos sem remover estratégia. Direção preferida:

```text
Target Army: 5 Zombies + 30 Skeletons
→ Factory monitora perdas
→ cria reposições quando houver recursos, população e throughput
```

O sistema futuro deve incluir:

- auto-coleta de Corpses como unlock/toggle;
- fila e velocidade do Corpse Processor;
- quantidade manual por stepper para ordens em lote;
- Army Doctrine com composição-alvo;
- prioridades de reposição e reserva mínima de recursos;
- pausa/desativação da automação;
- painel de Factory Upgrades aberto por botão;
- upgrades de Processor, Skeleton Assembler, Flesh Vat, Logistics e Research.

Não implementar reposição instantânea e ilimitada. Produção deve respeitar recursos, `MAX_UNDEAD`, capacidade da fila e tempo das máquinas, além de mostrar feedback visível.

### Unidades futuras registradas

```text
Skeleton Warrior → Bone melee base
Skeleton Archer  → Bone ranged, receita desbloqueável
Zombie Tank      → Flesh frontline
Lich             → caster/support desbloqueável, pode invocar Skeletons temporários
```

Archer/Lich exigem primeiro uma camada genérica de Undead. O summon do Lich precisa de cap, cooldown ou custo para impedir crescimento infinito.

### Menus e idiomas registrados

- Main Menu, Pause e Options são obrigatórios para o vertical slice;
- idiomas-alvo: PT-BR, English e Spanish;
- criar infraestrutura de chaves/traduções antes de multiplicar painéis de UI;
- tradução final e QA somente quando os textos estabilizarem;
- settings e saves precisam ser persistentes e versionados.

### Direções registradas para conteúdo futuro

Os inimigos são povos vivos com papéis distintos; a primeira versão mecânica já existe:

```text
Human Warrior → durable frontline
Mage          → fragile ranged damage
Elf           → fast skirmisher
```

O jogo também precisa de uma lore envolvente antes e durante as runs. A escrita completa foi deliberadamente adiada, mas deve cobrir a origem da NecroWorks, a coalizão dos vivos, The Foreman, registros corporativos e as consequências da reanimação industrial.

### Phase 3 — Blood

Só depois dar geração real ao Blood e um sink concreto.

### Phase 4 — Souls/Ghost

Depois:

```text
Souls → Ghost
```

Ghost deve introduzir comportamento ranged/magic.

---

# 18. Arquitetura — próxima melhoria

O maior risco futuro é continuar crescendo:

```text
skeletons
zombies
ghosts
abominations
...
```

com duplicação de toda função.

Direção:

```text
Undead Unit
├── type
├── hp
├── max_hp
├── damage
├── cooldown
├── speed
├── slot
└── tags
```

Porém:

**não fazer essa refatoração inteira agora.**

Fazer incrementalmente antes do primeiro terceiro tipo jogável (Skeleton Archer, Lich ou Ghost). A nova direção de tropas torna esse gatilho concreto.

---

# 19. Comercial

Objetivo:
maximizar probabilidade de sucesso comercial na Steam.

Não existe garantia de receita.

Hook:

```text
Kill
→ Recycle
→ Manufacture
→ Swarm
```

A diferença visual/comercial precisa ser:

**industrial necromancy**, não somente "skeleton roguelite".

Antes de marketing forte:

- build diversity;
- Factory;
- representative visuals;
- readable UI;
- satisfying corpse-to-production loop.

---

# 20. Roadmap macro

```text
v0.1.0  First Run                    ← funcionalmente concluído
v0.2.0  Necromantic Economy          ← concluída
v0.3.0  Factory / Automation         ← AGORA
v0.4.0  Build Diversity & Content
v0.5.0  Meta Progression
v0.6.0  Vertical Slice
v0.7.0  Steam Demo / Market Validation
v0.8.0  Alpha
v0.9.0  Beta / Release Candidate
v1.0.0  Steam Launch
```

---

# 21. Git / continuidade

Antes de trabalhar:

```powershell
git status
git pull origin main
```

Depois de um bloco estável:

```powershell
git add .
git commit -m "..."
git push origin main
```

Exemplo de commit para o próximo marco estável:

```powershell
git add .
git commit -m "feat: add timed undead production queues"
git push origin main
```

Antes disso, verificar se existem alterações locais não relacionadas.

---

# 22. Baseline atual para próximo chat

O orquestrador estável permanece em:

```text
main.gd
```

Último marco publicado: Necromantic Economy v0.2 e correção do HUD inferior. O bloco local adiciona Army Doctrine Execution V1 sobre as filas temporizadas.

Próxima conversa deve partir da automação já conectada aos métodos públicos de enqueue. Não recriar o protótipo antigo nem ligar automação aos métodos instantâneos de lote.

---

# 23. Atualização 20/08/2026 — início da v0.4.0

A fundação genérica de tropas agora está ativa:

- `scripts/units/undead_runtime_unit.gd` armazena identidade de receita, família de produção, papel de combate, HP, dano, cooldown, timer, velocidade, alcance e slot;
- `scripts/game/undead_recipe_catalog.gd` formaliza `skeleton_warrior`, `zombie_tank` e `ghost`;
- `skeleton.tscn` e `ghost.tscn` usam o componente compartilhado;
- Skeletons e Zombies são configurados por receita no registro;
- mutações de HP, timers e consultas de slot passam por helpers genéricos;
- os dicionários antigos continuam como espelhos temporários para testes e futura migração de save;
- `tests/units/undead_runtime_runner.gd` protege identidade, papéis, HP, slot e sincronização após dano.

Validações executadas com sucesso:

- runtime genérico;
- cenários de composição da Wave 8;
- automação da Doutrina;
- Blood/Soul/Ghost;
- limites do layout e das sinergias;
- duas runs completas até The Foreman.

Próximo passo: implementar Skeleton Archer como receita Bone desbloqueável e usar seu comportamento à distância para validar que nenhuma terceira família de dicionários será criada.

## Skeleton Archer V1 — implementado e validado

- blueprint run-scoped comprado por 3 Factory Points;
- receita de 8 Bones, 65 HP, 14 Damage, cooldown 1,1 s, speed 160 e range 380;
- pedidos usam a Skeleton Assembler existente e carregam `unit_type` próprio em FIFO;
- o Arqueiro entra no mesmo array de família Bone, sem dicionários paralelos;
- `combat_role=ranged_damage` mantém a unidade atrás de Zombies e Skeleton Warriors;
- sprite temporário original em `assets/sprites/units/skeleton_archer_prototype.png`, com alfa real e import limitado a 512 px;
- textos de produção/blueprint disponíveis em EN, PT-BR e ES;
- upgrades de Bone afetam atributos atuais e futuros do Arqueiro;
- `tests/units/skeleton_archer_runner.gd` valida o fluxo completo.

## Lich Summoner V1 — implementado e validado

- blueprint run-scoped comprado por 5 Factory Points;
- receita de 8 Souls, 90 HP, 11 Damage, cooldown de ataque 1,6 s e range 350;
- cada Lich tenta invocar um `lich_thrall` por 1 Soul, com cooldown base de 10 s;
- limite global base de 6 Servos, duração base de 15 s e ocupação normal do cap de 36 Undead;
- Servos não contam como Skeletons produzidos/perdidos e não ativam Reassembly nem Final Service;
- Grave Contract aumenta o cap, Rapid Conjuration reduz cooldown e Bound Servitude aumenta duração;
- Soul Foundry fortalece futuras invocações para 55 HP e 8 Damage;
- Balística do Ossuário eleva o catálogo para 10 sinergias e concede +80 range aos Arqueiros;
- `tests/units/lich_summoning_runner.gd` cobre receita, combate, custo, cap, duração, upgrades, sinergia, métricas e anti-exploit;
- regressão completa: 21/21 runners aprovados em Godot 4.7.1 headless.

Próximo passo recomendado: fazer uma run manual concentrada em Archer/Lich para avaliar pressão de Souls, cap temporário e legibilidade da retaguarda. Depois, escolher entre upgrades raros/regra-alteradora ou comportamento avançado de Mage/Elf.

## Atualização v0.4 — comportamento inimigo e primeiro raro

- `scripts/game/enemy_combat_policy.gd` centraliza frequências e multiplicadores dos ataques especiais;
- Mage dispara Rajada Arcana no terceiro ataque: máximo de três alvos, splash de 50% e supressão de 0,30 s;
- Elf dispara Tiro de Precisão no quarto ataque: prioriza Summoner, Ranged Support e Ranged Damage antes de melee/tank e causa 135% de dano;
- os ataques especiais têm feedback localizado e emitem `enemy_ability_triggered`;
- Recuperação Emergencial é o primeiro upgrade raro/regra-alteradora, elegível após a Wave 8;
- o raro devolve uma vez por Wave 50% do custo da primeira unidade permanente perdida;
- `lich_thrall` é explicitamente excluído do gatilho;
- o HUD direito foi redistribuído para comportar todas as métricas e dez sinergias sem sobreposição;
- `tests/combat/enemy_advanced_behavior_runner.gd` e `tests/upgrades/rare_upgrade_runner.gd` protegem o novo contrato;
- regressão completa atual: 23/23 runners aprovados, incluindo duas runs até o Foreman.

Próximo passo recomendado: run manual Archer/Lich sob pressão dos novos ataques. Se legível e balanceado, implementar elite variants antes de aumentar novamente o número de unidades.
