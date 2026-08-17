# NecroWorks — Design & Technical Decisions

Este documento registra decisões importantes e os motivos por trás delas.

---

## 14/08/2026 — Engine

**Decisão:** Godot 4.

**Motivo:** foco 2D, desenvolvimento solo e iteração rápida.

---

## 14/08/2026 — Linguagem

**Decisão:** GDScript.

**Motivo:** integração direta com Godot e baixa fricção durante prototipação.

---

## 14/08/2026 — 2D

**Decisão:** primeira versão em 2D.

**Motivo:** controlar custo, prazo e produção de assets.

---

## 14/08/2026 — Single-player

**Decisão:** não incluir multiplayer na primeira versão.

**Motivo:** networking aumentaria muito o escopo e o risco técnico.

---

## 14/08/2026 — Arte de protótipo

**Decisão:** usar placeholders até o core loop estar validado.

**Motivo:** evitar gastar tempo/dinheiro em apresentação antes de provar o jogo.

---

## 14/08/2026 — Core Design

**Decisão:** poucas regras devem gerar muitas combinações.

**Motivo:** replayability sistêmica é mais viável para solo dev do que depender de enorme volume de conteúdo artesanal.

---

## 14/08/2026 — Automação necromântica

**Decisão:** automação será um diferencial central.

**Motivo:** NecroWorks não deve ser apenas um autobattler de Skeletons.

Core:

```text
Enemy → Corpse → Processing → Resources → Production → Undead
```

---

## 16/08/2026 — Rename

**Decisão:** `Corpse Factory` → `NecroWorks`.

**Identidade:**

NecroWorks  
Industrial Reanimation Solutions  
Waste Nothing. Raise Everything.

**Motivo:** o nome anterior já era usado comercialmente e NecroWorks comunica melhor a proposta industrial.

---

## 16/08/2026 — Node2D para unidades

**Decisão:** Skeleton e Enemy usam Node2D.

**Motivo:** são entidades do mundo e precisam de movimentação/posicionamento real.

---

## 16/08/2026 — Placeholder visual via código

**Decisão:** garantir visual temporário programaticamente.

**Motivo:** impedir regressões em que entidades dinâmicas existem mecanicamente, mas não aparecem.

---

## 16/08/2026 — Target-Based Movement

**Decisão:** remover deslocamento global do exército.

**Motivo:** reforços estavam nascendo avançados e a movimentação produzia atravessamentos/comportamentos inconsistentes.

---

## 16/08/2026 — Centralização temporária em `main.gd`

**Decisão:** não criar managers prematuramente.

**Motivo:** velocidade de prototipação.

**Revisão:** após `v0.1.0`, o crescimento do script justifica reavaliar refatoração.

---

## 17/08/2026 — Waves antes de balanceamento definitivo

**Decisão:** validar estrutura de Waves antes de otimizar dificuldade.

**Motivo:** upgrades e sinergias alteram drasticamente a curva de poder e tornariam um balanceamento antecipado descartável.

---

## 17/08/2026 — Economia temporariamente generosa

**Decisão:** manter `bones_per_corpse = 8` e dano base de Enemy reduzido durante prototipação.

**Motivo:** facilitar testes de Waves altas e novos sistemas.

**Status:** valores de desenvolvimento, não valores comerciais finais.

---

## 17/08/2026 — 10 upgrades, 3 escolhas aleatórias

**Decisão:** pool inicial com 10 upgrades e apresentação de 3 opções aleatórias por Wave.

**Motivo:** gerar decisões diferentes entre runs sem exigir grande volume de conteúdo.

---

## 17/08/2026 — Upgrades acumuláveis

**Decisão:** upgrades podem ser escolhidos múltiplas vezes quando não atingiram limite.

**Motivo:** permitir especialização e power fantasy.

---

## 17/08/2026 — Sinergias automáticas

**Decisão:** combinações específicas desbloqueiam efeitos extras automaticamente.

**Motivo:** recompensar descoberta de builds e criar efeitos emergentes.

Primeiras sinergias:

- Overclocked Ossuary;
- Recycling Plant;
- Second Shift;
- Bone Assembly Line.

---

## 17/08/2026 — Métricas antes do balance pass

**Decisão:** coletar estatísticas básicas de run desde o protótipo.

**Motivo:** substituir sensação subjetiva por dados durante balanceamento.

Métricas:

- kills;
- corpses;
- Skeletons construídos;
- Skeletons perdidos;
- revives;
- Bones ganhos.

---

## 17/08/2026 — Boss como encerramento da primeira run

**Decisão:** primeiro protótipo de run será encerrado por Boss na Wave 20.

**Motivo:** criar objetivo claro e testar um ciclo completo antes de ampliar recursos/conteúdo.

---

## 17/08/2026 — Boss deve atacar a horda

**Decisão:** primeiro Boss precisa possuir ameaça multi-target/AOE.

**Motivo:** Enemies atuais atacam um Skeleton por vez e ficam incapazes de pressionar uma horda grande.

---

## 17/08/2026 — Comercialização é parte do produto

**Decisão:** Steam page, demo, wishlists, trailer, capsule art e testes públicos entram no roadmap antes do jogo estar 100% concluído.

**Motivo:** o potencial comercial precisa ser validado antes do lançamento, não apenas depois de terminar o jogo.

---

## 17/08/2026 — Receita não é premissa

**Decisão:** tratar "vender muito" como objetivo, não garantia.

**Motivo:** receita depende de produto, posicionamento, apresentação, mercado, timing e execução. Decisões futuras devem ser orientadas por playtests, wishlists, demo e resposta real do público.

---

## 17/08/2026 — Escopo comercial

**Decisão:** cortar features que não aumentem claramente um destes fatores:

- diversão;
- diferenciação;
- replayability;
- valor percebido;
- capacidade de marketing;
- retenção;
- qualidade técnica.

**Motivo:** terminar um jogo forte é comercialmente melhor do que construir um projeto enorme que nunca fica pronto.
