# NecroWorks — Roadmap

**Atualizado:** 17/08/2026

Este roadmap separa o desenvolvimento em milestones de gameplay, produto e comercialização.

A prioridade é terminar um jogo forte e comercializável, não maximizar a quantidade de features.

---

# Visão geral

```text
v0.0.x — provar o core
v0.1.0 — primeira run completa
v0.2.0 — economia necromântica
v0.3.0 — Factory
v0.4.0 — diversidade de builds/conteúdo
v0.5.0 — meta-progressão e variedade
v0.6.0 — vertical slice polido
v0.7.0 — demo/Steam/validação de mercado
v0.8.0 — alpha
v0.9.0 — beta/release candidate
v1.0.0 — lançamento Steam
pós-lançamento — suporte e expansão
```

---

# v0.0.1 — Combat

- [x] Projeto Godot
- [x] Main
- [x] Skeleton
- [x] Enemy
- [x] Movimento
- [x] HP
- [x] Damage
- [x] Cooldown
- [x] Combate automático
- [x] Morte

**Status:** concluído.

---

# v0.0.2 — Corpse Loop

- [x] Corpse
- [x] Spawn de Corpse
- [x] Processar Corpse
- [x] Bones
- [x] Bones HUD
- [x] Create Skeleton
- [x] Múltiplos Skeletons
- [x] HP individual
- [x] Cooldown individual
- [x] Enemy respawn
- [x] Node2D
- [x] Dynamic visuals
- [x] Target-based movement
- [x] Retarget
- [x] Debug HUD

**Status:** concluído.

---

# v0.0.3 — Waves

- [x] Wave counter
- [x] Enemies por Wave
- [x] Enemies Remaining
- [x] Delay entre Enemies
- [x] Wave Complete
- [x] HP scaling
- [x] Damage scaling
- [x] Elite Wave
- [x] Wave HUD
- [x] Teste em Waves altas

**Status:** concluído.

---

# v0.1.0 — First Run

## Já implementado

- [x] Upgrade selection
- [x] 3 opções por Wave
- [x] Pool de 10 upgrades
- [x] Randomização de escolhas
- [x] Upgrades acumuláveis
- [x] Upgrades com limites
- [x] 4 primeiras sinergias
- [x] Synergy HUD
- [x] Run metrics
- [x] Playtest longo até Wave 21

## Próximo bloco

- [ ] Boss Wave 20
- [ ] Primeiro Boss — The Foreman
- [ ] Ataque multi-target/AOE do Boss
- [ ] Victory
- [ ] Run Summary
- [ ] Game Over
- [ ] Restart Run
- [ ] Teste do fluxo completo
- [ ] Balance pass inicial
- [ ] Validar proc de Bone Assembly Line em runtime
- [ ] Atualizar docs
- [ ] Commit/tag `v0.1.0`

### Gate para avançar

Uma pessoa deve conseguir:

1. iniciar;
2. entender o loop sem explicação longa;
3. crescer;
4. escolher upgrades;
5. desbloquear sinergia;
6. enfrentar Boss;
7. ganhar ou perder;
8. reiniciar.

---

# v0.2.0 — Necromantic Economy

Objetivo:
parar de ser um jogo quase exclusivamente de Bones/Skeleton e criar as primeiras decisões econômicas reais.

- [ ] Flesh
- [ ] Blood
- [ ] Souls
- [ ] Drop/processing por recurso
- [ ] Zombie
- [ ] Ghost
- [ ] Abomination
- [ ] Pelo menos 1 linha clara de build por recurso
- [ ] Upgrades específicos por recurso
- [ ] Primeiras combinações multi-resource
- [ ] UI de múltiplos recursos
- [ ] Balanceamento de custo/produção

### Gate

Runs diferentes devem começar a gerar exércitos diferentes.

---

# v0.3.0 — Factory / Automation

Objetivo:
entregar o diferencial de "industrial necromancy".

- [ ] Processamento automático
- [ ] Primeira máquina
- [ ] Produção automática
- [ ] Fila/rota de produção
- [ ] Melhorias de eficiência
- [ ] Interação entre máquina e upgrades
- [ ] Interação entre máquina e recursos
- [ ] Automação que cria decisões
- [ ] Feedback visual de produção
- [ ] Primeiras "factory builds"

### Gate

O jogador deve conseguir olhar para uma run avançada e sentir que construiu uma operação, não apenas um exército.

---

# v0.4.0 — Build Diversity & Content

Objetivo:
aumentar replayability sem explodir o escopo.

- [ ] ~30–40 upgrades úteis
- [ ] ~10–15 sinergias
- [ ] upgrades raros
- [ ] upgrades que alteram regras
- [ ] novos Enemy archetypes
- [ ] ranged Enemy
- [ ] tank Enemy
- [ ] fast Enemy
- [ ] special Enemy
- [ ] Elite variants
- [ ] 2–3 Bosses
- [ ] eventos simples
- [ ] Boss Corpses prototype
- [ ] receitas secretas

### Gate

Duas runs não devem parecer iguais apenas por números diferentes.

---

# v0.5.0 — Meta Progression & Run Variety

Objetivo:
criar motivos para jogar novamente sem tornar grind obrigatório.

