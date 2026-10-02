# NecroWorks — Roadmap

**Atualizado:** 02/10/2026

---

# Ordem imediata de execução

## Revisão de experiência — 01/10/2026

Revisão visual de 02/10: máquinas frontalizadas passam ao monitor recolhível da HUD, não ao chão em perspectiva. Carcaça ilustrada da refinaria integrada. Piloto do esqueleto guerreiro: marcha com 8 quadros e impacto existente + 3 recuperações; não encerra o item de animação aprovada. Antecipação, revisão de naturalidade e migração das demais famílias permanecem pendentes.

Avanço de 02/10 (trajeto): essência arcana e confirmação de saída de Sangue/Almas integradas ao ciclo real. Acabamento ilustrado e avaliação em movimento numa run humana continuam pendentes; os registros abaixo descrevem cortes anteriores.

Avanço adicional de 02/10: Sangue/Almas possuem indicadores procedurais ligados ao progresso real. A expansão visual permanece aberta: acabamento ilustrado, transferência arcana e confirmação da saída ainda faltam. Não considerar esses medidores equivalentes à máquina final.

Avanço de 02/10: montagem óssea (guerreiro/arqueiro) e cuba de zumbis representadas em cena com progresso real, acessibilidade e confirmação da produção. O item de expansão abaixo permanece aberto para Sangue e Almas; avaliação de legibilidade em movimento ainda necessária.

A base funcional ainda não entrega o impacto visual nem a variedade desejados. A meta não é alongar a run artificialmente: cada etapa precisa trazer uma ameaça, decisão ou transformação perceptível. A ordem abaixo detalha os itens já abertos de apresentação e repetição.

1. **Fábrica palpável:** [x] ligar restos às poses de morte; [x] mostrar entrada, prensa e saída sincronizadas com a fila de materiais; [x] animar transferência visual sem duplicar o corpo no campo; [ ] estender a linguagem a Sangue, Almas e montagem de tropas; [ ] validar legibilidade em movimento. Transferência integrada em 02/10: somente a cabeça da fila viaja, sem alterar o tempo de processamento. A prensa V1 é um corte inicial, não toda a fábrica finalizada.
2. **Uma família de animação aprovada:** [ ] produzir caminhada com contatos alternados dos pés e ataque com antecipação/contato/recuperação; [ ] comparar em vídeo a velocidade normal antes de replicar para as onze famílias. Poses deformadas não encerram este item.
3. **Três setores da planta:** [ ] pátio de recepção, fundição e núcleo espectral com arte e som próprios; [ ] transições nos intervalos; [ ] uma regra de encontro por setor anunciada antes do combate. Trocar apenas a cor do mesmo fundo não conta como cenário novo.
4. **Decisões que mudam a run:** [ ] prototipar contratos opcionais de produção sob pressão e rotas de recompensa; [ ] dar função diferente às composições; [ ] comparar com a run atual antes de ampliar catálogo. Hipótese: a fábrica deve ser uma ferramenta tática, não apenas um menu de compras.
5. **Motivo para voltar:** [ ] desafios/condições de vitória alternativos e dificuldade progressiva após a primeira vitória; [ ] recompensas horizontais, sem exigir repetição vazia; [ ] observar retorno voluntário de jogadores novos. Não transformar duração ou número de conquistas em substituto de diversão.

Critério de avanço: uma pequena fatia precisa ser convincente em vídeo e jogável por pessoas externas antes de produzir cenários, tropas e upgrades em massa. Não há promessa de popularidade ou vendas embutida nesses marcos.

## Sequência técnica vigente

1. fechar a confiabilidade da pausa, do isolamento dos testes e da retomada;
2. melhorar preparação entre ondas, tutorial e leitura das decisões;
3. aprovar uma família de animação autoral e o feedback de combate antes de ampliar a produção visual;
4. diferenciar chefes, revisar cartas e preservar composições na automação;
5. validar builds, executável renderizado e compreensão com pessoas novas;
6. preparar demo e presença Steam com evidências de qualidade e interesse.

A auditoria de 14/09 reabre os critérios abaixo. Os marcos antigos registram implementação histórica, não aprovação comercial. Testes matemáticos de resolução, processamento parcial de CPU e vitórias de bots não comprovam legibilidade, FPS real ou balanceamento. A expansão do catálogo fica suspensa durante esta consolidação.

