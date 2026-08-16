# NecroWorks — AI Handoff

Última atualização: 14/08/2026

## Objetivo deste documento

Este arquivo contém o estado atual do desenvolvimento do Corpse Factory.

Ele deve permitir que outra conversa do ChatGPT continue o desenvolvimento sem depender do histórico de conversas anteriores.

Sempre consultar este arquivo antes de continuar o projeto.

---

## Informações do projeto

Nome provisório: Corpse Factory

Engine: Godot 4.7.1

Linguagem: GDScript

Tipo: 2D

Plataforma inicial: Windows / Steam

Desenvolvimento: solo

Gênero:

- Roguelite
- Autobattler
- Automação
- Estratégia
- Incremental

---

## Conceito

O jogador controla uma operação de necromancia industrial.

Inimigos atacam continuamente.

Quando mortos, seus cadáveres não desaparecem.

Cadáveres são processados e transformados em recursos como:

- Ossos
- Carne
- Sangue
- Almas

Esses recursos permitem produzir novos mortos-vivos, construir máquinas e melhorar a fábrica.

O jogador deve criar combinações e sinergias capazes de produzir builds extremamente poderosas.

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
- baseado mais em sistemas do que em quantidade enorme de assets.

A inspiração de filosofia de design é criar:

"poucas regras simples que geram muitas interações complexas."

Não copiar sistemas, arte ou identidade de outros jogos.

---

## Loop principal

Inimigos aparecem
→ mortos-vivos atacam automaticamente
→ inimigos morrem
→ cadáveres aparecem
→ cadáveres são processados
→ recursos são obtidos
→ novas criaturas são produzidas
→ exército aumenta
→ inimigos ficam mais fortes
→ jogador escolhe upgrades
→ sinergias aparecem
→ boss
→ fim da run

---

## Recursos planejados

### Bones / Ossos

Principal uso:

- esqueletos;
- arqueiros esqueléticos;
- criaturas ósseas;
- máquinas relacionadas a ossos.

### Flesh / Carne

Principal uso:

- zumbis;
- abominações;
- criaturas resistentes.

### Blood / Sangue

Principal uso:

- vampirismo;
- buffs;
- sacrifícios;
- magia sanguínea.

### Souls / Almas

Principal uso:

- fantasmas;
- liches;
- magia;
- efeitos raros.

---

## Arquitetura atual da cena

Main
├── Background
├── Skeleton
└── Enemy

Background:
ColorRect temporário.

Skeleton:
ColorRect branco temporário.

Enemy:
ColorRect vermelho temporário.

Os gráficos atuais são placeholders.

Não produzir arte definitiva nesta fase.

---

## Código atual

Arquivo:

main.gd

Responsabilidades atuais:

- referência ao Skeleton;
- referência ao Enemy;
- movimento automático;
- distância entre unidades;
- cooldown de ataque;
- HP;
- dano;
- morte.

Skeleton e Enemy caminham um em direção ao outro.

Quando entram na distância de ataque:

- param;
- atacam automaticamente;
- perdem HP.

Quando Enemy chega a 0 HP:

- Enemy é removido;
- processamento é interrompido.

---

## Estado atual

FUNCIONANDO:

- [x] Projeto Godot
- [x] Cena Main
- [x] Background
- [x] Skeleton
- [x] Enemy
- [x] Movimento automático
- [x] Distância de combate
- [x] Sistema de HP
- [x] Ataque automático
- [x] Cooldown de ataque
- [x] Morte básica

NÃO IMPLEMENTADO:

- [x] Corpse
- [x] Bones
- [x] Processamento de cadáver
- [x] Criação de Skeleton
- [ ] Spawn de inimigos
- [ ] Ondas
- [ ] Upgrades
- [ ] Sinergias
- [ ] Factory
- [ ] Flesh
- [ ] Blood
- [ ] Souls
- [ ] Boss
- [ ] Meta-progressão

---

## Próxima tarefa

Implementar Enemy Spawner.

Objetivo:

Enemy morre
→ Corpse permanece
→ após pequeno intervalo surge outro Enemy
→ combate continua automaticamente.

---

## Regra de desenvolvimento

NÃO implementar muitos sistemas de uma vez.

Fluxo:

implementar
→ testar
→ corrigir
→ documentar
→ commit
→ próxima funcionalidade.

O objetivo atual é validar o gameplay central antes de produzir arte definitiva.

---

## Próximo milestone

Prototype v0.0.2

Objetivo:

Enemy
→ morte
→ Corpse
→ processar
→ Bones
→ criar novo Skeleton.

Quando esse ciclo estiver funcionando, o primeiro loop econômico do Corpse Factory estará completo.

## Problemas conhecidos

### Node2D migration

A migração de Skeleton e Enemy de ColorRect para Node2D ainda está em andamento.

Comportamento atual:

- Skeleton inicial é exibido corretamente.
- Enemy inicial é exibido corretamente.
- Novo Enemy é instanciado e participa do combate, confirmado pelos logs, porém não é renderizado.
- Novos Skeletons podem ser registrados logicamente mas não aparecer visualmente.
- Sistema de combate permanece funcional nos bastidores.
- Skeleton mantém HP entre inimigos e pode morrer no segundo combate; isso é comportamento esperado atualmente.

Próxima correção:

Garantir visual placeholder via código para todas as unidades instanciadas dinamicamente.
