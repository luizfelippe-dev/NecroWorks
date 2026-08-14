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

### Resultado

Loop atual:

Enemy → Corpse → Bones

### Próxima tarefa

Permitir gastar 5 Bones para criar um novo Skeleton.