## v0.6.3 — Confiabilidade pós-auditoria (implementação técnica concluída; unreleased)

- [x] tornar o gameplay explicitamente pausável sem bloquear os menus do shell;
- [x] interromper temporizadores de reposição inimiga e aviso de desbloqueio durante pausa;
- [x] testar avanço real de frames na pausa/tutorial e retomada, além do booleano da árvore;
- [x] isolar checkpoints dos runners de shell/tutorial e limpar seus backups;
- [x] fazer o botão Continuar respeitar o caminho injetado de checkpoint;
- [x] validar semanticamente evento narrativo pendente, inclusive evento já escolhido, e recuperar checkpoint inválido sem softlock;
  - regressão cobre ID desconhecido, escolha incompatível, tipos incorretos, backup válido e ausência de backup; restauração direta rejeita narrativa inválida antes de remover unidades;
- [x] ampliar validação defensiva dos subcampos de fábrica, rituais, doutrina e modificadores;
  - níveis/flags, reservas, capacidade combinada, prioridade, pressão de facção e IDs do loadout validados; campos opcionais ausentes preservam defaults legados;
- [x] informar perfil recuperado, incompatível ou protegido, falhas de progressão e autosave; preservar arquivos originais;
  - painel localizado com confirmação e nova tentativa; falhas durante a run pausam o gameplay; histórico de fim de run permanece em memória até nova gravação;
- [x] persistir métricas de processamento por rota, com compatibilidade para checkpoints anteriores;
  - `processing_routes` opcional no schema v2; totais antigos sem distribuição ficam como rota não registrada, sem inventar escolhas;
- [x] acrescentar regressões de isolamento, corrupção semântica, falha de gravação e retomada para cada correção;
- [x] consolidar HUD duplicado e evitar atualização de debug oculto, medindo antes/depois;
  - [x] impedir montagem de texto e análise de recuperação quando o debug está oculto, com regressão de atualização ao exibir;
  - [x] remover labels e formatadores legados; comparar cenário renderizado local antes/depois em `RENDERED_PROFILING.md`, sem extrapolar para hardware mínimo;
- [x] reduzir acoplamento do controlador por extrações pequenas ligadas às correções, sem reescrita geral;
  - apresentação de produção, processamento e filas extraída para funções puras com snapshots explícitos; regressão de custos, lotes, bloqueios e três idiomas. A execução das compras permanece nas políticas existentes.

**Aceite:** pausa congela relógio, unidades, produção e reposição; menus continuam utilizáveis. Nenhum runner grava no save pessoal. Retomadas válidas preservam estado e as inválidas oferecem recuperação segura. Erros de persistência são visíveis.

## v0.6.4 — Ritmo, interface e aprendizagem

- [x] criar preparação entre ondas: carta/evento, ajustes da fábrica e comando explícito para iniciar;
- [x] definir se filas avançam na preparação e comunicar essa regra, evitando espera explorável;
  - da seleção da carta até o comando de início, relógio da run, processamento, produção e automações congelam; ordens podem ser configuradas e retomam somente no combate;
- [x] anunciar próxima ameaça para permitir planejamento;
  - painel mostra família principal, composição presente, PV, dano, total da onda e limite simultâneo; chefes usam o perfil próprio;
- [x] ensinar cadáver → processamento → recurso → tropa por ações, substituindo páginas iniciais extensas;
  - introdução continua como contexto resumido; guia contextual acompanha cinco ações reais, pode ser dispensado e não reaparece após conclusão;
- [x] corrigir tutorial: chefes nas ondas 10, 15 e 20, não a cada dez ondas;
- [ ] medir tempo até primeira decisão interessante e antecipar amostra de inimigo especial/build/automação;
  - instrumentação local opcional `--measure-run` registra primeiras mudanças e ociosidade; medição com jogadores e alteração do ritmo inicial continuam pendentes;
