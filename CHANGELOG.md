# Changelog

## [Unreleased] — Consolidação pós-auditoria de 14/09/2026

### Transporte para a prensa — 02/10

Validação: 87/87 runners em 122,71 s, exportação e smoke Windows aprovados; capturas de coleta e prensa conferidas em 1280×720.

- Cadáver ativo percorre uma trajetória até a entrada, sem cópia visível no campo; os demais aguardam em suas posições.
- Coleta, esteira, prensa e saída dividem o ciclo real, sem atrasos adicionais ou crédito antecipado de recursos.
- Visibilidade original restaurada se a reserva for removida ou o apresentador destruído; modo reduzido apresenta a carga diretamente na câmara.
- Proporção da carga preservada e compressão ancorada à esteira; estado de coleta traduzido em PT-BR, EN e ES.

### CI reproduzível e processamento em cena — 01/10

Validação local: 87/87 runners em 93,85 s com hardlink sem extensão; exportação e smoke Windows aprovados. Capturas das fases a 1028×578. CI da correção confirmado em 36925391852.

- Corrigido o Release Gate: importação prévia, espera explícita, log nativo e suporte ao hardlink sem extensão do setup-godot. Execução remota 36925391852 aprovada.
- Cadáveres coletáveis usam a arte de queda de cada arquétipo, com região transparente aparada em memória e proporção preservada; não mais a pose em pé cinzenta.
- Prensa ilustrada com esteira, pistão e saída ligados ao progresso real da fila de materiais; recursos continuam creditados pela simulação. Efeito de ganho dessa rota parte da saída da máquina.
- Pausa de planejamento e movimento reduzido respeitados; roteiro de captura das três fases e teste dedicado sem mutação econômica.
- Roadmap prioriza animação aprovada, três setores distintos, decisões de produção e vontade de repetir, sem fechar artificialmente v0.6.5.

### Identidade do Diretor e desfecho — 01/10

Validação: 86/86 runners em 96,13 s; exportação e smoke test Windows aprovados. Capturas 720p nos três idiomas e regressão narrativa adicional após o ajuste de troca de idioma.

- Eventos revelam a origem coletiva do Diretor e o motivo do confronto com o Capataz antes da onda final.
- Falas do Marechal e do Auditor reconhecem decisões anteriores, reutilizando o histórico salvo e preservando recompensas.
- Vitória recebe epílogo curto com variação conforme o destino do núcleo; derrota mantém seu diagnóstico sem texto de vitória.
- Resumo final com duas colunas roláveis; textos em PT-BR, EN e ES.

### Ameaças dos chefes — 23/09

Gate: 86/86 runners em 94,54 s; exportação Windows e smoke test aprovados. Capturas dos avisos geradas em 720p nos três idiomas, com inspeção de PT-BR, EN e ES. SHA-256 do executável: `9CD976868368217899C9C3359DEE080DB5F071E8A19D408CF964EBF37D7A457A`.

- Marechal atinge até três tropas mais próximas; Auditor prioriza até quatro mais distantes; Capataz atinge até seis tropas no agrupamento mais denso em um raio de 180 unidades.
- Aviso traduzido antecede o especial em pelo menos um segundo de simulação, inclusive após um frame longo. Pausa e preparação continuam congelando o combate.
- Banners têm quebra de linha e prioridade sobre efeitos comuns; movimento reduzido não encurta a leitura.
- PV, dano por alvo e intervalos-base preservados. A distribuição de perdas mudou: equilíbrio e compreensão ainda precisam de playtest, sem declarar a v0.6.5 concluída.

### Leitura ampliada e observação — 23/09

Validação final: 86/86 runners em 91,27 s, exportação e smoke test Windows aprovados. Capturas 720p de Opções, HUD e cartas nos três idiomas; textos táticos a 130%. v0.6.4 e v0.6.5 continuam abertas conforme o roadmap.

- opções de textos táticos em 100%, 115% e 130%, persistidas no settings v5 com compatibilidade para versões anteriores;
- operação com rolagem; escala aplicada às sinergias e às cartas;
- instrumentação opcional `--measure-run`: primeiras mudanças, tempo sem pausa, combate, ociosidade e perdas no segmento atual;
- voz exclusiva para alerta de chefe, protegida da substituição por efeitos comuns;
- decisão de manter Fusões documentada pela conversão exclusiva de recursos em Pontos de Fábrica.

### Painel operacional e escolhas antecipadas — 17/09

- capacidade, reservas de produção, composição e processamento passam a ocupar o painel principal; métricas históricas continuam disponíveis por botão;
- aviso de fluxo recebe espaço próprio com quebra de linha; temporizadores voltam a ter uma linha exclusiva;
- preparação informa máquinas pausadas; cadáveres já destinados à extração de almas deixam de aparecer como coleta pendente;
- cartas mostram qual combinação avançam ou ativam, usando uma cópia do estado sem conceder o benefício antecipadamente;
- sinergias exibem fração de requisitos e são ordenadas pelo progresso proporcional;
- capturas de cartas incluídas na ferramenta de apresentação em PT-BR, inglês e espanhol.

Validação: 86/86 runners em 110,46 s, exportação Windows e smoke test aprovados. Capturas de HUD e cartas em 1280×720. Tamanho e hash do build atual em `docs/BUILDING.md`.

### Clareza de decisões e fluxo

- painel rolável consulta as dez sinergias, ordenadas por ativas, prontas e maior progresso;
- efeito e requisitos concluídos/pendentes aparecem em PT-BR, inglês e espanhol;
- requisitos mecânicos foram centralizados no catálogo usado tanto pelo desbloqueio quanto pela apresentação;
- linha de produção identifica capacidade cheia, filas saturadas, cadáver aguardando, recurso ocioso, processamento e produção em andamento;
- diagnóstico e formatação usam snapshots puros, sem alterar custos, recompensas, cadência ou automação.

