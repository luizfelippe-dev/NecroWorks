# NecroWorks — Game Design Document

## Identidade

**NecroWorks**  
*Industrial Reanimation Solutions*  
**Waste Nothing. Raise Everything.**

---

# High Concept

NecroWorks é um roguelite 2D de autobattler, estratégia, automação e progressão incremental.

O jogador administra uma operação de necromancia industrial em que inimigos derrotados se tornam matéria-prima.

A promessa do jogo é simples:

> **o inimigo que tentou destruir sua fábrica pode terminar trabalhando para ela.**

---

# Fantasia central

**Matar. Reciclar. Reanimar. Automatizar. Escalar.**

A run deve começar com uma operação pequena e terminar, quando a build funciona, em uma máquina necromântica absurda.

A sensação desejada é:

```text
1 Skeleton
→ pequena sobrevivência
→ processamento de Corpses
→ novos Skeletons
→ upgrades
→ automação
→ sinergias
→ horda
→ fábrica necromântica fora de controle
```

---

# Pilares

## 1. Poucas regras, muitas interações

A profundidade deve vir principalmente de combinações.

Um upgrade deve ser interessante sozinho e mais interessante quando combinado com outros.

## 2. Cadáver é economia

Corpse não é decoração.

Corpse deve representar:

- recurso;
- escolha;
- combustível;
- produção;
- potencial de automação.

## 3. Exército descartável

Perder Undead faz parte do loop.

O jogador deve poder transformar perdas em novos efeitos e oportunidades.

## 4. Necromancia industrial

O jogo não deve parecer somente "um jogo de esqueletos".

A identidade precisa misturar:

- dark fantasy;
- fábrica;
- produtividade;
- processamento;
- eficiência;
- humor corporativo macabro.

## 5. Power fantasy crescente

Runs boas devem permitir estados exagerados.

A força não deve vir apenas de números maiores, mas de sistemas que passam a alimentar outros sistemas.

## 6. Legibilidade

Mesmo quando dezenas de unidades estiverem na tela, o jogador precisa entender:

- o que está acontecendo;
- o que ganhou;
- qual sinergia ativou;
- por que a build ficou forte;
- por que perdeu.

## 7. Comercialmente demonstrável

O conceito precisa ser compreensível em segundos em:

- GIF;
- vídeo curto;
- trailer;
- screenshot;
- stream.

A transformação de cadáveres em produção de mortos-vivos deve ser visualmente central.

---

# Loop atual

```text
Wave inicia
→ Enemy aparece
→ Undead atacam automaticamente
→ Enemy morre
→ Corpse aparece
→ Corpse é processado
→ Bones são obtidos
→ Skeleton é produzido
→ Wave continua
→ Wave termina
→ 3 upgrades são apresentados
→ jogador escolhe 1
→ sinergias podem desbloquear
→ próxima Wave
```

---

# Recursos

## Bones — implementado

Atual:

- Corpse gera Bones;
- Skeleton custa Bones;
- upgrades alteram geração/custo;
- sinergias podem automatizar produção.

Futuro:

- Skeleton Archer;
- Bone Golem;
- estruturas de osso;
- máquinas ósseas.

## Flesh — planejado

Direção:

- Zombie;
- Abomination;
- HP alto;
- regeneração;
- produção de massa biológica.

## Blood — planejado

Direção:

- buffs temporários;
- sacrifícios;
- vampirismo;
- multiplicadores de dano;
- decisões de risco/recompensa.

## Souls — planejado

Direção:

- Ghost;
- Lich;
- magia;
- efeitos raros;
- upgrades de alta qualidade;
- automações sobrenaturais.

---

# Unidades

## Skeleton — implementado

Função atual:

- unidade básica;
- custa Bones;
- combate automático;
- recebe todos os upgrades atuais.

## Zombie — planejado

Direção:

- lento;
- resistente;
- baseado em Flesh;
- bom para segurar pressão.

## Ghost — planejado

Direção:

- baseado em Souls;
- ataque especial/range;
- interações mágicas.

## Abomination — planejado

Direção:

- unidade avançada;
- combinação de recursos;
- alta presença visual;
- produto "premium" da fábrica.

---

# Waves — implementado

Sistema atual:

- Wave counter;
- quantidade crescente de Enemies;
- HP scaling;
- Damage scaling;
- 0.5 s entre Enemies;
- Elite a cada 5 Waves;
- escolha de upgrade após conclusão.

Estado de balanceamento:

**provisório.**

A economia atualmente supera a ameaça cedo demais.

Balanceamento profundo será feito após a primeira run completa e ampliação dos sistemas.

---

# Upgrades — implementados

| Upgrade | Categoria | Efeito atual |
|---|---|---|
| Sharpened Bones | Offense | +25% Damage |
| Bone Plating | Defense | +25 Max HP |
| Efficient Recycling | Economy | +2 Bones/Corpse |
| Rapid Assault | Offense | +15% Attack Speed |
| Death March | Mobility | +20% Movement Speed |
| Mass Production | Economy | -1 Skeleton Cost |
| Heavy Bones | Tradeoff | +50% Damage, -20% Attack Speed |
| Bone Harvest | Economy | chance de Bones extras |
| Reassembly | Survival | chance de revive |
| Final Service | Death | dano ao morrer |