- [ ] priorizar capacidade, filas, gargalos, composição e ameaças no HUD; recolher métricas históricas;
  - [x] diagnóstico operacional aponta capacidade cheia, cadáver aguardando, filas saturadas, material pronto ou máquina trabalhando sem alterar a simulação;
  - [ ] consolidar composição e ameaça com histórico de perdas/ociosidade medido em runs reais;
  - painel operacional assume a área principal com capacidade, unidades enfileiradas, seis papéis de tropa, coleta e extração; histórico disponível por botão. Medição temporal de perdas/ociosidade permanece pendente;
- [ ] permitir escala legível de interface e validar 720p, textos longos e três idiomas;
  - escala de textos táticos 100/115/130% persistida nas Opções, painéis roláveis e cartas validados em 720p; ampliação de toda a interface ainda não foi implementada;
- [x] exibir requisitos, efeito e progresso das sinergias, com consulta durante a partida;
  - catálogo rolável ordena sinergias ativas, prontas e mais próximas; cada entrada identifica efeito e componentes concluídos/pendentes nos três idiomas;
  - cartas antecipam a combinação mais próxima que a escolha avança ou ativa; progresso exibido em fração e ordenado proporcionalmente;
- [x] tornar visível o fluxo cadáver → máquina → recurso → tropa;
  - objetivo contextual acompanha o cadáver clicável, aguarda a conversão, aponta a linha inferior e conclui somente quando a unidade entra no exército;
- [x] avaliar consolidar Fusões na fábrica/rituais ou justificar o painel com um resultado exclusivo.
  - Fusões permanece como conversão cruzada: Liga do Ossuário transforma Ossos+Carne em Pontos de Fábrica; Reunião Vinculada troca Sangue+Almas por um Fantasma. A primeira receita oferece saída exclusiva para investimento industrial;

**Aceite:** jogadores novos completam o ciclo sem instrução verbal, entendem uma sinergia e ajustam a fábrica antes do combate. Medir confusão e tempo de decisão, sem usar apenas screenshots como aprovação.

## v0.6.5 — Combate, apresentação e narrativa

- [ ] produzir e aprovar uma família com caminhada e ataque autorais: apoio dos pés, antecipação, contato, recuperação e dano sincronizado;
- [ ] expandir o padrão aprovado às onze famílias, sem tratar deformação de pose ou quadros duplicados como animação final;
- [ ] verificar leitura de impacto/morte e movimento reduzido em vídeo a velocidade normal;
- [ ] dar mecânica e resposta próprias a Marechal, Auditor e Capataz, com avisos legíveis e perda explicável;
  - seleção por proximidade, retaguarda e agrupamento implementada em 23/09, com aviso mínimo de um segundo; validar contrajogo e perdas em partidas humanas antes de fechar o item;
- [ ] produzir identidade sonora de máquinas, materiais e famílias e ambiente com variação de tensão;
- [ ] proteger prioridade de alertas de chefe no pool de áudio e validar mixagem em sessão real;
  - voz SFX exclusiva protege o alerta contra roubo pelos dez canais comuns; regressão cobre saturação por 30 efeitos; mixagem subjetiva permanece pendente;
- [x] antecipar a revelação do Diretor/Livro-Negro e entregar desfecho breve coerente após o Capataz;
  - assinatura anterior ao despertar no sabotador; identidade coletiva no Arcanista; ordem de eliminação no Auditor; epílogo na vitória com variante do núcleo;
- [x] criar consequências reconhecíveis entre eventos, sem exigir grandes blocos de exposição;
  - Marechal reconhece exposição/suborno do sabotador; Auditor reconhece a extração do Arcanista. Recompensas e schema preservados. Compreensão e impacto narrativo ainda dependem de playtest.

**Aceite:** combate convincente em movimento, chefes exigem respostas diferentes, áudio informa ações e o arco central tem conclusão dentro do jogo. Revisão de direitos acompanha cada asset.

## v0.6.6 — Estratégia, repetição e validação do produto