Validação: 86 runners aprovados em 89,33 s, catálogo com 485 chaves completas nos três idiomas, inspeção renderizada em 1280×720 e Windows exportado/iniciado em smoke test. Executável com 125.031.320 bytes e SHA-256 `8A2B1E5930C5B3449E91CB54687A15A81DB214ADE65D00742FC892FC6EC89A04`.

### Preparação estratégica entre ondas

- próxima onda aguarda comando explícito após o aprimoramento e o eventual evento narrativo;
- painel localizado antecipa inimigo principal, PV, dano, total e limite simultâneo;
- durante o planejamento, tempo da run, processamento, produção e automações ficam congelados; novas ordens podem ser configuradas para retomada no início do combate;
- checkpoints novos reabrem a preparação, enquanto saves anteriores mantêm a retomada direta compatível;
- fluxo protegido contra início duplo, com tutorial atualizado e regressões de estado, pausa dos relógios, tradução e restauração.

Validação: 84 runners aprovados em 91,2 s, catálogo com 450 chaves nos três idiomas, captura renderizada em 1280×720 e Windows exportado/iniciado em smoke test. Nenhum número de combate ou economia foi alterado.

### Primeiro ciclo jogável

- guia contextual acompanha abate → cadáver → processamento → ordem → unidade produzida usando eventos reais da partida;
- progresso se recupera de ações fora de ordem e de checkpoints com ciclo parcialmente avançado;
- introdução e guia possuem conclusão separada; dispensar tudo, rever e desativar nas opções atualizam a orientação imediatamente;
- settings v4 lê versões anteriores com defaults seguros e preserva a conclusão do novo ciclo;
- cartão localizado em PT-BR/EN/ES foi reposicionado após captura renderizada para não cobrir o primeiro aliado.

Validação: 85 runners aprovados em 84,46 s, catálogo com 461 chaves nos três idiomas, captura do guia em 1280×720 e Windows exportado/iniciado em smoke test. Executável com 125.023.248 bytes e SHA-256 `B35972084EF8E14F0EE19D871A4AC417E90C1738386FE5184AA8BF159D4DF93F`.

### Fronteira de apresentação da produção

- formatação de produção, processamento e status das filas extraída do controlador para funções puras;
- snapshots explícitos, sem acesso à cena ou mutação de recursos e filas;
- preservados custos, quantidade, capacidade, bloqueio de arqueiro, limite de ordens e fim de partida;
- nova regressão cobre lotes 1/10, limites exatos, falta de recursos, fila cheia e tradução PT-BR/EN/ES;
- implementação técnica da v0.6.3 concluída; próxima etapa: preparação entre ondas da v0.6.4. Sem nova versão pública nem mudança de balanceamento.

Validação deste corte: 83 runners aprovados em 85,06 s; Windows exportado e iniciado em smoke test headless. Run manual e aprovação comercial permanecem etapas separadas.

### Consolidação de HUD e medição renderizada

- removidas labels ocultas de recursos/métricas e seus formatadores; dashboard passa a ser a única apresentação desses dados;
- textos fixos traduzidos por mudança de idioma e valores reescritos apenas quando alterados;
- regressões de tradução e limites verificam as labels visíveis, preservando controles de produção/processamento;
- ferramenta de profiling com loop renderizado, aquecimento, percentis, memória estática e cenário com seed fixa;
- comparação local registrada em `RENDERED_PROFILING.md`, sem prometer ganho consistente de FPS ou requisitos mínimos;
- 82 runners aprovados, HUD renderizado em 720p, alias F6 iniciado e Windows exportado com smoke test. O teste de formatação de onda também foi reexecutado após remover as funções antigas.

### Avisos de persistência, rotas e ajustes de leitura

- painel PT-BR/EN/ES para recuperação de backup, perfil protegido, checkpoint inválido e falhas de gravação de run/perfil/opções;
- nova tentativa de gravação sem reiniciar; falhas durante combate pausam a partida e avisos repetidos já confirmados não inundam a tela;
- histórico de conclusão com falha de gravação permanece em memória e pode ser salvo novamente;
- checkpoint preserva métricas por rota; legado sem distribuição recebe categoria explícita de rota não registrada no resumo/histórico;
- validação confere tipos, IDs e soma das rotas; schema v2 e migração v1 continuam compatíveis;
- debug oculto deixa de montar texto e consultar recuperação; mostrar F3 volta a atualizar;
- tutorial corrigido para chefes nas ondas 10, 15 e 20 nos três idiomas;
- regressão integrada de falha, nova tentativa, backup, proteção do perfil e métricas; captura renderizada dos avisos em três idiomas.

Validação: 82 runners e 443 chaves nos três idiomas; avisos capturados em 1280×720 com OpenGL Compatibility. O gate também exporta e inicia o Windows release. Isso não substitui uma run manual completa nem medições de performance em hardware mínimo.

### Validação dos campos operacionais

- fábrica e rituais rejeitam níveis inválidos e flags com tipos incorretos;
- doutrina valida metas, capacidade combinada, reservas e prioridade; modificadores validam bônus e pressão por facção;
- loadout rejeita IDs desconhecidos; versão/onda rejeitam tipos incorretos, frações e números não finitos;
- restauração direta recusa campos operacionais inconsistentes antes de remover unidades;
- campos opcionais ausentes continuam compatíveis com checkpoints anteriores;
- nova regressão verifica que escrita recusada preserva o arquivo saudável e que um principal inválido recupera o backup.

