# NecroWorks — Roadmap

## Estado atual

**Versão estável:** v0.0.2  
**Próximo milestone:** v0.0.3 — Waves  
**Foco atual:** transformar o combate contínuo em uma estrutura de Waves com progressão de dificuldade.

---

## Prototype v0.0.1 — Combat

- [x] Criar projeto Godot
- [x] Criar Main
- [x] Criar Background
- [x] Criar Skeleton
- [x] Criar Enemy
- [x] Movimento automático
- [x] HP
- [x] Dano
- [x] Cooldown de ataque
- [x] Combate automático
- [x] Morte

**Status:** concluído.

---

## Prototype v0.0.2 — Corpse Loop

- [x] Criar Corpse
- [x] Gerar Corpse na morte
- [x] Permitir selecionar Corpse
- [x] Processar Corpse
- [x] Adicionar recurso Bones
- [x] Mostrar Bones na interface
- [x] Criar Skeleton usando Bones
- [x] Spawn contínuo de Enemy
- [x] Múltiplos Skeletons
- [x] HP individual dos Skeletons
- [x] Cooldown individual dos Skeletons
- [x] Migração de Skeleton e Enemy para Node2D
- [x] Corrigir renderização de unidades instanciadas dinamicamente
- [x] Target-based movement
- [x] Enemy retarget
- [x] Novos Skeletons nascem na base
- [x] HUD de debug

### Objetivo

Enemy → Corpse → Bones → Skeleton

**Status:** concluído e estabilizado.

---

## Prototype v0.0.3 — Waves

- [ ] Wave counter
- [ ] Enemies por Wave
- [ ] Contador de Enemies restantes
- [ ] Intervalo entre Enemies da mesma Wave
- [ ] Estado `Wave Complete`
- [ ] Intervalo entre Waves
- [ ] Aumento de HP por Wave
- [ ] Aumento de dano por Wave
- [ ] HUD da Wave
- [ ] Elite Wave a cada 5 Waves
- [ ] Teste de progressão por pelo menos 10 Waves
- [ ] Ajuste inicial de balanceamento

### Objetivo

Criar começo, progressão e encerramento claros para os combates.

Estrutura pretendida:

Wave começa  
→ Enemies são derrotados  
→ último Enemy morre  
→ Wave Complete  
→ intervalo de gerenciamento  
→ próxima Wave mais difícil.

---

## Prototype v0.1.0 — First Run

- [ ] Sistema de upgrades
- [ ] Escolha entre três upgrades
- [ ] 10 upgrades básicos
- [ ] Primeiras sinergias
- [ ] Boss
- [ ] Vitória
- [ ] Derrota
- [ ] Reiniciar run

### Objetivo

Permitir uma run completa com início, crescimento de build e condição de encerramento.

---

## Prototype v0.2.0 — Necromantic Economy

- [ ] Flesh
- [ ] Blood
- [ ] Souls
- [ ] Zombie
- [ ] Ghost
- [ ] Abomination
- [ ] Expandir utilidade de Bones
- [ ] Diferenciar linhas de produção por recurso

---

## Prototype v0.3.0 — Factory

- [ ] Processamento automático
- [ ] Máquinas
- [ ] Produção automática
- [ ] Rotas de recursos
- [ ] Melhorias de produção
- [ ] Primeiras interações entre Factory e upgrades

---

## Futuro

- [ ] Personagens jogáveis
- [ ] Meta-progressão
- [ ] Receitas secretas
- [ ] Elite enemies com identidade própria
- [ ] Boss corpses
- [ ] Eventos
- [ ] Achievements
- [ ] Steam integration
- [ ] Demo pública
- [ ] Testar sistema Last Stand / segunda chance após perda total do exército