- [ ] eliminar escolhas dominadas, começando por Stitched Hide (+30 PV) versus Rotten Bulk (+40 PV e sinergia);
- [ ] revisar redundâncias de atributos e priorizar cartas que mudem comportamento;
- [ ] avaliar ofertas com opção compatível com a build e alternativas de transição, sem retirar toda a incerteza;
- [ ] automatizar metas por receita/papel, distinguindo arqueiros, guerreiros e servos temporários;
- [ ] incluir tropas avançadas no planejamento com reservas, capacidade e prioridades explícitas;
- [ ] variar encontros e contratos por regras significativas, mantendo ameaças anunciadas e dificuldade justa;
- [ ] comparar builds com custo/progressão equivalentes, várias seeds, atrasos humanos de coleta e escolhas orientadas versus aleatórias;
- [ ] medir perdas por chefe, recursos ociosos, gargalos e causas de derrota; não classificar vitória de bot como balanceamento aprovado;
- [ ] medir frames renderizados, percentis de tempo, memória, áudio e shaders no export;
- [ ] testar instalação limpa, sessões longas, saves, escala Windows e hardware mínimo/recomendado;
- [ ] testar interface instanciada em resoluções reais, além da matemática de escala;
- [ ] conduzir rodada cega inicial de 5–10 pessoas e nova rodada após correções, observando compreensão e repetição voluntária;
- [ ] revisar PT-BR/EN/ES com leitores nativos e avaliar remapeamento/navegação conforme dispositivos suportados.

**Aceite:** estratégias distintas viáveis dentro de investimentos comparáveis, escolhas compreensíveis e evidência externa de vontade de repetir. Definir requisitos de hardware somente após medição real.

## Entrada na v0.7.0 — Condições comerciais

- [ ] congelar demo curta representativa com diferencial apresentado cedo e um clímax;
- [ ] posicionar o jogo para fãs de roguelite/autobattler/produção e validar a promessa com gameplay;
- [ ] fechar proveniência, licenças, créditos e declaração correta de conteúdo gerado com IA;
- [ ] preparar página, cápsula, trailer e screenshots representativos; não usar capturas de debug como evidência de balanceamento;
- [ ] avaliar preço por qualidade, duração, repetição e comparáveis atuais, sem depender apenas de ser barato;
- [ ] coletar sinais de interesse, wishlists e feedback de demo; não prometer conversão nem hype;
- [ ] preparar Steam Playtest, clipes e contato com criadores do nicho;
- [ ] escolher Next Fest quando a demo estiver pronta, considerando a participação única por título.

O checklist detalhado da v0.7.0 abaixo continua válido. Estes critérios são pré-requisitos, não uma autorização para publicação automática.

---

# v0.1.0 — First Run

## Status: functional milestone complete

- [x] Combat
- [x] Corpse Loop
- [x] Bones
- [x] Skeleton Production
- [x] Waves
- [x] Elite Waves
- [x] 10 Upgrades
- [x] Random upgrade selection
- [x] 4 Synergies
- [x] Run Metrics
- [x] The Foreman
- [x] Boss AOE
- [x] Boss movement fix
- [x] Victory
- [x] Defeat
- [x] Run Summary
- [x] Restart
- [x] Full run validation

### Git

- [x] tag `v0.1.0` presente localmente e em `origin`

---

# v0.2.0 — Necromantic Economy

## Phase A — Resource Foundation

- [x] Bones state
- [x] Flesh state
- [x] Blood state
- [x] Souls state
- [x] temporary Resource HUD
- [x] Flesh generated by Corpse
- [x] compact F3 Debug HUD
- [x] Skeleton compatibility preserved

## Phase B — Flesh / Zombie

- [x] Zombie V1
- [x] Zombie production
- [x] Zombie HP
- [x] Zombie attacks
- [x] Zombie movement
- [x] Zombie frontline priority
- [x] Enemy targets mixed Undead
- [x] Boss targets mixed Undead
- [x] Game Over supports Zombie recovery
- [x] Run Metrics support Zombie

### Next