Validação: 81 runners aprovados com `-SkipExport`, incluindo migração v1→v2 e campos operacionais; importação headless do editor sem erros. Sem novo export e sem alteração de regras de combate/economia.

### Integridade narrativa dos checkpoints

- eventos pendentes desconhecidos ou já concluídos, escolhas incompatíveis e tipos narrativos incorretos são rejeitados;
- restauração direta valida a narrativa antes de remover unidades ou substituir estado;
- JSON semanticamente inválido passa a acionar a tentativa de backup; sem cópia válida, o arquivo original permanece intacto e Continuar fica indisponível;
- regressão dedicada cobre rejeição, recuperação e reabertura de decisão válida sem recompensa antecipada;
- avisos explícitos de recuperação/indisponibilidade ainda serão implementados no próximo corte de persistência.

Validação deste corte: 80 runners aprovados com `-SkipExport`, incluindo integridade narrativa e migração v1→v2; importação headless do editor concluída sem erros. Sem novo executável ou alteração de balanceamento.

### Pausa e isolamento dos testes

- gameplay explicitamente pausável, preservando navegação do shell; reposição inimiga e aviso de desbloqueio também respeitam a pausa;
- regressões de pausa/tutorial verificam relógio, posições e temporizador ao longo de frames, além da retomada;
- checkpoints de shell/tutorial isolados do save pessoal, com limpeza dos backups de teste;
- Continuar respeita o caminho de checkpoint configurado;
- roadmap registra todas as frentes da auditoria com prioridades e critérios de aceite, sem equiparar testes técnicos à aprovação comercial.

Validação: 79 runners aprovados com `validate_release.ps1 -SkipExport`; runner de shell reexecutado após acrescentar a verificação da fila de produção congelada. Não houve novo export Windows nem aceite visual/manual neste corte.

## [0.6.2] — 11/09/2026 — Apresentação industrial

### Alterado

- menu ilustrado com nova arte da fábrica, hierarquia de ações, Cinzel/Barlow e atmosfera compatível com Movimento Reduzido;
- HUD com quatro cartões de recursos, símbolos econômicos, métricas em colunas, molduras e barras de progresso;
- sinergias em área rolável, produção com ícones, rótulos compactos, quantidade/custo e dica explicando a fila;
- driver de movimento contínuo ligado ao deslocamento, sem reiniciar a passada ou misturar silhuetas com transparência;
- perfis e âncoras por família, resposta de dano independente do ataque e morte terminal mesmo ao alternar acessibilidade;
- preservados combate, economia, cooldowns, saves e balanceamento.

### Validação e limites

- 79 runners aprovados, incluindo novo cenário de apresentação nos três idiomas;
- ciclo do driver comparado a 30/60/144 Hz, onze famílias integradas, lotes de dez e dez sinergias verificados;
- menu, HUD e fases do movimento renderizados para inspeção; Windows release exportado e iniciado;
- licenças OFL incluídas; capturas e ferramentas excluídas do pacote;
- smoke test Windows agora espera o executável gráfico encerrar e confere também erros de runtime;
- movimento ainda procedural sobre poses V1: não foram adicionados frames desenhados de personagens. A naturalidade depende do próximo playtest.

## [0.6.1] — 11/09/2026 — Fluidez de combate

### Alterado

- caminhada das onze famílias visuais passou a usar seis fases de pose em um ciclo de 0,32 s, com transição cruzada, oscilação e inclinação interpoladas;
- ataques agora possuem antecipação, impacto sustentado e recuperação em seis fases ao longo de 0,28 s;
- o driver ignora pedidos redundantes de movimento enquanto um ciclo já está em execução, evitando reinícios e travamentos aparentes;
- a apresentação continua desacoplada de dano, alcance, cooldown, economia e balanceamento.

### Validado

- contrato de sequências rejeita estados, quantidades e tipos de frame inválidos;
- regressão visual percorre caminhada, ataque, impacto e morte das onze famílias atuais;
- versão de produto, projeto e metadados Windows avançados em conjunto para `0.6.1`.

## [0.6.0] — 08/09/2026 — Vertical Slice

### Added

- validação defensiva de checkpoint e perfil, recuperação centralizada e diagnóstico localizado da derrota;
- gate único com 78 runners, logs, exportação, smoke test, hash e workflow Windows;
- famílias V1 completas do Arqueiro Esqueleto e do Lich;
- arte física V1 da Fábrica com processador, cuba, prensa, reservatórios e esteira;
- buses `Music`, `SFX` e `UI`, volumes persistentes, ambiente industrial e sinais de processamento/produção/bloqueio;
- matriz de seis resoluções, estresse de 36 unidades e cinco estratégias na Onda 12;
- telemetria ampliada no histórico local das vinte runs;
- documentação de situação da auditoria, protocolo de playtest e gates de release;
- versão centralizada entre menu, checkpoint, projeto e executável Windows;
- contrato de aceite da vertical slice e transferência explícita dos gates externos para a v0.7.0;