- [ ] Save system
- [ ] Unlock system
- [ ] novos Undead desbloqueáveis
- [ ] novos upgrades desbloqueáveis
- [ ] operadores/personagens
- [ ] starting modifiers
- [ ] challenges
- [ ] codex/collection
- [ ] progressão baseada em possibilidades
- [ ] avaliar Last Stand
- [ ] run history/statistics

### Gate

Depois de perder/ganhar, o jogador deve querer clicar em "Run Again".

---

# v0.6.0 — Vertical Slice / Presentation

Objetivo:
transformar o protótipo em algo apresentável ao público.

- [ ] direção de arte definitiva
- [ ] Skeleton final
- [ ] primeiros Enemies finais
- [ ] Corpse final
- [ ] Boss final/polido
- [ ] UI/UX pass
- [ ] animações
- [ ] VFX
- [ ] feedback de hit/death/process
- [ ] áudio
- [ ] música
- [ ] screen shake/juice com moderação
- [ ] tutorial/onboarding
- [ ] settings
- [ ] volume controls
- [ ] resolution/fullscreen
- [ ] key rebinding se necessário
- [ ] gamepad evaluation
- [ ] performance pass
- [ ] demo interna de 10–20 min

### Gate

O jogo deve ser bom o bastante para um trailer e uma página de Steam sem parecer "protótipo de programador".

---

# v0.7.0 — Steam & Market Validation

Objetivo:
começar a vender a ideia antes de terminar o jogo.

- [ ] Steamworks setup
- [ ] nome/branding final verificados
- [ ] capsule art profissional
- [ ] screenshots de alta qualidade
- [ ] trailer curto
- [ ] store description
- [ ] tags corretas
- [ ] Coming Soon page
- [ ] wishlist tracking
- [ ] demo pública
- [ ] playtests externos
- [ ] feedback form
- [ ] crash/error collection
- [ ] criadores de conteúdo
- [ ] vídeos curtos / social clips
- [ ] comunidades relevantes
- [ ] avaliar Steam Next Fest
- [ ] medir reação do público

### Métricas comerciais a acompanhar

- wishlists;
- visitas → wishlists;
- demo downloads;
- demo completion;
- tempo médio de demo;
- restart rate;
- feedback qualitativo;
- criadores interessados;
- comentários sobre clareza do hook;
- bugs/crashes.

### Gate

Não avançar cegamente para lançamento se a reação pública indicar que hook, visual ou posicionamento não funcionam.

---

# v0.8.0 — Alpha / Full Game

Objetivo:
ter todo o conteúdo necessário para a versão 1.0.

- [ ] estrutura completa de runs
- [ ] conteúdo alvo implementado
- [ ] bosses finais
- [ ] upgrades finais principais
- [ ] sinergias finais principais
- [ ] meta-progressão funcional
- [ ] balanceamento de todos os sistemas
- [ ] performance com hordas
- [ ] Steam achievements
- [ ] Steam integration necessária
- [ ] save migration/versioning
- [ ] analytics internos de balanceamento
- [ ] localization pipeline
- [ ] PT-BR
- [ ] English
- [ ] accessibility review

---

# v0.9.0 — Beta / Release Candidate

Objetivo:
parar de adicionar sistemas e terminar o produto.

- [ ] feature freeze
- [ ] QA
- [ ] bugs críticos
- [ ] bugs de save
- [ ] bugs de progressão
- [ ] crash testing
- [ ] performance testing
- [ ] balancing final
- [ ] tutorial final
- [ ] Steam Deck evaluation
- [ ] achievements test
- [ ] localization QA
- [ ] trailer final
- [ ] screenshots finais
- [ ] press/creator outreach
- [ ] pricing research
- [ ] release date
- [ ] launch discount decision
- [ ] review build
- [ ] release candidate

---

# v1.0.0 — Steam Launch

- [ ] build final
- [ ] Steam review concluído
- [ ] store page final
- [ ] preço final
- [ ] lançamento
- [ ] monitorar crash reports
- [ ] hotfix readiness
- [ ] responder bugs
- [ ] acompanhar reviews
- [ ] acompanhar wishlist conversion
- [ ] comunicar roadmap pós-lançamento sem prometer demais

---

# Pós-lançamento

Prioridade depende da tração real.

Possibilidades:

- patches;
- balance updates;
- novos upgrades;
- novos bosses;
- novos operadores;
- novos recursos;
- novas máquinas;
- challenge modes;
- conteúdo gratuito;
- DLC/expansão se houver audiência;
- achievements adicionais;
- eventos;
- sales;
- bundles;
- port para outras plataformas somente se comercialmente justificável.

---

# Regra comercial

O objetivo é **maximizar as chances** de o jogo vender bem na Steam.

Não existe roadmap capaz de garantir receita.

A estratégia deve ser:

```text
hook forte
+ jogo divertido
+ replayability
+ apresentação profissional
+ Steam page cedo
+ wishlists
+ demo excelente
+ feedback real
+ marketing consistente
+ lançamento tecnicamente sólido
```

Escopo deve ser cortado sempre que uma feature não aumentar claramente:

- diversão;
- diferenciação;
- retenção;
- valor percebido;
- capacidade de marketing;
- qualidade do produto.
