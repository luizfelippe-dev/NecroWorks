# NecroWorks — AI Handoff

**Última atualização:** 16/08/2026

## Objetivo deste documento

Este arquivo contém o estado atual do desenvolvimento de **NecroWorks**.

Ele deve permitir que outra conversa do ChatGPT continue o projeto sem depender do histórico completo de conversas anteriores.

Sempre consultar este arquivo antes de continuar o desenvolvimento.

---

## Identidade do projeto

**Nome:** NecroWorks  
**Subtítulo de marca:** Industrial Reanimation Solutions  
**Slogan:** Waste Nothing. Raise Everything.

Nome anterior durante o início do protótipo: `Corpse Factory`.

O nome foi alterado porque já existia outro jogo comercial com o nome anterior.

---

## Informações técnicas

**Engine:** Godot 4.7.1  
**Linguagem:** GDScript  
**Tipo:** 2D  
**Plataforma inicial:** Windows / Steam  
**Desenvolvimento:** solo  
**Repositório:** Git/GitHub  
**Branch principal:** `main`

Gêneros / pilares:

- Roguelite
- Autobattler
- Automação
- Estratégia
- Incremental

---

## Conceito

O jogador controla uma operação de necromancia industrial.

Enemies atacam.

Quando mortos, seus cadáveres permanecem no campo e podem ser processados.

Cadáveres serão transformados em recursos como:

- Bones
- Flesh
- Blood
- Souls

Esses recursos permitem produzir mortos-vivos, melhorar a operação e, futuramente, construir máquinas e automações.

O objetivo de design é permitir builds fortes e combinações emergentes com relativamente poucas regras.

---

## Filosofia de design

O jogo deve ser:

- fácil de entender;
- barato de produzir;
- adequado para desenvolvimento solo;
- altamente rejogável;
- satisfatório visualmente;
- divertido de assistir;
- capaz de produzir builds absurdas;
- baseado mais em sistemas do que em enorme quantidade de assets.

Princípio:

> Poucas regras simples devem gerar muitas interações complexas.

Não copiar sistemas, arte ou identidade de outros jogos.

---

## Loop principal planejado

Enemy aparece  
→ undead atacam automaticamente  
→ Enemy morre  
→ Corpse aparece  
→ Corpse é processado  
→ recursos são obtidos  
→ novas criaturas são produzidas  
→ exército cresce  
→ Waves ficam mais fortes  
→ upgrades são escolhidos  
→ sinergias aparecem  
→ boss  
→ fim da run.

---

## Estado de versão

**Última versão estável:** `v0.0.2`

### v0.0.1

Combat prototype:

- movimento;
- HP;
- dano;
- cooldown;
- ataque automático;
- morte.

### v0.0.2

Corpse Loop + múltiplas unidades + movimentação estabilizada:

- Corpse;
- Bones;
- criação de Skeleton;
- múltiplos Skeletons;
- HP individual;
- cooldown individual;
- Enemy respawn;
- Node2D;
- unidades dinâmicas visíveis;
- target-based movement;
- retarget;
- HUD de debug.

### Próxima versão

`v0.0.3 — Waves`

---

## Arquitetura atual das cenas

### `main.tscn`

Estrutura atual relevante:

```text
Main
├── Background
├── Skeleton
├── Enemy
├── BonesLabel
└── CreateSkeletonButton
```

`Corpse`, novos `Skeletons`, novos `Enemies` e o HUD de debug podem ser criados dinamicamente durante a execução.

### `skeleton.tscn`

- raiz: `Node2D`;
- cena reutilizável;
- placeholder visual temporário.

### `enemy.tscn`

- raiz: `Node2D`;
- cena reutilizável;
- placeholder visual temporário.

### `corpse.tscn`

- raiz: `Button`;
- clicável;
- usado atualmente para representar e processar Corpse.

---

## `main.gd` — responsabilidades atuais

O protótipo ainda concentra a maior parte da lógica em `main.gd`.

Responsabilidades atuais:

- referência às cenas reutilizáveis;
- registro de Skeletons;
- HP individual de Skeleton;
- cooldown individual de Skeleton;
- HP do Enemy atual;
- dano;
- cooldown;
- target acquisition;
- movimentação de Skeletons;
- movimentação de Enemy;
- retarget;
- morte de Skeleton;
- morte de Enemy;
- spawn de Enemy;
- spawn de Corpse;
- processamento de Corpse;
- Bones;
- criação de Skeleton;
- slots de spawn;
- posições de combate;
- placeholders visuais;
- HUD de debug;
- atualização básica da UI.

Esta centralização é intencional durante o protótipo.

Não refatorar para vários managers antes de haver necessidade real.

---

## Estado atual — funcionando