- tutorial inicial localizado em cinco etapas, apresentado uma vez na primeira Nova Partida;
- controles para rever ou desativar o tutorial nas Opções;
- Movimento Reduzido, removendo parallax, névoa móvel, pulsos, idle procedural e deslocamentos de feedback;
- Interface de Alto Contraste, com contornos de texto e barras de vida reforçadas;
- regressões próprias de tutorial e acessibilidade, elevando a suíte para 55 cenários.
- camada VFX V1 com rastros de ataque, números de dano, impactos, mortes, invocações e alertas de chefe;
- banco SFX procedural V1 com vozes para ataque, impacto, morte, habilidade, chefe e início de Onda;
- apresentação localizada de entrada dos três chefes;
- regressões audiovisuais dedicadas, elevando a suíte para 57 cenários.
- direção de arte consolidada para personagens, cenário, interface, cores e exportação;
- concept sheets RGBA de cinco estados para Guerreiro Esqueleto e Zumbi Tank;
- suporte a texturas por estado no `UnitAnimationDriver`, com fallback seguro para o sprite-base;
- auditoria integral das 422 chaves em inglês, português do Brasil e espanhol;
- regressões de assets de animação e integridade linguística, elevando a suíte para 59 cenários.
- família final V1 do Guerreiro Esqueleto com sprites individuais de idle, movimento, ataque, impacto e morte;
- integração das poses no movimento e feedback de combate, com morte visual curta após a liberação do slot;
- regressão dedicada de dimensões, transparência e catálogo da família do Esqueleto, elevando a suíte para 60 cenários.
- família final V1 do Zumbi Tank com cinco sprites individuais, escala de canvas própria e pose de morte horizontal;
- cobertura de transparência, importação e ciclo visual completo do Zumbi, elevando a suíte para 61 cenários.
- identidade visual final V1 do Fantasma, com núcleo de Alma industrial, cinco estados e dissipação horizontal;
- regressão dedicada da família espectral, elevando a suíte para 62 cenários.
- família final V1 do Guerreiro Humano com idle defensivo, avanço protegido, golpe de espada, impacto e morte;
- regressão dedicada dos assets humanos, elevando a suíte para 63 cenários.
- família final V1 do Mago com guarda arcana, avanço baixo, conjuração compacta, impacto e morte;
- regressão dedicada dos assets arcanos, elevando a suíte para 64 cenários.
- família final V1 do Elfo com guarda de arqueira, avanço cauteloso, disparo, impacto e morte horizontal;
- regressão dedicada dos assets élficos e retirada visual, elevando a suíte para 65 cenários.
- família final V1 do Marechal da Sepultura com escudo-túmulo, avanço pesado, golpe, impacto e queda;
- primeira regressão dedicada de chefe animado, elevando a suíte para 66 cenários.
- família final V1 do Auditor Arcano com aparato de auditoria, avanço, conjuração, impacto e queda;
- regressão dedicada do segundo chefe animado, elevando a suíte para 67 cenários.
- família final V1 do Capataz com martelo-reator, marcha pesada, golpe industrial, impacto e queda;
- regressão dedicada do chefe final, concluindo os três chefes e elevando a suíte para 68 cenários.
- armazenamento JSON transacional compartilhado por checkpoint e perfil, com arquivo temporário validado e backup da gravação anterior;
- regressão de confiabilidade cobrindo corrupção, recuperação do backup, falha de escrita, schema inválido e proteção de perfil futuro, elevando a suíte para 69 cenários.

### Changed

- configurações migradas para o schema v2, preservando automaticamente arquivos v1;
- preferências de acessibilidade passam a valer imediatamente no shell e na partida em andamento;
- painel de Opções foi ampliado para manter todos os controles dentro de 1920×1080;
- tutorial concluído é persistido sem contaminar checkpoint ou perfil permanente.
- feedback visual limitado a 48 elementos transitórios e áudio limitado a dez vozes com cadência protegida para hordas.
- concept sheets são fontes de direção e não são cortados como atlas enquanto não tiverem células e pivôs uniformes.
- fontes de conceito e referência permanecem excluídas do build Windows até virarem assets de runtime.
- cena editável e catálogo do Esqueleto agora usam a nova pose idle; demais estados entram pelo driver visual.
- Zumbis agora liberam registro e slot antes dos 0,24 s reservados à leitura da morte visual.
- a cena do Fantasma deixou de reutilizar o Esqueleto e passou a expor sua própria pose idle no editor.
- o Guerreiro Humano agora usa a mesma ponte de animação do exército sem alterar seus atributos de combate;
- o trio básico de invasores vivos agora compartilha retirada visual após a resolução determinística do Cadáver e da Onda;
- o Marechal mantém sua escala ampliada e resolve progressão de chefe antes dos 0,24 s reservados à morte visual;
- o Auditor mantém descarga especial, alvo, recompensa e decisão de Núcleo fora da camada visual;
- o protótipo do Auditor deixou de entrar no pacote depois que a família V1 assumiu o runtime;
- o Capataz preserva o Industrial Crush, o encerramento da run e sua apresentação de vitória fora da arte;
- o protótipo do Capataz deixou de entrar no pacote depois que sua família V1 assumiu o runtime;
- inimigos humanos derrotados permanecem por 0,24 s apenas para apresentar a pose de morte, depois de saírem da simulação.
- o Mago passou a usar poses próprias sem mover Rajada Arcana, supressão ou dano para a camada visual;
- o projétil permanece no VFX de combate, enquanto a pose de ataque limita a energia ao núcleo do cajado.
- `Continuar` agora retoma explicitamente o início da onda atual, sem preservar ganhos ou dano parciais do combate interrompido;
- Salvar e Voltar ao Menu só encerra a partida depois da confirmação de escrita; em caso de erro, a run permanece aberta e informa a falha no idioma ativo;
- conclusão de run confirma o perfil permanente antes de remover o checkpoint;
- perfis criados por schemas futuros entram em modo protegido e não podem ser sobrescritos por uma versão antiga do jogo.

## [0.5.0] — 01/09/2026 — Meta Progression

### Added

