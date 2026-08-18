# NecroWorks — AI Handoff

**Atualizado em:** 18/08/2026  
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

A imagem conceitual criada pelo próprio usuário é o target visual oficial.

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
- continua usando placeholders para unidades e arte procedural temporária.

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
scripts/ui
```

`main.tscn` e `main.gd` permanecem na raiz como entry points estáveis para F5/F6.

---

# 17. Próxima tarefa recomendada

## v0.2.0 — Flesh Identity / Zombie Build

Zombie V1, Phase 1 (Zombie-specific upgrades) e Phase 2 (primeira Flesh synergy) estão funcionando.

Próximo objetivo:

### Phase 2B — Composition validation

Testar se Skeleton-only, Zombie-heavy e exército misto produzem decisões e resultados realmente diferentes.

Revisar Flesh pacing somente com evidência de runs comparáveis.

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

Fazer incrementalmente quando Ghost ou terceiro tipo tornar a duplicação realmente cara.

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
v0.2.0  Necromantic Economy          ← AGORA
v0.3.0  Factory / Automation
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

Após atualizar estes docs, um commit apropriado seria algo como:

```powershell
git add .
git commit -m "feat: add flesh economy and zombie unit"
git push origin main
```

Antes disso, verificar se existem alterações locais não relacionadas.

---

# 22. Baseline atual para próximo chat

O arquivo funcional validado pelo usuário equivale à versão:

```text
main_necroworks_v0_2_zombie_v1.gd
```

O orquestrador está salvo como:

```text
main.gd
```

Último teste confirmado pelo usuário:

> Resource Foundation funcionando e Zombie V1 funcionando.

Próxima conversa deve começar daqui, não da versão Skeleton-only.
