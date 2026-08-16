# NecroWorks — Devlog

## 14/08/2026 — Projeto iniciado

### Implementado

- Projeto criado no Godot 4.7.1.
- Cena Main criada.
- Background criado.
- Skeleton placeholder criado.
- Enemy placeholder criado.
- Movimento automático implementado.
- Sistema de HP implementado.
- Ataque automático implementado.
- Cooldown implementado.
- Morte básica implementada.

### Resultado

Skeleton e Enemy caminham automaticamente um em direção ao outro.

Ao entrarem no alcance de combate, começam a atacar.

Enemy é removido quando seu HP chega a zero.

### Próxima tarefa

Criar Corpse quando Enemy morrer.

---

## 14/08/2026 — Corpse Processing

### Implementado

- Corpse é criado quando Enemy morre.
- Corpse aparece na posição da morte.
- Corpse pode ser clicado.
- Processar Corpse concede 5 Bones.
- Corpse desaparece após processamento.
- Contador de Bones adicionado à interface.
- 5 Bones → novo Skeleton está funcionando.

### Resultado

Loop atual:

Enemy → Corpse → Bones → Create New Skeleton

### Próxima tarefa

Suporte a múltiplos Skeletons em combate.

---

## 15/08/2026 — Multiple Skeleton Combat

### Implementado

- Skeletons agora são registrados individualmente.
- Cada Skeleton possui HP próprio.
- Cada Skeleton possui cooldown de ataque próprio.
- Vários Skeletons podem atacar o mesmo Enemy.
- Enemy seleciona o Skeleton mais próximo como alvo.
- Skeletons podem morrer individualmente.

### Próxima tarefa

Adicionar spawn contínuo de inimigos.

---

## 15/08/2026 — Continuous Enemy Spawning

### Implementado

- Enemy reaparece automaticamente após morrer.
- Novo Enemy recebe HP máximo.
- Combate continua entre spawns.
- Corpses permanecem disponíveis para processamento.
- Corrigido bug onde o jogo parava de processar após a morte do último Skeleton.
- Agora é possível reconstruir o exército após todos os Skeletons morrerem.

### Problema identificado

Skeletons novos podiam ocupar posições sobrepostas e eventualmente nascer fora da tela.

### Próxima tarefa

Corrigir posicionamento e estabilizar a movimentação de múltiplas unidades.

---

## 16/08/2026 — Node2D Migration

### Implementado

- Skeleton e Enemy migrados para `Node2D`.
- Cenas `skeleton.tscn` e `enemy.tscn` passaram a ser reutilizadas para instanciamento dinâmico.
- Visual provisório das unidades passou a ser garantido por código.
- Corrigido problema em que unidades instanciadas existiam e participavam do combate, mas não apareciam visualmente.

### Resultado

Skeletons e Enemies iniciais e dinâmicos são exibidos corretamente.

---

## 16/08/2026 — Target-Based Combat Movement

### Implementado

- Skeletons agora perseguem o Enemy atual em 2D.
- Enemy procura e persegue o Skeleton mais próximo.
- Removido sistema antigo de deslocamento global do exército.
- Novos Skeletons sempre nascem na base.
- Skeletons recebem posições de combate próximas ao Enemy.
- Novo Enemy é exibido corretamente após respawn.
- Novos Skeletons são exibidos corretamente.
- HUD de debug adicionado.
- Retarget após morte de Enemy está funcionando.

### Resultado

Movimentação v1 considerada estável para continuidade do protótipo.

Os principais problemas observados na migração para Node2D foram corrigidos.

### Próxima tarefa

Implementar sistema de Waves e progressão de dificuldade.

---

## 16/08/2026 — Project renamed to NecroWorks

O projeto anteriormente chamado `Corpse Factory` passa oficialmente a se chamar **NecroWorks**.

### Brand identity

**NecroWorks**  
*Industrial Reanimation Solutions*  
**Waste Nothing. Raise Everything.**

---

## 16/08/2026 — Prototype v0.0.2 estabilizado

### Estado do milestone

O primeiro loop econômico do projeto está funcional:

Enemy → morte → Corpse → processamento → Bones → novo Skeleton.

Também estão funcionando:

- múltiplos Skeletons;
- HP e cooldown individuais;
- respawn de Enemy;
- criação dinâmica de unidades;
- target-based movement;
- retarget;
- placeholders em Node2D;
- HUD de debug.

### Próximo milestone

**Prototype v0.0.3 — Waves**

Objetivo:

Criar estrutura de início, progressão e encerramento de Waves, com aumento gradual da dificuldade.