- [x] Zombie-specific upgrades
- [x] runtime health bars
- [x] initial professional folder organization
- [x] first Flesh synergy — Meat Shield Protocol
- [x] independent runtime state and health bars for simultaneous Enemies
- [x] staged active-Enemy escalation beginning on Wave 6
- [x] Wave 20 Boss preserved as a single target
- [x] first living Enemy archetypes: Human Warrior, Mage and Elf
- [x] per-Enemy HP, damage, speed, range and cooldown
- [x] progressive archetype introduction on Waves 1, 8 and 11
- [x] right HUD combat-safe boundary
- [x] two-column Run Summary layout
- [x] F5 main-scene UID repaired and synchronized
- [x] establish deterministic Skeleton/Zombie/mixed Wave 8 baseline
- [x] confirm distinct damage, durability and mixed-army outcomes
- [x] turn Corpse output into a real Bone/Flesh routing decision
- [x] lock the selected processing route for each Wave
- [x] replace square combat placeholders with basic unit sprites
- [x] expose base Skeleton/Enemy sprites in editable scenes
- [x] playtest active-Enemy caps against Skeleton-only, Zombie-heavy and mixed builds
- [x] capture a short milestone clip for the second LinkedIn dev update
- [x] decide Flesh resource pacing
- [x] begin generic Undead refactor only where needed

## Phase C — Blood

- [x] define first Blood sink
- [x] Blood generation
- [x] Blood UI feedback
- [x] sacrifice/buff prototype
- [x] Blood upgrades
- [x] Blood synergy

## Phase D — Souls / Ghost

- [x] Souls generation
- [x] Ghost scene
- [x] Ghost production
- [x] ranged/magic combat
- [x] Soul upgrades
- [x] Soul synergy

## Phase E — Economy / Combat Balance

- [x] Bones income
- [x] Flesh income
- [x] unit costs
- [x] Skeleton DPS
- [x] Zombie tankiness
- [x] Enemy HP/Damage
- [x] Wave size
- [x] Elite pressure
- [x] Foreman pressure
- [x] upgrade stacking
- [x] resource sinks

### Gate for v0.2.0

Two runs should produce meaningfully different armies/builds.

Health, damage and resource changes must also remain readable without opening Debug.

**Gate completed:** deterministic full runs reached and defeated the Foreman with both Bone/Skeleton and Flesh/Zombie strategies. Blood/Soul resources, Ghosts and all resource totals remain visible in the standard HUD and Ritual panel.

---

# v0.3.0 — Factory / Automation

- [x] visible Corpse processing feedback: movement, machine reaction, yield popup and sound hook
- [x] Corpse Processor queue
- [x] automatic Corpse collection unlock/toggle
- [x] processing throughput and queue capacity
- [x] processing directive: Bone / Flesh / Balanced
- [x] focused modes preserve emergency rebuild viability
- [x] free between-Wave selection with in-Wave commitment
- [x] localization foundation before adding more large UI panels
- [x] PT-BR, English and Spanish translation resources
- [x] Factory panel shell opened by a dedicated button
- [x] run-scoped Factory upgrade model and currency prototype
- [x] Corpse Processor upgrade branch
- [x] Skeleton Assembler production queue
- [x] Flesh Vat production queue
- [x] manual bulk order with stepper/quantity control
- [x] Army Doctrine target-composition planning model
- [x] automatic replenishment toward target composition
- [x] priority and minimum-resource-reserve policy model
- [x] execute priority/reserve policy through timed production queues
- [x] automation pause/disable controls
- [x] Blood production machine
- [x] Soul extraction machine
- [x] resource routing
- [x] efficiency
- [x] factory synergies

### Gate

NecroWorks must feel like a necromantic factory, not only an autobattler.

**Mechanical gate completed:** Corpses and rare resources now move through visible timed queues, Army Doctrine maintains target composition, and six Factory cards provide collection, throughput, conversion, routing and efficiency decisions. Manual balance/presentation validation remains before the milestone tag.

---

# v0.4.0 — Build Diversity & Content