- perfil permanente versionado e separado do checkpoint de uma run;
- Codex narrativo no menu principal com descobertas de rota e registros de tropas, inimigos e chefes;
- histórico persistente das 20 runs concluídas mais recentes;
- tela localizada de histórico com projetos permanentes e resultados de cada run;
- cinco projetos horizontais de Fábrica e quatro possibilidades permanentes de loadout;
- tela de configuração com três operadores, três contratos iniciais e cinco desafios operacionais;
- notificação imediata de projeto permanente liberado durante a partida;
- alias de compatibilidade `main.tscn` para execuções F6 salvas em versões anteriores da organização;
- regressões de perfil, catálogo, integração, loadout e layout, elevando a suíte para 53 runners.

### Changed

- descobertas passam do checkpoint para o perfil sempre que a partida é salva ou concluída;
- conclusão de Onda e processamento de Cadáver atualizam o perfil durante a run;
- resultado, onda, inimigos derrotados e exército restante são registrados no fim da run;
- perfil migrado para o schema v3, reconstruindo progresso compatível a partir do histórico preservado;
- tecnologias e receitas avançadas exigem marcos permanentes no fluxo F5, mas continuam livres no F6 de desenvolvimento;
- cartões de aprimoramento e projetos ganharam quebra automática, recorte e limites fixos;
- painel do menu principal ganhou acesso ao loadout sem comprimir os demais controles.

## [0.4.1] — 01/09/2026 — Consolidação Técnica

### Added

- `RunDirector` como fonte do estado e das transições da partida;
- `RunSummaryFormatter` para apresentação localizada do resultado final;
- `CombatFormationPolicy` para a grade, spawn, compactação e limites de posicionamento;
- `UndeadArmyRegistry` para coleções, capacidade e ocupação dos slots;
- `UpgradeCatalog` como fonte dos 30 IDs, disponibilidade, limites e categorias;
- `SynergyCatalog` como fonte das dez identidades, requisitos e chaves de localização;
- `FactoryProgressionPolicy` para custos, capacidade e ciclos das máquinas;
- `UpgradeStatusFormatter` e `ProductionControlsFactory` como limites iniciais da UI;
- sprites próprios para Marechal da Sepultura e Auditor Arcano, completando a identidade visual dos três chefes;
- famílias visuais de Cadáver e restos exclusivos dos chefes;
- contrato comum de animações para idle, movimento, ataque, impacto e morte;
- preset de exportação Windows Desktop;
- fundo híbrido com ilustração industrial, parallax sutil, névoa e iluminação procedural;
- schema de checkpoint v2 com metadados e migração automática dos saves v1;
- `CombatRuntimeCoordinator` para seleção, dano e limpeza comum do ciclo de vida;
- `GameplayHudPresenter` e `GameplayPanelCoordinator` para apresentação e exclusividade dos painéis;
- primeiro executável Windows release validado com os templates oficiais do Godot 4.7.1;
- cenários de regressão dedicados às novas fronteiras.

### Changed

- cenas organizadas em `scenes/core`, `scenes/world` e `scenes/units`;
- controlador principal movido para `scripts/game/main_controller.gd`;
- F5 passa por `scenes/core/app.tscn` e F6 pode executar `scenes/world/gameplay.tscn`;
- referências de cenas, testes e documentação atualizadas com preservação dos UIDs.
- `MainController` reduzido para menos de dez mil linhas, mantendo as APIs públicas usadas por saves e testes.
- Cadáveres deixaram de ser botões textuais puros e agora preservam a família visual do inimigo abatido.
- o cenário procedural puro foi substituído por uma composição ilustrada sem remover as camadas dinâmicas de leitura do combate.

## [0.4.0] — 24/08/2026 — Build Diversity & Content

### Added

- catálogo ampliado de 18 para 30 upgrades, com opções próprias para Arqueiros, Zumbis, Fantasmas e economia;
- Dízimo Carmesim e Patente Proibida no catálogo raro, ao lado de Recuperação Emergencial;
- Marechal da Sepultura na onda 10 e Auditor Arcano na onda 15, mantendo o Capataz na onda 20;
- cinco eventos narrativos localizados, incluindo risco permanente e duas decisões de Cadáver de Chefe;
- dez descobertas de lore persistentes vinculadas às rotas dos eventos;
- painel de Fusões Necromânticas com Liga de Ossuário e Formação Vinculada;
- primeira versão completa da lore em `docs/LORE.md`;
- regressões dedicadas para catálogo de upgrades, progressão de chefes, eventos e fusões.

### Changed

- Elites redistribuídos para as ondas 5, 9, 14 e 18, evitando conflito com chefes;
- checkpoints agora preservam os modificadores permanentes concedidos por eventos;
- documentação consolidada em voz autoral e atualizada para o estado real da v0.4.0;
- traduções EN, PT-BR e ES ampliadas para todo o novo conteúdo.

### Balance

- chefes escalam de 1050/18 para 1650/24 e 2200/28 em PV/dano;
- duas runs determinísticas completas continuam viáveis: Bone encerra com predominância de Esqueletos e Flesh com predominância de Zumbis;
- receitas de fusão usam custos fixos e transações atômicas para impedir consumo parcial ou criação sem vaga.

## [Unreleased] — v0.2.0 Necromantic Economy

### Added

- Archetype-specific Elite variants, now scheduled on Waves 5/9/14/18:
  - Elite Warrior Bulwark reduces incoming damage by 20%;
  - Elite Mage Overcharged casts every second attack with 65% splash and 0.45 s suppression;
  - Elite Elf Deadeye uses precision every third attack for 150% damage;
  - localized Elite name, persistent trait label and stronger ability feedback;
  - Elite state is stored per Enemy and cleaned with its runtime dictionaries;
  - The Foreman remains outside the Elite rules.
