# NecroWorks — Design & Technical Decisions

## 14/08/2026 — Engine

**Decisão:** Godot 4.

**Motivo:** projeto predominantemente 2D, desenvolvimento solo e necessidade de prototipação rápida.

---

## 14/08/2026 — Linguagem

**Decisão:** GDScript.

**Motivo:** integração direta com Godot e menor complexidade inicial.

---

## 14/08/2026 — 2D

**Decisão:** o jogo será inicialmente 2D.

**Motivo:** reduzir custo de desenvolvimento, produção de assets e complexidade técnica.

---

## 14/08/2026 — Single-player

**Decisão:** o primeiro lançamento será single-player.

**Motivo:** networking aumentaria significativamente o escopo do projeto.

---

## 14/08/2026 — Arte durante o protótipo

**Decisão:** não produzir arte definitiva durante o primeiro protótipo.

**Motivo:** validar primeiro o loop, os sistemas e a arquitetura. Skeletons e Enemies permanecem como placeholders enquanto as mecânicas centrais não estiverem consolidadas.

---

## 14/08/2026 — Core Design

**Decisão:** a profundidade deve vir principalmente das interações entre sistemas e upgrades.

**Princípio:** poucas regras devem gerar muitas combinações.

O objetivo não é depender de uma quantidade enorme de conteúdo isolado, mas permitir que recursos, unidades, upgrades e automação criem builds emergentes.

---

## 14/08/2026 — Automação necromântica

**Decisão:** automação necromântica será um dos principais diferenciais de NecroWorks.

O projeto não deverá ser apenas um autobattler.

A transformação industrial dos cadáveres deverá ter papel importante no gameplay:

Enemy → Corpse → processamento → recursos → produção → novos mortos-vivos.

---

## 16/08/2026 — Project Rename

**Decisão:** renomear o projeto de `Corpse Factory` para `NecroWorks`.

**Identidade:**

**NecroWorks**  
*Industrial Reanimation Solutions*  
**Waste Nothing. Raise Everything.**

**Motivo:** o nome anterior já era utilizado por outro jogo comercial. NecroWorks também representa melhor a identidade de necromancia industrial/corporativa do projeto.

---

## 16/08/2026 — Node2D para unidades de combate

**Decisão:** Skeletons e Enemies utilizam `Node2D` como raiz das cenas reutilizáveis.

**Motivo:** são entidades do mundo 2D que precisam de posicionamento e movimentação espacial. A abordagem inicial baseada em `ColorRect` era adequada apenas como placeholder visual e passou a limitar o sistema de movimentação.

---

## 16/08/2026 — Visual provisório garantido por código

**Decisão:** durante o protótipo, o `main.gd` garante um visual simples para unidades instanciadas dinamicamente.

**Motivo:** durante a migração para Node2D, unidades criadas em runtime existiam mecanicamente, mas podiam não ser renderizadas. O placeholder programático evita que configuração visual da cena impeça testes de gameplay.

**Status:** solução temporária. Será substituída quando o pipeline visual definitivo das unidades for criado.

---

## 16/08/2026 — Target-Based Combat Movement

**Decisão:** remover o deslocamento global do exército e utilizar movimentação baseada em alvo.

**Comportamento atual:**

- Skeletons nascem na base.
- Skeletons procuram o Enemy atual.
- Skeletons caminham até posições de combate próximas ao Enemy.
- Enemy procura o Skeleton mais próximo.
- Quando um alvo deixa de existir, ocorre retarget.

**Motivo:** o sistema anterior baseado em deslocamento horizontal global fazia reforços nascerem avançados e permitia situações em que unidades atravessavam umas às outras sem combater.

---

## 16/08/2026 — Manter `main.gd` centralizado durante o protótipo

**Decisão:** não separar BattleManager, WaveManager, ResourceManager e outros managers antes de existir necessidade concreta.

**Motivo:** acelerar a validação do gameplay e evitar overengineering.

A refatoração será feita quando a complexidade do protótipo justificar a separação de responsabilidades.