- [x] Projeto Godot 4.7.1
- [x] Main
- [x] Background
- [x] Skeleton
- [x] Enemy
- [x] Node2D para Skeleton e Enemy
- [x] Placeholder visual
- [x] Movimento automático baseado em alvo
- [x] Enemy procura Skeleton mais próximo
- [x] Skeleton procura Enemy
- [x] Retarget
- [x] Sistema de HP
- [x] HP individual dos Skeletons
- [x] Dano
- [x] Cooldown
- [x] Cooldown individual dos Skeletons
- [x] Morte
- [x] Corpse
- [x] Processamento de Corpse
- [x] Bones
- [x] BonesLabel
- [x] Create Skeleton
- [x] Múltiplos Skeletons
- [x] Spawn contínuo de Enemy
- [x] Enemy dinâmico visível
- [x] Skeleton dinâmico visível
- [x] Novos Skeletons nascem na base
- [x] Reconstrução do exército após perda total
- [x] HUD de debug

---

## Não implementado

- [ ] Waves
- [ ] Wave counter
- [ ] Enemies por Wave
- [ ] Scaling de HP/dano
- [ ] Elite Wave
- [ ] Upgrades
- [ ] Sinergias
- [ ] Factory
- [ ] Flesh
- [ ] Blood
- [ ] Souls
- [ ] Zombie
- [ ] Ghost
- [ ] Abomination
- [ ] Boss
- [ ] Vitória
- [ ] Derrota definitiva
- [ ] Meta-progressão

---

## Movimentação v1 — comportamento esperado

A movimentação atual foi estabilizada em 16/08/2026.

### Skeleton

- nasce em posição de spawn na base;
- procura o Enemy atual;
- move-se em 2D em direção à sua posição de combate;
- não utiliza mais deslocamento global do exército;
- reforços não devem nascer magicamente na linha de frente.

### Enemy

- procura o Skeleton mais próximo;
- aproxima-se desse Skeleton;
- para ao entrar em alcance;
- ataca;
- se o alvo morrer, procura outro.

### Após morte do Enemy

- Corpse é criado;
- Enemy atual é removido;
- após pequeno delay surge novo Enemy;
- Skeletons passam a perseguir o novo alvo.

---

## Economia atual

### Bones

- recurso atualmente implementado;
- cada Corpse processado concede Bones;
- Skeleton custa Bones;
- valor de teste deve permanecer `0` em builds estáveis, evitando deixar cheats de teste ativos.

### Recursos futuros

- Flesh
- Blood
- Souls

---

## UI atual

Elementos principais:

- `BonesLabel`;
- `CreateSkeletonButton`;
- HUD de debug temporário.

O HUD de debug atualmente ajuda a verificar:

- quantidade de Skeletons;
- HP do Enemy;
- distância aproximada do alvo.

Manter durante o desenvolvimento de Waves.

---

## Próxima tarefa — v0.0.3 Waves

Implementar Waves sem alterar desnecessariamente a movimentação v1.

Objetivo inicial:

1. Wave counter.
2. Quantidade definida de Enemies por Wave.
3. Enemies remaining.
4. Pequeno intervalo entre Enemies da mesma Wave.
5. Estado `Wave Complete`.
6. Intervalo entre Waves.
7. Aumento gradual de HP.
8. Aumento gradual de dano.
9. HUD da Wave.
10. Elite Wave a cada 5 Waves.
11. Testar progressão de pelo menos 10 Waves.

Direção inicial de balanceamento discutida:

- Wave 1: base de 5 Enemies;
- Waves seguintes aumentam gradualmente quantidade e resistência;
- a cada 5 Waves haverá uma Wave especial/Elite.

Os números não são definitivos e devem ser ajustados por playtest.

---

## Future Concept — Last Stand

Quando todos os Skeletons morrerem, a derrota não precisa necessariamente ser instantânea.

Possível sistema futuro:

- entrar em estado de alerta;
- permitir alguns segundos para reconstrução;
- manter Corpses e recursos disponíveis;
- permitir reanimação de emergência;
- Game Over apenas se o jogador não conseguir voltar ao combate a tempo.

**Status:** não implementado. Registrar como conceito futuro, não como funcionalidade atual.

---

## Regra de desenvolvimento

Não implementar muitos sistemas de uma vez.

Fluxo obrigatório:

implementar  
→ testar  
→ corrigir  
→ documentar  
→ commit  
→ push  
→ próxima funcionalidade.

Antes de considerar uma feature estável:

- testar comportamento normal;
- testar criação dinâmica;
- testar morte/respawn;
- remover cheats temporários;
- atualizar documentação.

---

## Política de documentação

### `CHANGELOG.md`

Registrar apenas comportamento implementado e estável.

### `GAME_DESIGN.md`

Registrar conceitos, sistemas planejados e ideias futuras.

### `ROADMAP.md`

Registrar milestones e tarefas.

### `ARCHITECTURE.md`

Registrar estrutura técnica atual e direção de refatoração.

### `DECISIONS.md`

Registrar decisões importantes e seus motivos.

### `DEVLOG.md`

Registrar evolução cronológica do desenvolvimento.

### `AI_HANDOFF.md`

Manter como resumo consolidado e fonte de continuidade para outra conversa.

---

## Próximo milestone

**Prototype v0.0.3 — Waves**

Não iniciar arte definitiva, Factory complexa ou novos recursos antes de validar Waves e, depois, o sistema de upgrades.
