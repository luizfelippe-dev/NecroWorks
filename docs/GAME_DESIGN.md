# NecroWorks — Game Design Document

## High Concept

**Kill enemies. Recycle the corpses. Turn them into your army.**

NecroWorks é um roguelite 2D que combina:

- autobattler;
- estratégia;
- economia;
- automação;
- buildcrafting;
- progressão incremental.

## Fantasia

O jogador administra uma empresa necromântica industrial.

O campo de batalha é simultaneamente:

- zona de combate;
- fonte de matéria-prima;
- chão de fábrica.

O inimigo derrotado deixa de ser ameaça e passa a ser estoque.

## Pilares

### Cadáver é recurso

Corpse deve importar economicamente.

### Exército descartável

Perder Undead faz parte da estratégia.

### Industrial Necromancy

O diferencial não é somente "ter esqueletos": é criar uma linha de produção de mortos-vivos.

### Builds emergentes

Poucos sistemas precisam interagir de muitas maneiras.

### Power fantasy

Runs fortes podem ficar exageradas e visualmente satisfatórias.

### Legibilidade

O jogador precisa entender por que sua build funciona ou falha.

## First Run — implementado

```text
Wave 1
→ Corpse
→ Bones
→ Skeleton
→ Upgrades
→ Synergies
→ Elites
→ Wave 20
→ The Foreman
→ Victory / Defeat
→ Run Summary
→ Restart
```

## Recursos

### Bones — implementado

Uso atual:
Skeleton.

### Flesh — próxima fase

Uso principal planejado:
Zombie e unidades carnais.

Identidade:
HP, massa, regeneração, frontline.

### Blood — planejado

Uso:
sacrifício, buffs, vampirismo, multiplicadores temporários.

### Souls — planejado

Uso:
Ghosts, magia, efeitos raros e automação sobrenatural.

## Undead

### Skeleton — implementado

- barato;
- simples;
- ofensivo;
- base da economia atual.

### Zombie — próximo

Direção:

- custo em Flesh;
- mais HP que Skeleton;
- mais lento;
- menor dano;
- frontline/tank.

### Ghost — planejado

- Soul;
- ranged/magic;
- mais raro.

### Abomination — planejado

- mistura de recursos;
- unidade avançada;
- alto valor visual.

## Upgrades atuais

10 upgrades, 3 escolhas por Wave.

A direção futura é migrar progressivamente de bônus numéricos para efeitos que alteram regras.

## Synergies atuais

- Recycling Plant;
- Second Shift;
- Bone Assembly Line;
- Overclocked Ossuary.

Sinergias devem ser descobertas e produzir momentos de build memoráveis.

## Boss

### The Foreman — implementado

Wave 20.

- 2200 HP;
- 28 Damage;
- ataque normal;
- Industrial Crush;
- multi-target;
- encerra a run.

## Defeat

A run termina quando não existe:

- Skeleton vivo;
- Corpse processável;
- Bones suficientes para reconstruir.

### Last Stand — futuro

Pode substituir/expandir essa condição depois:

- janela curta;
- emergency raise;
- sacrifícios;
- recuperação dramática.

## Factory — futuro central

A Factory deve transformar processamento manual em cadeia industrial.

Possibilidades:

- Corpse Processor;
- Skeleton Assembler;
- Flesh Vat;
- Soul Extractor;
- Blood Pump;
- conveyor/route abstraction;
- efficiency;
- overload;
- auto-production.

A Factory deve gerar decisões, não apenas automatizar cliques.

## Direção visual oficial

Target visual próprio:

- battle arena central;
- arquitetura industrial ao redor;
- production floor na parte inferior;
- HUD dividido em módulos;
- recursos à esquerda;
- sinergias/métricas à direita;
- Wave/Boss no topo;
- cards contextuais;
- metal escuro;
- verde necromântico;
- ossos;
- iluminação industrial;
- horror corporativo cartunesco.

Não é necessário reproduzir tudo imediatamente. Novas telas/sistemas devem, porém, respeitar essa hierarquia.

## Comercial

NecroWorks precisa ser explicável visualmente em segundos:

```text
Enemy dies
→ Corpse enters production
→ resources appear
→ Undead is manufactured
→ army grows
→ factory accelerates
```

O objetivo é criar momentos fáceis de mostrar em trailer, GIF e vídeo curto.
