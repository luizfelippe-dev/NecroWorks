# NecroWorks — AI Handoff

**Atualizado:** 18/08/2026

Este é o documento principal de continuidade do projeto.

# Identidade

**NecroWorks**  
**Industrial Reanimation Solutions**  
**Waste Nothing. Raise Everything.**

# Produto

Roguelite 2D de autobattler + estratégia + automação necromântica.

Core:

```text
Enemy
→ Corpse
→ Resource
→ Undead
→ Army
→ Wave
→ Upgrade
→ Synergy
→ Boss
→ Victory / Defeat
→ Restart
```

# Tecnologia

- Godot 4.7.1
- GDScript
- 2D
- single-player
- Windows primeiro
- Steam planejada
- Git/GitHub

# Estado de desenvolvimento

## v0.1.0 — First Run

**Funcionalmente completo e validado.**

Já existe:

- start de run;
- Skeleton inicial;
- Enemy;
- combate automático;
- Corpse;
- Bones;
- Skeleton production;
- Waves;
- Elite Waves;
- upgrades;
- random choices;
- synergies;
- Boss;
- Victory;
- Defeat;
- Run Summary;
- Restart.

O próximo trabalho é `v0.2.0 — Necromantic Economy`.

Não realizar grande refatoração antes de existir necessidade concreta.

# Valores atuais importantes

```gdscript
var skeleton_max_hp: int = 100
var skeleton_damage: int = 10
var skeleton_attack_cooldown: float = 0.7
var skeleton_speed: float = 180.0

var bones: int = 0
var bones_per_corpse: int = 8
var skeleton_cost: int = 5

const BASE_ENEMY_HP: int = 100
const ENEMY_HP_GROWTH: int = 20

const BASE_ENEMY_DAMAGE: int = 7
const ENEMY_DAMAGE_GROWTH: int = 1
```

Esses valores são provisórios.

# Waves

- Wave inicial: 1.
- base enemies: 5.
- +1 Enemy por Wave.
- Elite a cada 5 Waves, exceto Wave 20.
- Wave 20 = Boss.

# The Foreman

```text
Wave: 20
HP: 2200
Damage: 28
Industrial Crush:
- ~4 s
- até 6 Skeletons
- 35 dano/alvo
```

Boss usa lane horizontal controlada.

Bug já corrigido:
Boss podia sair da tela devido ao feedback entre perseguição e formação.

Correção:

- Y fixo de combate;
- limites de X;
- ataque baseado em distância horizontal;
- posições de combate limitadas;
- compactação dos slots de combate após mortes.

# Game Over

Derrota somente quando:

```text
Wave ativa
AND Skeletons == 0
AND Corpses == 0
AND Bones < Skeleton Cost
```

Isso permite recuperação se houver Corpse ou recursos suficientes.

# Upgrades

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

Três aparecem por Wave.

# Synergies

- Recycling Plant
- Second Shift
- Bone Assembly Line
- Overclocked Ossuary

# Métricas

- Enemies Killed
- Corpses Processed
- Skeletons Built
- Skeletons Lost
- Skeletons Revived
- Bones Earned
- upgrades
- synergies

# Estado de balanceamento

Não está final.

Problemas observados:

- Army cresce cedo demais.
- Bones podem acumular em excesso.
- 30+ Skeletons trituram Enemies sequenciais.
- Enemy comum ataca apenas um alvo e perde pressão em late game.
- upgrades de dano/attack speed podem multiplicar o problema.

Decisão do projeto em 18/08/2026:
**não fazer o balance pass profundo ainda.**

Primeiro inserir a base da economia multi-resource e pelo menos um novo Undead; depois balancear o sistema representativo do jogo final.

# Próxima tarefa imediata

## v0.2.0 — Necromantic Economy, Phase A

Objetivo:

- introduzir resource state para:
  - Bones;
  - Flesh;
  - Blood;
  - Souls;
- criar HUD de recursos compatível com a direção visual futura;
- preservar Bones/Skeleton funcional;
- preparar Corpse processing para múltiplos outputs;
- em seguida implementar o primeiro novo Undead: Zombie.

Evitar adicionar Flesh/Blood/Souls como números sem propósito durante muitas etapas. A intenção é fazer o primeiro novo recurso ganhar um sink rapidamente.

# Direção visual oficial

Foi definido um target visual próprio do projeto:

- battlefield central;
- HUD superior para Wave/Boss;
- painel de recursos à esquerda;
- Run Metrics e Active Synergies à direita;
- Factory/production na faixa inferior;
- cards de upgrade na parte inferior/contextual;
- estética dark fantasy industrial;
- metal escuro;
- verde necromântico;
- osso;
- equipamentos/máquinas;
- branding corporativo macabro.

Usar essa referência nas novas decisões de UI.

# Próximos milestones

```text
v0.2.0 Necromantic Economy
v0.3.0 Factory / Automation
v0.4.0 Build Diversity & Content
v0.5.0 Meta Progression
v0.6.0 Vertical Slice
v0.7.0 Steam Demo / Market Validation
v0.8.0 Alpha
v0.9.0 Beta / RC
v1.0.0 Steam Launch
```

# Workflow

```text
implementar
→ testar
→ corrigir
→ documentar
→ commit
→ push
```

User prefere arquivos completos para substituir, não snippets.