Direção futura:

- aumentar pool gradualmente;
- criar raridades;
- adicionar upgrades específicos por recurso/unidade;
- evitar upgrades puramente numéricos demais;
- criar efeitos que mudam regras.

---

# Sinergias — implementadas

## Overclocked Ossuary

**Heavy Bones + Rapid Assault**

Ataques ganham chance de Double Strike.

Objetivo de design:
compensar o peso de Heavy Bones com automação agressiva.

## Recycling Plant

**Efficient Recycling + Bone Harvest**

Bone Harvest recebe bônus dobrado.

Objetivo:
build de economia explosiva.

## Second Shift

**Reassembly + Final Service**

Skeleton que revive ainda causa parte do dano de Final Service.

Objetivo:
fazer morte/revive virar motor ofensivo.

## Bone Assembly Line

**Mass Production + Efficient Recycling**

Processar Corpse pode produzir Skeleton automaticamente.

Objetivo:
primeiro exemplo real de linha de produção necromântica.

---

# Bosses

## Primeiro Boss planejado — The Foreman

Wave alvo do primeiro protótipo: **20**.

Objetivos do Boss:

- ser visualmente diferente de Elite;
- testar a horda, não apenas um único Skeleton;
- possuir HP significativamente maior;
- possuir ataque em área/multi-target;
- encerrar a primeira run.

Direção:

```text
WAVE 20 — BOSS
THE FOREMAN

→ ataques normais
→ golpe industrial periódico
→ dano em múltiplos Skeletons
→ morte do Boss
→ Victory
→ Run Summary
```

O nome e números são provisórios.

---

# End of Run

## Victory

Primeiro objetivo:

- derrotar Boss da Wave 20;
- exibir resumo;
- permitir Restart.

## Defeat

A derrota ainda precisa ser definida tecnicamente.

Direção simples para `v0.1.0`:

- se não houver Skeletons e não houver forma viável de reconstrução, entrar em Game Over.

Mais tarde pode evoluir para Last Stand.

---

# Future Concept — Last Stand

Quando todos os Skeletons morrerem, a derrota não precisa necessariamente ser instantânea.

Possível sistema:

- alerta;
- janela curta para reconstrução;
- Corpses e recursos continuam utilizáveis;
- Emergency Raise;
- uma segunda chance por run;
- sacrifício de recursos futuros;
- upgrades específicos.

Status:
**conceito futuro, não implementado.**

---

# Factory — diferencial central futuro

A Factory deve transformar a economia manual atual em sistema industrial.

Possibilidades:

- processamento automático;
- máquinas;
- esteiras/rotas;
- filas de produção;
- produção automática;
- máquinas que convertem um recurso em outro;
- eficiência;
- overload;
- mutações;
- cadeias de produção.

Princípio:

> a Factory precisa criar decisões, não apenas remover cliques.

---

# Boss Corpses — conceito futuro

Boss pode deixar Corpse especial.

Possíveis decisões mutuamente exclusivas:

1. Ressuscitar o Boss.
2. Processar por recurso raro.
3. Consumir para efeito permanente na run.

---

# Meta-progressão

Prioridade:
**desbloquear possibilidades, não apenas stats permanentes.**

Exemplos:

- novos Undead;
- novos upgrades;
- novos personagens;
- novas máquinas;
- novas receitas;
- novos eventos;
- novas linhas de produção.

Evitar transformar o jogo em grind obrigatório para ficar forte.

---

# Personagens / operadores

Conceitos:

- Bone Lord;
- Blood Queen;
- Surgeon.

Cada um deve orientar builds sem impedir experimentação.

---

# Estrutura alvo de uma run

Versão comercial ainda será validada, mas direção inicial:

```text
Early Game
→ sobrevivência + economia

Mid Game
→ definição de build + primeiras sinergias

Late Game
→ automação + horda + ameaças especiais

Boss
→ teste final da operação

Run Summary
```

Tempo alvo futuro:
aproximadamente 20–30 minutos, sujeito a playtest.

---

# Direção visual

Dark fantasy cartunesco + horror corporativo/industrial.

Necessidades futuras:

- silhuetas muito legíveis;
- Corpses visualmente satisfatórios;
- máquinas com animações claras;
- feedback forte de processamento;
- números/popups sem poluir;
- Elite e Boss imediatamente reconhecíveis;
- momentos "clipáveis" quando uma sinergia explode a produção.

Durante o protótipo:
placeholders continuam corretos.

---

# Princípio comercial de design

O objetivo comercial é aumentar a probabilidade de sucesso, não assumir sucesso.

NecroWorks deve buscar:

- hook fácil de explicar;
- diferença visual clara;
- replayability;
- builds compartilháveis;
- demo forte;
- bom trailer;
- boa cápsula de Steam;
- feedback público antes do lançamento;
- escopo que um desenvolvedor solo consiga terminar.
