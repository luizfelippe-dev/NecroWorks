# NecroWorks

> **Industrial Reanimation Solutions**  
> **Waste Nothing. Raise Everything.**

**NecroWorks** é um roguelite 2D de autobattler, estratégia, economia e automação necromântica desenvolvido em **Godot 4.7.1** com **GDScript**.

## High concept

> **Kill enemies. Recycle the corpses. Turn them into your army.**

Loop central:

```text
Enemy
→ Corpse
→ Processing
→ Resources
→ Undead
→ Army Growth
→ Upgrades
→ Synergies
→ Elites / Boss
→ Victory ou Defeat
```

## Estado atual

### `v0.1.0 — First Run`

Funcionalmente completo e validado:

- combate automático;
- Corpses;
- Bones;
- Skeleton production;
- Waves;
- Elite Waves;
- 10 upgrades;
- 5 sinergias;
- Run Metrics;
- Boss Wave 20;
- The Foreman;
- Victory;
- Defeat;
- Run Summary;
- Restart.

> O status exato da tag Git `v0.1.0` deve ser verificado com `git tag`. A documentação confirma o milestone funcional, não presume que a tag já foi publicada.

### `v0.2.0 — Necromantic Economy`

Funcionalmente completo e validado por duas runs determinísticas até o Foreman:

- resource foundation com Bones, Flesh, Blood e Souls;
- Corpse processado gera Bones + Flesh;
- HUD temporário de Resources;
- Debug oculto por padrão e alternável com `F3`;
- Zombie V1 implementado e testado;
- 4 upgrades exclusivos de Zombie;
- Enemy/Boss atacam Skeletons e Zombies;
- Zombies priorizados na frontline;
- Game Over considera Bones, Flesh, Skeletons, Zombies e Corpses.
- barras de vida em tempo real para aliados, inimigos e Boss.
- grupos de inimigos simultâneos com escalada progressiva;
- Guerreiro Humano, Mago e Elfo com stats e funções distintas;
- faixa segura de combate que não invade o HUD lateral;
- Run Summary final em duas colunas sem sobreposição.
- primeira decisão de Factory: processamento Balanced, Bone Focus ou Flesh Focus.
- Wave 1 usa Balanced; entre Waves, a diretiva da próxima Wave pode ser escolhida gratuitamente e fica travada durante o combate.
- sprites básicos para Skeleton, Zombie, Warrior, Mage, Elf e The Foreman.
- processamento de Corpses com token animado, reação do painel e popup do rendimento real.
- fundação de localização em English, PT-BR e Español aplicada ao primeiro recorte estável da HUD.
- painel inicial de Factory com Pontos de Fábrica, auto-coleta desbloqueável e upgrades de capacidade/velocidade do Corpse Processor.
- produção manual em lote com quantidade digitável, custo total visível e validação atômica de recursos/vagas.
- produção temporizada paralela no Skeleton Assembler e Flesh Vat.
- geração de Blood e Souls por combate, com feedback no HUD.
- painel de Rituais com Blood Fervor, upgrades de Blood/Soul e duas novas sinergias.
- Ghost mágico à distância, produzido com Souls e baseado no primeiro runtime genérico de Undead.
- correção de viewport para preservar toda a interface inferior em janelas mais baixas.

## Economia atual

```text
CORPSE
├── + Bones
└── + Flesh
```

Valores atuais:

```text
Bones per Corpse: 8
Flesh per Corpse: 2

Skeleton Cost: 5 Bones
Zombie Cost: 6 Flesh
```

Blood é consumido por Blood Fervor e seus upgrades; Souls produzem Ghosts e alimentam Spectral Focus/Ethereal Anchor. Normal kills geram Blood em ritmo controlado, enquanto Mage/Elf/Boss são as fontes principais de Souls.

## Undead atuais

### Skeleton

```text
HP: 100
Damage: 10
Attack Cooldown: 0.7 s
Movement Speed: 180
Cost: 5 Bones
Role: DPS / unidade base
```

### Zombie V1

```text
HP: 220
Damage: 6
Attack Cooldown: 1.1 s
Movement Speed: 120
Cost: 6 Flesh
Role: Tank / Frontline
```