- Persistent Elite variant validation; complete regression expanded to 24 runners.

- Advanced enemy behavior:
  - Mage Arcane Burst every third attack hits up to three nearby Undead, deals 50% splash damage and delays their next attack by 0.30 s;
  - Elf Precision Shot every fourth attack prioritizes vulnerable summoners/ranged units and deals 135% damage;
  - localized in-world ability feedback and an observable gameplay signal;
  - isolated `EnemyCombatPolicy` keeps cadence, targeting priority and multipliers testable.
- First rare/rule-changing upgrade, Emergency Reclamation:
  - eligible from Wave 8 and limited to one acquisition;
  - once per Wave refunds half the production cost of the first permanent Undead lost;
  - supports Bone, Flesh and Soul recipes;
  - temporary Thralls cannot consume or exploit the trigger;
  - localized card, status and resource-return feedback.
- Metrics/Synergy HUD separation expanded and regression-tested against every metric row and all ten synergies.
- Automated regression expanded to 23 persistent runners.

- Lich Summoner V1:
  - original transparent prototype sprite and dedicated scene;
  - run-scoped blueprint purchased for 5 Factory Points;
  - ranged 8-Soul caster recipe in the Ritual panel;
  - Soul-consuming temporary Thralls with global cap, cooldown, lifetime and normal army-slot pressure;
  - temporary units are isolated from permanent Skeleton build/loss metrics, Reassembly and Final Service;
  - Grave Contract, Rapid Conjuration and Bound Servitude upgrades;
  - Soul Foundry synergy buffs future Thralls;
  - full EN/PT-BR/ES UI, metrics and run-summary coverage;
  - persistent Lich combat, summon, anti-exploit, localization and layout validation.
- Ossuary Ballistics, the tenth active synergy: unlocked Archer blueprint + Heavy Bones + Death March grants Skeleton Archers +80 range.
- Runtime recipe catalog expanded with `lich` and `lich_thrall`, including summoner identity and temporary-unit ownership state.
- Complete automated regression now covers 23 runners; visual tween cleanup uses elapsed time instead of frame count for headless stability.

- v0.4 generic Undead runtime foundation:
  - shared `UndeadRuntimeUnit` identity and combat-state component;
  - recipe catalog for Skeleton Warrior, Zombie Tank and Ghost;
  - Skeleton Warrior formalized as base Bone melee;
  - Zombie Tank formalized as base Flesh frontline;
  - compatibility mirrors preserve current combat, balance tests and future save migration;
  - persistent runtime contract test added before Skeleton Archer development.
- Skeleton Archer V1:
  - original transparent prototype sprite and dedicated editable scene;
  - unlockable blueprint purchased for 3 Factory Points;
  - 8-Bone ranged recipe sharing the timed Skeleton Assembler queue;
  - protected rear formation and 380-unit engagement range;
  - runtime-owned HP, damage, cooldown, speed and slot state;
  - Bone upgrades propagate to existing and future Archers;
  - English, PT-BR and Spanish production/unlock text;
  - persistent gameplay, localization, sprite and layout validation.

- Resource foundation:
  - Bones;
  - Flesh;
  - Blood;
  - Souls.
- Flesh generation from Corpse processing.
- Temporary multi-resource HUD.
- `F3` toggle for compact Debug HUD.
- Zombie V1.
- Zombie production using Flesh.
- Zombie HP / attack timer / slots / metrics.
- Generic Undead targeting for Enemy.
- Generic Undead targeting for The Foreman AOE.
- Zombie frontline priority.
- Zombie metrics in Run Summary.
- Defeat condition aware of Skeletons + Zombies + Bones + Flesh + Corpses.
- Zombie-specific upgrade set:
  - Rotten Bulk;
  - Grave Hunger;
  - Dead Weight;
  - Carrion Recovery.
- First industrial-necromancy visual pass based on `assets/reference/necrodesign.png`:
  - procedural factory backdrop;
  - separated battlefield and production floor;
  - NecroWorks brand header;
  - framed Wave, Resources, Run Metrics and Synergy panels;
  - dedicated Corpse Processing and Undead Production modules;
  - dark-metal upgrade and production cards.
- Main scene configured for Project Run.
- Runtime health bars for Skeletons, Zombies, normal Enemies, Elites and The Foreman.
- Health bars update on damage, healing, revival and Max HP upgrades.
- Project structure clarified while preserving Godot-compatible root entry points:
  - `main.tscn`, `main.gd` and base prototype scenes remain at `res://` for reliable F6 current-scene execution;
  - `assets/reference` and `scripts/ui` hold modular resources.
- Reusable `UnitHealthBar` visual component.
- First Flesh/Bone cross-synergy, Meat Shield Protocol:
  - requires Rotten Bulk + Rapid Assault;
  - every hit absorbed by a Zombie reduces all Skeleton attack timers by 0.12 s.
- Simultaneous Enemy group foundation:
  - independent HP, cooldown, lane and health bar per active Enemy;
  - closest-target selection for Skeletons and Zombies;
  - defeated slots refill while the Wave still has remaining Enemies;
  - staged active caps from Wave 6 onward;
  - The Foreman remains a single-target Boss encounter.
- Living Enemy archetype foundation:
  - Human Warrior as the durable melee baseline;
  - Mage as a fragile, high-damage ranged attacker from Wave 8;
  - Elf Skirmisher as a fast attacker from Wave 11;
  - independent HP, damage, speed, attack range and cooldown per archetype;
  - temporary identity labels and color coding above each Enemy.
