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

Ao executar o projeto com `F5`, a aplicação agora abre um fluxo completo de entrada com Nova Partida, Continuar, Opções e Sair. `F6` sobre `main.tscn` permanece disponível para testar diretamente o gameplay.

O menu de pausa abre com `Esc`. Idioma, volume geral e tela cheia são persistidos em `user://necroworks_settings.cfg`; o checkpoint versionado de partida usa `user://necroworks_run.json` e restaura onda, recursos, exército, upgrades, Fábrica e Doutrina.

Nova Partida apresenta o primeiro prólogo narrativo localizado. A tela final também está integralmente localizada e oferece Reiniciar ou Voltar ao Menu Principal sem romper o shell da aplicação.

Cinco incidentes narrativos aparecem entre as ondas 4 e 16. As escolhas incluem rotas econômicas, risco permanente e aproveitamento dos restos dos chefes intermediários. Decisões e modificadores são localizados e preservados no checkpoint.

### `v0.4.0 — Build Diversity & Content`

Milestone completo e validado:

- 30 upgrades, incluindo três raros que alteram regras de recompensa e recuperação;
- 10 sinergias;
- seis identidades de tropa entre unidades permanentes e Servos temporários;
- Elites nas ondas 5, 9, 14 e 18;
- Marechal da Sepultura na onda 10, Auditor Arcano na onda 15 e Capataz na onda 20;
- cinco eventos narrativos com escolhas persistentes;
- duas decisões de Cadáver de Chefe;
- Liga de Ossuário e Formação Vinculada no painel de Fusões;
- primeira lore completa com facções, chefes e linha narrativa da run;
- traduções EN, PT-BR e ES para todo o conteúdo novo.

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

### Skeleton Archer V1

```text
HP: 65
Damage: 14
Attack Cooldown: 1.1 s
Movement Speed: 160
Attack Range: 380
Cost: 8 Bones
Unlock: 3 Factory Points
Role: ranged Bone damage / retaguarda
```

O blueprint é adquirido no painel da Fábrica. Depois disso, pedidos de Arqueiro compartilham a Skeleton Assembler com Skeleton Warriors, preservando ordem, custo reservado e capacidade total do exército. A unidade usa sprite próprio e o mesmo runtime genérico, sem novos dicionários de HP/timer/slot.

### Lich Summoner V1

```text
HP: 90
Damage: 11
Attack Cooldown: 1.6 s
Attack Range: 350
Cost: 8 Souls
Unlock: 5 Factory Points
Role: ranged caster / temporary-army support
```

Cada Lich pode consumir 1 Soul para invocar um Servo temporário. A invocação usa cooldown base de 10 s, duração de 15 s e limite global de 6 Servos; eles ocupam vagas normais do exército, mas não contam como Skeletons produzidos/perdidos nem ativam Reassembly/Final Service. Grave Contract, Rapid Conjuration e Bound Servitude especializam o summoner. Soul Foundry fortalece futuras invocações.

Balística do Ossuário completa a décima sinergia atual: o projeto do Arqueiro combinado com Heavy Bones e Death March concede +80 de alcance aos Arqueiros existentes e futuros.

## Pressão inimiga avançada

- Magos usam Rajada Arcana a cada terceiro ataque: até três alvos, 50% de splash e atraso de 0,30 s nos ataques atingidos.
- Elfos usam Tiro de Precisão a cada quarto ataque: priorizam Liches, Ghosts e Arqueiros vulneráveis e causam 135% de dano.
- ambos exibem feedback localizado sobre a unidade inimiga quando a habilidade dispara.

O primeiro upgrade raro/regra-alteradora é Recuperação Emergencial. Ele começa a aparecer a partir da Wave 8 e, uma vez obtido, devolve metade do custo da primeira tropa permanente perdida em cada Wave. Servos temporários não consomem a ativação.

### Variantes Elite

Nas Waves 5, 9, 14 e 18, o bônus de HP/dano é acompanhado por um traço próprio:

- Guerreiro Elite — Baluarte: reduz em 20% o dano recebido;
- Mago Elite — Sobrecarregado: Rajada a cada 2 ataques, 65% de splash e 0,45 s de supressão;
- Elfo Elite — Olho da Morte: Precisão a cada 3 ataques e 150% de dano.

Nome e traço aparecem sobre cada Elite em EN, PT-BR e ES. Ondas de chefe não recebem esses modificadores.

## Chefes atuais

- **Onda 10 — Marechal da Sepultura:** 1050 PV, 18 de dano e golpe especial em até três alvos.
- **Onda 15 — Auditor Arcano:** 1650 PV, 24 de dano e descarga especial em até quatro alvos.
- **Onda 20 — Capataz:** 2200 PV, 28 de dano e Industrial Crush em até seis alvos.

Os dois primeiros liberam escolhas exclusivas sobre seus restos. Derrotar o Capataz encerra a run com vitória.

### Capataz

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

O catálogo possui 30 opções distribuídas entre Esqueletos, Arqueiros, Zumbis, Fantasmas, Liches, economia e produção. Recuperação Emergencial, Dízimo Carmesim e Patente Proibida formam o primeiro conjunto raro. Upgrades comuns têm limite de acúmulo e os especializados só entram no pool quando sua unidade ou momento de run é relevante.

## Sinergias atuais

O catálogo possui 10 sinergias cobrindo processamento, Esqueletos, Zumbis, Blood, Souls, Arqueiros, Liches e Fábrica. O painel lateral usa área própria e permanece dentro do viewport mesmo com todas ativas.

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
scripts/units/           runtime compartilhado das tropas jogáveis
scripts/economy/         regras isoladas de processamento e recursos
scripts/factory/         políticas de produção e Doutrina do Exército
scripts/visual/          backdrop e catálogo de sprites
tests/factory/           validação de filas, automação, lotes e Doutrina
tests/units/             contratos de runtime e receitas de tropas
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

Consulte `docs/PROJECT_STATE.md` para o estado técnico consolidado e `docs/LORE.md` para a base narrativa.

Auditoria técnica e próximos refactors: `docs/CODE_AUDIT.md`.

O painel de Doutrina do Exército permite salvar composição-alvo, reservas mínimas e prioridade de produção. A reposição pode ser iniciada ou pausada pelo jogador e usa exclusivamente as filas temporizadas independentes do Skeleton Assembler e da Flesh Vat. Pedidos reservam recursos e vagas atomicamente, e cada máquina entrega uma unidade por ciclo.

A v0.4.0 formaliza Skeleton Warrior, Skeleton Archer, Zombie Tank, Ghost, Lich e Lich Thrall em um catálogo de receitas e no componente compartilhado `UndeadRuntimeUnit`. HP, tempo de ataque, habilidade, duração temporária e slot são sincronizados pelo runtime; os antigos dicionários permanecem somente como ponte compatível.

Próximo foco: v0.4.1, com modularização incremental de `main.gd`, identidade visual própria para chefes e Cadáveres, contrato de animações, fundo híbrido e primeiro build Windows. A meta progressão da v0.5.0 começa depois dessa consolidação.