O Zombie ainda compartilha a cena-base do Skeleton, mas já possui sprite e identidade visual próprios em runtime.

## Boss atual

### The Foreman

Wave 20.

```text
HP: 2200
Damage: 28
Industrial Crush:
- aproximadamente a cada 4 s
- até 6 Undead
- 35 damage por alvo
```

Derrotá-lo encerra a run com Victory.

## Upgrades atuais

1. Sharpened Bones
2. Bone Plating
3. Efficient Recycling
4. Rapid Assault
5. Death March
6. Mass Production
7. Heavy Bones
8. Bone Harvest
9. Reassembly
10. Final Service
11. Rotten Bulk
12. Grave Hunger
13. Dead Weight
14. Carrion Recovery

Os quatro últimos upgrades formam a primeira identidade própria de Flesh/Zombie:
mais resistência, dano, uma opção de tank pesado com trade-off de velocidade e recuperação de HP ao atacar.

## Synergies atuais

- Recycling Plant
- Second Shift
- Bone Assembly Line
- Overclocked Ossuary
- Meat Shield Protocol

## Direção visual oficial

A referência principal agora é `assets/reference/necrodesignv2.png`. Ela substitui a primeira versão como Visual Target V2 sem exigir uma reconstrução imediata de toda a interface.

Estrutura:

- battlefield central;
- Wave/Boss no topo;
- recursos à esquerda;
- Run Metrics e Active Synergies à direita;
- fábrica/produção na faixa inferior;
- cards de upgrade contextuais na parte inferior;
- máquinas legíveis para Corpse Processing, estoques e montagem de tropas;
- navegação inferior para Facility, Bestiary, Research, Upgrades e Options;
- metal escuro;
- verde necromântico;
- ossos;
- maquinário industrial;
- horror corporativo.

O protótipo já substituiu os quadrados por sprites básicos de todas as unidades atuais. A arte ainda é temporária e sem animação, mas a primeira passagem estrutural também inclui fundo fabril procedural, battlefield separado, faixa de produção, módulos de processamento, painéis de metal escuro, acentos necromânticos e cards contextuais.

## Stack

- Godot 4.7.1 stable
- GDScript
- 2D
- single-player
- Windows primeiro
- Steam como plataforma comercial inicial
- Git + GitHub

## Estrutura do projeto

```text
assets/reference/       concept e referências visuais
assets/sprites/units/   sprites temporários usados pelo runtime
docs/                   design, arquitetura, roadmap e plano comercial
main.tscn / main.gd      entradas estáveis para F5/F6 no Godot
scripts/ui/              componentes reutilizáveis de interface
scripts/game/            políticas de Waves e catálogo de inimigos
scripts/economy/         regras isoladas de processamento e recursos
scripts/factory/         políticas de produção e Doutrina do Exército
scripts/visual/          backdrop e catálogo de sprites
tests/factory/           validação de filas, automação, lotes e Doutrina
tests/visual/            validação persistente dos assets de unidade
```

O protótipo ainda mantém a orquestração principal centralizada, mas novos componentes devem ser extraídos incrementalmente quando houver uma fronteira clara e testável.

## Testes de balanceamento

O runner persistente em `tests/balance/composition_scenario_runner.gd` compara exércitos Skeleton-only, Zombie-heavy e mistos usando o combate real da Wave 8.

Consulte `tests/README.md` para o comando reproduzível e o baseline atual.

## Workflow

```text
implementar
→ testar
→ corrigir
→ documentar
→ commit
→ push
→ próxima funcionalidade
```

Consulte `docs/AI_HANDOFF.md` antes de continuar o desenvolvimento em outro chat.

Auditoria técnica e próximos refactors: `docs/CODE_AUDIT.md`.

O painel de Doutrina do Exército permite salvar composição-alvo, reservas mínimas e prioridade de produção. A reposição pode ser iniciada ou pausada pelo jogador e usa exclusivamente as filas temporizadas independentes do Skeleton Assembler e da Flesh Vat. Pedidos reservam recursos e vagas atomicamente, e cada máquina entrega uma unidade por ciclo.

Próximo foco: validar manualmente o fechamento mecânico da v0.3.0 e iniciar a v0.4.0 com famílias de tropas, receitas desbloqueáveis e maior diversidade de builds.