- Persistent deterministic composition balance runner for Skeleton-only, Zombie-heavy and mixed armies.
- Processing Directive V1:
  - Balanced yields 8 Bones / 2 Flesh;
  - Bone Focus yields 12 Bones / 0 Flesh;
  - Flesh Focus yields 2 Bones / 6 Flesh;
  - three live factory controls and dynamic yield feedback;
  - focused modes preserve one-Corpse emergency production.
  - per-route processing history in the final Run Summary.
- Processing directives now use Wave commitment:
  - Wave 1 starts in Balanced mode;
  - selection is free during the between-Wave upgrade phase;
  - the selected route is locked while combat is active.
- Persistent economy runner for directive yields, UI bounds and upgrade compatibility.
- First runtime character sprite pass for Skeleton, Zombie, Human Warrior, Mage, Elf and The Foreman.
- `skeleton.tscn` and `enemy.tscn` now expose visible `Sprite2D` children in the 2D editor.
- Runtime sprite selection centralized in `scripts/visual/unit_sprite_catalog.gd`.
- Procedural backdrop moved from the repository root to `scripts/visual/industrial_backdrop.gd`.
- Persistent visual runner validates every current unit texture and verifies square placeholders are gone.
- Runtime sprite imports are capped at 512 px while original transparent PNG sources are preserved.
- Corpse processing feedback V1:
  - clicked Corpses emit a directive-colored token toward the Resources intake;
  - the Resources panel reacts with a short color pulse;
  - the actual Bones/Flesh yield appears above the factory boundary;
  - resource transactions remain immediate and deterministic;
  - `corpse_processing_feedback_started` provides a future SFX integration hook.
- Persistent visual runner validates the complete feedback lifecycle and cleanup.
- Localization foundation V1:
  - Godot-native CSV catalog registered for English, PT-BR and Spanish;
  - localized Resources, production, Corpse processing, directives, metrics and yield feedback;
  - runtime locale changes refresh the localized HUD slice immediately;
  - `LocalizationService` normalizes regional locale variants and provides a safe English fallback;
  - persistent runner validates all three language routes.
- Localization coverage expanded to the Wave HUD, enemy identities, Corpse labels and Active Synergies.
- `necrodesignv2.png` adopted as the authoritative Visual Target V2.
- Corpse Processor Queue V1:
  - manual Corpse clicks enqueue work instead of yielding resources instantly;
  - base queue capacity is 5 with a 0.65-second single-lane processing cycle;
  - each queue entry snapshots its processing directive;
  - full queues preserve unqueued Corpses on the battlefield;
  - persistent runner validates capacity, delayed rewards and directive integrity.
- Factory Control V1:
  - dedicated localized Factory panel and navigation button;
  - one Factory Point per completed Wave plus one bonus point for Elite Waves;
  - Automated Retrieval purchase and reversible auto-collection toggle;
  - three queue-capacity levels and three processing-speed levels with escalating costs;
  - automatic retrieval respects queue capacity and never destroys overflow Corpses;
  - persistent runner validates locks, earnings, purchases, toggling and queue refill.
- Manual Batch Production V1:
  - shared 1–36 quantity selector supports typing and arrow adjustment;
  - Skeleton/Zombie buttons display requested quantity and total resource cost;
  - a batch is all-or-nothing when resources or army slots are insufficient;
  - `batch_production_completed` exposes a future machine-feedback/audio hook;
  - persistent runner validates costs, counts, capacity rejection and insufficient-resource rejection.
- Army Doctrine Planning V1:
  - dedicated localized panel and lower navigation button;
  - configurable Skeleton/Zombie target composition;
  - minimum Bones/Flesh reserves and Balanced/Skeleton-first/Zombie-first priority;
  - live current-army and composition-deficit readout;
  - isolated policy validates the 36-unit cap and reserve-safe spending;
  - automatic execution was deferred until timed production queues existed;
  - persistent runner validates state, rejected configurations, reserves, deficits and localized UI.
- Timed Undead Production Queues V1:
  - manual UI orders now enter independent Skeleton Assembler and Flesh Vat queues;
  - full order cost and army capacity are reserved atomically when accepted;
  - Skeletons complete every 0.45 s and Zombies every 0.80 s;
  - each machine supports up to three pending orders and runs in parallel;
  - live localized queue counts and cycle timers are visible in the production panel;
  - queued production prevents false defeat while the army is being rebuilt;
  - persistent runner validates reservation, timing, parallel output, limits and localization.
- Army Doctrine Execution V1:
  - explicit localized start/pause control;
  - target deficits discount units already committed to production;
  - Balanced/Skeleton-first/Zombie-first planning allocates scarce population capacity;
  - minimum Bones/Flesh reserves are preserved before orders enter the timed machines;
  - pausing stops future orders without cancelling paid production;
  - persistent runner validates planning, dual-machine timing and loss replacement.
- Hematic Press V1:
  - rare-resource Factory card in a readable 3×2 control grid;
  - unlock costs 3 Factory Points;
  - each timed order converts 12 Flesh into 1 Blood over 2 seconds;
  - three-unit queue reserves Flesh immediately and exposes live progress;
  - persistent runner validates unlock, costs, queue timing, signals and localization.
- Soul Extractor and rare-resource routing V1:
  - Mage, Elf and Foreman deaths preserve arcane identity on their Corpses;
  - a 4-Factory-Point unlock enables a reversible arcane routing mode;
  - eligible Corpses can enter a separate three-slot timed Soul queue instead of material processing;
  - common Corpses continue toward the selected Bone/Flesh directive;
  - automatic collection respects the selected route and never double-queues a Corpse.
- Industrial Efficiency and Dark Refinery:
  - three upgrade levels reduce Hematic Flesh cost and Soul extraction time;
  - Hematic Press plus Efficiency II unlocks Dark Refinery;
  - Dark Refinery reduces Blood production by another 2 Flesh.