- [x] generic Undead runtime record/component before the third player unit family
- [x] Skeleton Warrior formalized as the base Bone melee recipe
- [x] Skeleton Archer ranged recipe and unlock
- [x] Zombie Tank formalized as the Flesh frontline recipe
- [x] Lich caster/summoner recipe and unlock
- [x] temporary-Skeleton summon cap/cooldown/resource constraint
- [x] 30–40 upgrades — catálogo atual com 30 opções
- [x] 10–15 synergies — current catalog reached 10
- [x] rare upgrade catalog — Recuperação Emergencial, Dízimo Carmesim e Patente Proibida
- [x] first rule-changing upgrade — Emergency Reclamation
- [x] multiple enemy archetype foundation
- [x] Human Warrior prototype — durable frontline
- [x] Mage prototype — fragile ranged damage
- [x] Elf prototype — fast skirmisher
- [x] Mage advanced behavior — Arcane Burst AOE/suppression
- [x] Elf advanced behavior — Precision Shot backline targeting
- [x] archetype-specific elite variants — Bulwark, Overcharged and Deadeye
- [x] 3 bosses — Marechal da Sepultura, Auditor Arcano e Capataz
- [x] narrative event system with five between-Wave incidents
- [x] risk/reward event with persistent Iron Concord faction pressure
- [x] Boss Corpse choices after Waves 10 and 15
- [x] two resource recipes/fusions with atomic transactions
- [x] localized narrative intro prototype
- [x] first localized in-run narrative decisions on Waves 7 and 13
- [x] optional discoveries and larger event catalog — each of the ten event routes unlocks a distinct persistent Codex entry
- [x] first complete lore pass — world, factions, bosses, timeline and writing rules in `LORE.md`

### Gate da v0.4.0

**Concluído em 24/08/2026:** o catálogo chegou a 30 upgrades e três raros; a run ganhou três encontros de chefe, cinco decisões narrativas, duas escolhas de Cadáver de Chefe e duas Fusões Necromânticas. As estratégias determinísticas de Ossos e Carne continuam derrotando o Capataz, e os novos sistemas possuem regressão headless dedicada.

---

# v0.4.1 — Consolidação Técnica e Visual

- [x] corrigir quebra/corte de texto nas decisões narrativas
- [x] impedir sobreposição dos projetos de Arqueiro e Lich na Fábrica
- [x] preservar proporção do viewport e fallback de idioma
- [x] centralizar crescimento, Elites, calendário e perfis de chefes em `EnemyWavePolicy`
- [x] organizar cenas e controladores por domínio preservando UIDs, F5 e F6
- [x] extrair estado e transições da partida para `RunDirector`
- [x] extrair a formatação do resumo final para `RunSummaryFormatter`
- [x] extrair grade, spawn, compactação e alcance para `CombatFormationPolicy`
- [x] centralizar coleções, capacidade e ocupação do exército em `UndeadArmyRegistry`
- [x] extrair IDs, disponibilidade, categorias e tradução para `UpgradeCatalog`
- [x] extrair identidade, requisitos, tradução e ordem visual para `SynergyCatalog`
- [x] centralizar custos, capacidade e ciclos da Fábrica em `FactoryProgressionPolicy`
- [x] extrair formatação dos status de upgrade e criação dos controles básicos de produção
- [x] criar silhuetas e sprites próprios para os três chefes
- [x] definir famílias visuais de Cadáver por arquétipo e restos exclusivos de chefe
- [x] extrair a fronteira comum de seleção, dano e limpeza do ciclo de vida para `CombatRuntimeCoordinator`
- [x] separar apresentação do HUD e exclusividade de modais/Fábrica/Rituais em componentes próprios
- [x] definir contrato de animações: idle, movimento, ataque, impacto e morte
- [x] substituir o fundo procedural puro por composição híbrida de arte, parallax, luz e VFX
- [x] criar e validar preset de exportação Windows
- [x] gerar e validar o primeiro build externo Windows com os templates oficiais do Godot 4.7.1

### Gate

Milestone concluído. As regras, o estado e a apresentação estável possuem fronteiras testáveis; o controlador segue como orquestrador e será reduzido incrementalmente, sem bloquear conteúdo nem exigir reescrita total.

---

# v0.5.0 — Meta Progression

- [x] checkpoint versionado entre Ondas e fluxo Continuar V1
- [x] migração do save de schema v1 para v2
- [x] perfil permanente schema v3 com migração dos schemas v1 e v2
- [x] catálogo horizontal com cinco projetos de Fábrica e quatro opções de loadout
- [x] receitas desbloqueáveis: Arqueiro Esqueleto e Lich
- [x] tecnologias desbloqueáveis: Auto-coleta, Prensa Hemática e Extrator de Almas
- [x] três operadores com vantagens e limitações equivalentes
- [x] três contratos iniciais com recompensa e pressão explícitas
- [x] cinco desafios operacionais persistentes e visíveis, incluindo 30 Cadáveres em uma run
- [x] progresso e desbloqueios atualizados durante a run, sem exigir encerramento
- [x] Codex persistente com dez descobertas e dez registros de campo/produção
- [x] histórico persistente e visível das 20 runs concluídas mais recentes
- [x] avaliar Last Stand — resgate mecânico adiado até existirem dados externos de derrota
- [x] liberar possibilidades em vez de atributos acumulados

