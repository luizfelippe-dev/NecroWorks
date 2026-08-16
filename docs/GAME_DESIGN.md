# NecroWorks — Game Design

## Identidade

**NecroWorks**  
*Industrial Reanimation Solutions*  
**Waste Nothing. Raise Everything.**

---

## High Concept

NecroWorks é um roguelite 2D com elementos de autobattler, estratégia, automação e progressão incremental.

O jogador administra uma operação de necromancia industrial.

Inimigos derrotados não são apenas obstáculos: seus cadáveres se tornam matéria-prima para a produção de um exército de mortos-vivos.

---

## Fantasia central

**Matar. Reciclar. Reanimar. Escalar.**

O jogador deve sentir que está transformando um campo de batalha em uma linha de produção necromântica cada vez mais eficiente.

A força da run deve vir tanto do tamanho do exército quanto das combinações entre recursos, unidades, upgrades e automação.

---

## Loop principal planejado

Enemy aparece  
→ mortos-vivos atacam automaticamente  
→ Enemy morre  
→ Corpse permanece no campo  
→ jogador processa Corpse  
→ recursos são obtidos  
→ novos mortos-vivos são produzidos  
→ exército cresce  
→ Waves ficam mais difíceis  
→ upgrades são escolhidos  
→ sinergias aparecem  
→ elites e bosses  
→ fim da run.

---

## Pilares de design

### 1. Poucas regras, muitas interações

A profundidade deve surgir principalmente das combinações entre sistemas.

Upgrades isolados devem poder interagir e criar efeitos emergentes.

### 2. Exército descartável

Undead não precisam ser unidades preciosas individualmente.

Perdas fazem parte do loop e devem criar pressão para reciclar, reconstruir e adaptar a produção.

### 3. Cadáver é recurso

Enemy morto não significa apenas progresso.

O cadáver deve ter valor econômico e, futuramente, decisões diferentes de processamento.

### 4. Necromancia industrial

A identidade do projeto não é apenas "invocar mortos-vivos".

O objetivo é construir uma operação de produção, processamento e automação com estética corporativa/industrial macabra.

### 5. Runs fáceis de entender e difíceis de otimizar

A ação básica deve ser clara rapidamente.

A profundidade deve vir de builds, sinergias e decisões de produção.

---

## Recursos planejados

### Bones

Usos principais:

- Skeletons;
- arqueiros esqueléticos;
- criaturas ósseas;
- máquinas relacionadas a ossos.

**Status atual:** implementado como primeiro recurso do protótipo.

### Flesh

Usos planejados:

- Zombies;
- Abominations;
- unidades resistentes.

**Status:** futuro.

### Blood

Usos planejados:

- buffs;
- vampirismo;
- sacrifícios;
- magia sanguínea.

**Status:** futuro.

### Souls

Usos planejados:

- Ghosts;
- Liches;
- magia;
- efeitos raros.

**Status:** futuro.

---

## Unidades planejadas

### Skeleton

Primeira unidade do protótipo.

Função inicial:

- unidade básica;
- custo em Bones;
- combate automático.

**Status:** implementado como placeholder.

### Zombie

Planejado como unidade baseada em Flesh.

### Ghost

Planejado como unidade baseada em Souls.

### Abomination

Planejada como unidade avançada baseada principalmente em Flesh e combinações de recursos.

---

## Estrutura de Waves — direção atual

O próximo milestone do protótipo deverá transformar o spawn infinito de Enemies em Waves limitadas.

Estrutura inicial pretendida:

- contador de Wave;
- quantidade definida de Enemies;
- intervalo curto entre Enemies;
- intervalo maior entre Waves;
- aumento gradual de HP;
- aumento gradual de dano;
- Wave especial/Elite a cada 5 Waves.

Valores exatos ainda serão definidos por playtest.

---

## Upgrades — direção futura

Após Waves, o próximo grande sistema é a escolha de upgrades durante a run.

Direção inicial:

- apresentar 3 opções;
- jogador escolhe 1;
- upgrades modificam unidades, recursos ou regras;
- combinações devem produzir sinergias.

Exemplos conceituais, ainda não implementados:

- mais Bones por Corpse;
- aumento de dano de Skeleton;
- chance de reanimação;
- efeitos quando Skeleton morre;
- efeitos quando Corpse é processado.

---

## Factory — direção futura

Automação necromântica deverá ser um dos diferenciais centrais do projeto.

Possibilidades futuras:

- processamento automático de Corpses;
- máquinas;
- rotas de recursos;
- produção automática de unidades;
- melhorias de eficiência;
- transformação de diferentes matérias-primas.

A Factory não deve ser implementada antes do core loop de combate, Waves e upgrades estar validado.

---

## Boss Corpses — conceito futuro

Bosses poderão gerar cadáveres especiais.

Possíveis decisões mutuamente exclusivas:

- ressuscitar o Boss;
- processar o corpo por recursos raros;
- consumir o corpo para um efeito permanente durante a run.

**Status:** conceito futuro.

---

## Meta-progressão — direção futura

A meta-progressão deve priorizar desbloquear novas possibilidades em vez de apenas conceder aumentos permanentes de atributos.

Possibilidades:

- novas unidades;
- novos upgrades;
- novos personagens;
- novas receitas;
- novas máquinas;
- novas combinações.

---

## Personagens — conceitos futuros

Possíveis arquétipos:

- Bone Lord;
- Blood Queen;
- Surgeon.

Cada personagem poderá favorecer uma estratégia sem impedir outras builds.

---

## Future Concept — Last Stand

Quando todos os Skeletons morrerem, a derrota não precisa necessariamente ser instantânea.

Possível sistema:

- o jogo entra em estado de alerta;
- o jogador recebe alguns segundos para reconstruir o exército;
- Corpses e recursos existentes continuam disponíveis;
- o jogador pode realizar uma reanimação de emergência;
- se não conseguir produzir uma nova unidade antes do tempo acabar, ocorre Game Over.

Possibilidades adicionais:

- botão `Emergency Raise`;
- uma única segunda chance por run;
- sacrificar recursos futuros para sobreviver;
- Enemies continuam avançando durante o alerta;
- upgrades podem modificar o Last Stand.

**Status:** ideia futura. Não implementada e ainda sujeita a testes de balanceamento.

---

## Direção visual

Dark fantasy cartunesco com elementos grotescos e humor corporativo macabro.

Durante o protótipo:

- usar placeholders;
- priorizar leitura e funcionamento;
- não investir ainda em arte definitiva.

---

## Princípio de produção

O projeto deve permanecer viável para desenvolvimento solo.

Evitar sistemas que aumentem muito o escopo antes que o core loop demonstre ser divertido e rejogável.