- Necromantic Economy v0.2 completion:
  - Blood generation, Blood Fervor sacrifice and Hematic/Crimson upgrades;
  - Crimson Assembly synergy reduces the recurring sacrifice cost;
  - Souls generated by Mage, Elf and Foreman kills at controlled rates;
  - playable ranged Ghost with Soul cost, health bar and magic combat;
  - Spectral Focus/Ethereal Anchor upgrades and Phantom Conduit synergy;
  - localized Ritual panel and Ghost metrics;
  - full-run Bone and Flesh strategies both defeat the Foreman;
  - rare-resource pacing reduced after automated economy evidence;
  - full interface preserved with `stretch/aspect="keep"`;
  - production actions renamed to explicit production/queue copy.

### Current Zombie V1 values

```text
HP: 220
Damage: 6
Cooldown: 1.1 s
Speed: 120
Cost: 6 Flesh
```

### Current resource values

```text
Bones per Corpse: 8
Flesh per Corpse: 2
Skeleton Cost: 5 Bones
Zombie Cost: 6 Flesh
```

### Verified

- Resource HUD no longer overlaps the production buttons.
- Skeleton Max HP restored to 100 after accidental test value.
- Skeleton combat remains functional.
- Flesh is generated correctly.
- Zombie button unlocks with sufficient Flesh.
- Zombie spawns and moves.
- Zombie attacks.
- Enemy attacks Zombie.
- Zombie dies and releases slot.
- Mixed Skeleton + Zombie army functions.
- Zombie frontline priority works.
- Defeat logic remains functional with mixed Undead.
- Zombie upgrade effects validated together in a running scene.
- Project and main scene start without parser/runtime errors after the visual pass.
- Health values and rendered bars validated for damaged Skeleton, Zombie and Enemy instances.
- Project starts correctly after all source/resource paths were reorganized.
- Wave 6 group state, independent HP, refill behavior and Wave 20 single-Boss cap validated headlessly.
- Wave 1 Warrior, Wave 8 Mage reinforcement, Wave 11 mixed group and Foreman archetype validated headlessly.
- Enemy bodies, names and health bars remain outside the right HUD rail at 1920×1080.
- Run Summary statistics, build details, synergy list and Restart action render without overlap.
- F5 Project Run and F6-compatible scene entry point share the current `main.tscn` UID.
- Wave 8 composition baseline confirms distinct Skeleton damage, Zombie durability and mixed-army performance.

### Fixed

- Active Synergies panel now contains all eight current entries without text escaping its frame; a persistent bounds runner protects the maximum list.
- Lower Factory HUD no longer extends below the usable embedded-game viewport:
  - Resources, production and Corpse-processing panels use a compact 170 px shell;
  - production controls, queue status and processing directives remain fully visible;
  - the lower conveyor detail now renders inside the safe frame;
  - regression coverage enforces a conservative `y=1015` bottom boundary.
- Enemies could spawn and fight behind the Run Metrics and Active Synergies panels.
- Long Run Summary and Active Synergies text overlapped the Restart button.
- `project.godot` referenced a stale main-scene UID after scene reimport.

### Known limitations

- Blood has no source/sink yet.
- Souls has no source/sink yet.
- Skeleton-only upgrades do not yet have Zombie equivalents.
- Mixed formation is still prototype-level.
- Skeletons still attack through the current formation abstraction.
- No ranged/magic unit yet.
- Full balance pass intentionally postponed.
- `main.gd` remains large and centralized.

---

## [0.1.0] — First Run

### Added

- Automatic combat.
- Multiple Skeletons.
- Corpses.
- Bones.
- Skeleton production.
- Waves.
- Wave scaling.
- Elite Waves.
- 10 upgrades.
- 3 random upgrade choices between Waves.
- 4 synergies.
- Run Metrics.
- Boss Wave 20.
- The Foreman.
- Industrial Crush.
- Victory.
- Game Over.
- Run Summary.
- Restart after Victory/Defeat.
- Corpse tracking for defeat logic.

### Changed

- Enemy/Boss combat moved to a controlled horizontal lane.
- Skeleton combat formation compacts after deaths.
- Combat positions are clamped to arena bounds.
- Wave progression waits for upgrade selection.

### Fixed

- Main freeze after complete army wipe.
- Boss leaving the screen due to feedback between pursuit and formation.
- Formation gaps pulling combat outside the arena.
- Premature Game Over while player still has Corpses or enough Bones to rebuild.

### Verified

- Full run from Wave 1 to Wave 20.
- Elite Waves.
- The Foreman.
- Victory flow.
- Defeat flow.
- Run Summary.
- Restart.
- Overclocked Ossuary.
- Recycling Plant.
- Second Shift.
- Bone Assembly Line unlock.

### Balance

Balance is intentionally provisional.

Known issues:

- Bones can saturate.
- Army may snowball early.
- Late-game normal Enemies can lose pressure.
- Damage/attack-speed stacking can scale strongly.
- Boss/Elites will need reevaluation after multi-unit economy exists.

---

## [0.0.3] — Waves

- Wave counter.
- Enemies per Wave.
- HP/Damage scaling.
- Elite Waves.
- Wave HUD.

## [0.0.2] — Corpse Loop

- Corpse.
- Bones.
- Skeleton production.
- Multiple Skeletons.
- Node2D migration.
- Target movement.
- Dynamic placeholders.

## [0.0.1] — Combat Prototype

- Main.
- Skeleton.
- Enemy.
- HP.
- Damage.
- Cooldown.
- Auto combat.