### Gate

Milestone concluído em 01/09/2026. O perfil preserva conhecimento, projetos, desafios, loadout e histórico sem conceder crescimento bruto por repetição. Os cinco marcos foram cobertos em perfil novo e migrado; Onda 5 e Cadáveres atualizam o gameplay imediatamente.

### Próxima ordem

1. [concluído] fechar a v0.6.0 e seu build reproduzível;
2. iniciar teste cego e revisão linguística externa;
3. definir hardware mínimo/recomendado e medir o release;
4. revisar direitos e produzir áudio comercial final;
5. preparar a presença Steam da v0.7.0.

---

# v0.6.0 — Vertical Slice

## Status: milestone técnico concluído em 08/09/2026

- [x] Main Menu V1
- [x] Pause Menu V1
- [x] Options V1: audio, display and language
- [x] persistent settings V1
- [x] PT-BR / English / Spanish automated UI coverage
- [x] persistent settings V2 with V1 migration
- [x] first-run tutorial in PT-BR / English / Spanish
- [x] reduced motion and high-contrast options
- [x] accessibility options V1
- [x] localization integrity and automated linguistic QA
- [x] final-ish art direction
- [x] viewport proportion and six-target resolution matrix
- [x] factory machinery layer matching the official direction V1
- [x] responsive viewport contract and automated resolution QA
- [x] basic temporary sprites for all current combatants
- [x] final Skeleton art and animation V1
- [x] final Zombie art and animation V1
- [x] Ghost art and animation V1
- [x] Human Warrior art and animation V1
- [x] Mage art and animation V1
- [x] Elf art and animation V1
- [x] factory art V1
- [x] Boss polish
  - [x] Grave Marshal art and animation V1
  - [x] Arcane Auditor art and animation V1
  - [x] Foreman art and animation V1
- [x] animation V1 for all eleven current families
- [x] VFX V1
- [x] SFX V1
- [x] combat VFX V1 with bounded transient budget
- [x] procedural combat SFX V1 with voice budget
- [x] localized Boss entrance warning
- [x] procedural industrial ambience V1 accepted for the vertical slice
- [x] tutorial
- [x] accessibility basics
- [x] checkpoint e perfil com gravação transacional, backup e recuperação de corrupção
- [x] retomada segura no início da onda e erro de salvamento visível sem fechar a run
- [x] reproducible 36-unit headless stress smoke
- [x] five-build Wave 12 matrix
- [x] reproducible release gate, Windows export and smoke test

### Gate

Screenshots/trailer must look commercially credible.

**Gate técnico aprovado:** o aceite completo está em `VERTICAL_SLICE_ACCEPTANCE.md`. Revisão nativa, hardware físico, áudio comercial, teste cego e Steamworks passam para a v0.7.0 porque dependem de pessoas, licenças, equipamentos ou contas externas; não são pendências escondidas da implementação desta milestone.

**Direção visual fechada em 02/09/2026:** regras de cor, silhueta, escala, interface e exportação estão registradas em `ART_DIRECTION.md`. Os estudos de cinco estados do Guerreiro Esqueleto e do Zumbi Tank foram validados como PNG RGBA transparente e deram origem às duas famílias-base de runtime.

**Primeira família integrada em 03/09/2026:** o Guerreiro Esqueleto possui fontes individuais para os cinco estados, escala de canvas corrigida e morte visual desacoplada da liberação imediata do slot.

**Segunda família integrada em 03/09/2026:** o Zumbi Tank possui as cinco poses, escala própria e morte horizontal. As duas tropas-base agora comprovam o mesmo contrato; o próximo corte visual avança para Fantasma, inimigos e chefes.

**Família espectral integrada em 03/09/2026:** o Fantasma deixou de reutilizar a arte do Esqueleto e ganhou identidade fabril própria, cinco estados e dissipação legível. O próximo corte visual começa pelos três arquétipos inimigos.

