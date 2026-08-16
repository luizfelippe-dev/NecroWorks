# Corpse Factory — Devlog

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

## 14/08/2026 — Corpse Processing

### Implementado

- Corpse é criado quando Enemy morre.
- Corpse aparece na posição da morte.
- Corpse pode ser clicado.
- Processar Corpse concede 5 Bones.
- Corpse desaparece após processamento.
- Contador de Bones adicionado à interface.
- 5 Bones → novo Skeleton está funcionando

### Resultado

Loop atual:

Enemy → Corpse → Bones → Create New Skeleton

### Próxima tarefa

Suporte a múltiplos Skeletons em combate.

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

## 15/08/2026 — Continuous Enemy Spawning

### Implementado

- Enemy reaparece automaticamente após morrer.
- Novo Enemy recebe HP máximo.
- Combate continua entre spawns.
- Corpses permanecem disponíveis para processamento.
- Corrigido bug onde o jogo parava de processar após a morte do último Skeleton.
- Agora é possível reconstruir o exército após todos os Skeletons morrerem.

### Problema identificado

Skeletons novos podem ocupar posições sobrepostas e eventualmente nascer fora da tela.

### Próxima tarefa

Implementar sistema de formação com posições de spawn limitadas à arena.