**Primeiro invasor integrado em 04/09/2026:** o Guerreiro Humano ganhou guarda, avanço, golpe, impacto e morte próprios. A retirada visual ocorre depois da resolução determinística do Cadáver e da Onda. Mago e Elfo eram os próximos cortes inimigos.

**Artilharia arcana integrada em 04/09/2026:** o Mago ganhou cinco estados e mantém carga visual, trajetória de ataque e Rajada Arcana em responsabilidades separadas. O Elfo encerra o trio básico de invasores.

**Atiradora da coalizão integrada em 04/09/2026:** o Elfo ganhou cinco estados com arco, aljava e silhueta ágil consistentes. A flecha fica contida no ataque e o Tiro de Precisão permanece na regra de combate. Os três chefes formam o próximo corte visual.

**Primeiro chefe integrado em 04/09/2026:** o Marechal da Sepultura ganhou cinco estados, escala ampliada e queda completa sem alterar o encontro. Auditor Arcano e Capataz formavam os dois cortes visuais seguintes.

**Segundo chefe integrado em 04/09/2026:** o Auditor Arcano ganhou aparato, documentos e cinco estados próprios. A descarga de quatro alvos e a decisão do Núcleo continuam independentes da arte. O Capataz encerra o corte visual dos chefes.

**Trio de chefes concluído em 04/09/2026:** o Capataz ganhou marcha, golpe industrial, impacto e queda próprios em torno do martelo-reator. O `Industrial Crush` e o encerramento da run permanecem no combate. Fábrica, Arqueiro Esqueleto e Lich foram concluídos no corte de 08/09/2026.

**Confiabilidade de retomada concluída em 08/09/2026:** checkpoint e perfil usam escrita transacional com backup. `Continuar` volta ao início da onda atual, falhas de gravação mantêm a partida aberta e schemas futuros do perfil não são sobrescritos. O próximo corte técnico centraliza derrota e recuperação antes de ampliar sistemas comerciais.

**Correções internas da auditoria concluídas em 08/09/2026:** validação defensiva, recuperação e diagnóstico foram centralizados; Arqueiro e Lich fecharam as famílias visuais; a Fábrica ganhou maquinário; o áudio passou a quatro buses e nove sinais; seis resoluções, estresse máximo e cinco estratégias receberam regressões. O fechamento público agora depende dos gates humanos, legais, comerciais e de hardware descritos em `AUDIT_STATUS.md`.

---

# v0.7.0 — Steam Demo / Market Validation

- [ ] native PT-BR / English / Spanish editorial review
- [ ] manual Windows scale QA at 100%, 125% and 150%
- [ ] release profiling on minimum and recommended hardware
- [ ] authored/licensed commercial soundtrack and final SFX
- [ ] asset rights and AI disclosure review
- [ ] Steamworks
- [ ] Coming Soon page
- [ ] capsule
- [ ] screenshots
- [ ] trailer
- [ ] store copy
- [ ] tags
- [ ] public demo
- [ ] external playtests
- [ ] creators
- [ ] wishlist tracking
- [ ] short-form clips
- [ ] evaluate Next Fest timing

---

# v0.8.0 — Alpha

- [ ] target content
- [ ] meta progression
- [ ] achievements
- [ ] localization pipeline
- [ ] PT-BR
- [ ] English
- [ ] save versioning
- [ ] performance with large hordes
- [ ] full balance pass

---

# v0.9.0 — Beta / Release Candidate

- [ ] feature freeze
- [ ] QA
- [ ] crash testing
- [ ] save testing
- [ ] progression testing
- [ ] final balance
- [ ] localization QA
- [ ] release pricing research
- [ ] final trailer/capsule/screens
- [ ] creator outreach
- [ ] RC build

---

# v1.0.0 — Steam Launch

- [ ] Steam review
- [ ] final build
- [ ] launch
- [ ] hotfix pipeline
- [ ] reviews monitoring
- [ ] wishlist/sales conversion analysis

---

# Post-launch

Based on traction:

- patches;
- balance updates;
- new units;
- new bosses;
- new factory machines;
- operators;
- free content;
- DLC/expansion if justified;
- ports only if commercially viable.
