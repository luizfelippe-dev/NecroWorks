# NecroWorks — Estado do Projeto

**Atualizado em:** 04/09/2026

**Versão funcional:** v0.6.0-dev — onboarding e acessibilidade básica

**Engine:** Godot 4.7.1

**Branch principal:** `main`

Este arquivo concentra o estado técnico necessário para retomar o desenvolvimento. As decisões de produto ficam em `DECISIONS.md`, a visão de gameplay em `GAME_DESIGN.md`, a estrutura em `ARCHITECTURE.md` e o plano de entregas em `ROADMAP.md`.

## Identidade

NecroWorks é um roguelite 2D de autobattler, estratégia e automação necromântica. A proposta central é derrotar invasores vivos, processar os cadáveres e transformar os materiais obtidos em uma linha de produção de mortos-vivos.

```text
Inimigo → Cadáver → Processamento → Recursos → Tropas → Upgrades → Chefes
```

A direção visual oficial está em `assets/reference/necrodesignv2.png`: horror industrial, metal escuro, verde necromântico e leitura clara de fábrica.

## Como executar

- `F5`: shell completo com menu, prólogo, opções, continuar e gameplay.
- `F6` em `scenes/world/gameplay.tscn`: partida direta para desenvolvimento. O alias `main.tscn` mantém compatibilidade com seleções antigas do editor.
- `Esc`: pausa durante a partida.
- `F3`: alterna o painel de depuração.

Configurações são gravadas em `user://necroworks_settings.cfg`, agora com schema v2 e migração transparente do v1. O checkpoint da run usa `user://necroworks_run.json` com schema v2 e migração automática de saves v1. Descobertas, projetos, desafios, loadout e histórico ficam em `user://necroworks_profile.json`, com schema v3 e migração automática dos perfis v1 e v2.

## Conteúdo atual

- 20 ondas;
- Elites nas ondas 5, 9, 14 e 18;
- Marechal da Sepultura na onda 10;
- Auditor Arcano na onda 15;
- Capataz na onda 20;
- sprites próprios para os três chefes;
- Guerreiro Humano, Mago e Elfo;
- Esqueleto Guerreiro, Arqueiro Esqueleto, Zumbi Tank, Fantasma, Lich e Servos temporários;
- 30 upgrades, incluindo três raros;
- 10 sinergias;
- cinco eventos narrativos com escolhas persistentes;
- dez descobertas vinculadas às rotas desses eventos;
- Codex localizado com dez descobertas de rota e dez registros de tropas, inimigos e chefes;
- histórico visível e persistente das 20 runs concluídas mais recentes;
- cinco projetos permanentes de Fábrica e quatro opções permanentes de loadout;
- três operadores e três contratos iniciais horizontais;
- cinco desafios operacionais acompanhados durante a run;
- duas escolhas de Cadáver de Chefe;
- duas receitas de Fusão Necromântica;
- Fábrica, filas temporizadas, processamento, auto-coleta e Doutrina de Exército;
- Blood, Souls, Bones e Flesh com fontes e usos próprios;
- menu principal, pausa, opções, localização e checkpoint;
- interface localizada em inglês, português do Brasil e espanhol.
- tutorial inicial localizado em cinco etapas, persistente e reproduzível pelas Opções;
- Movimento Reduzido e Interface de Alto Contraste aplicados em tempo real;
- VFX de ataque, dano, habilidade, morte, invocação e entrada de Chefe;
- seis sinais SFX procedurais com dez vozes simultâneas e proteção contra repetição excessiva;
- direção de arte consolidada e concept sheets de cinco estados para Guerreiro Esqueleto e Zumbi Tank;
- contrato de animação preparado para trocar texturas por estado sem tocar na simulação;
- Guerreiro Esqueleto com cinco poses de runtime, movimento, ataque, impacto e morte conectados;
- Zumbi Tank com cinco poses de runtime, escala pesada e retirada visual conectadas;
- Fantasma com identidade fabril própria, cinco poses e dissipação conectadas;
- Guerreiro Humano com cinco poses próprias e retirada visual conectada;
- Mago com cinco poses próprias, conjuração compacta e retirada visual conectada;
- Elfo com cinco poses próprias, disparo compacto e retirada visual conectada;
- Marechal da Sepultura com cinco poses próprias, escala de chefe e retirada visual conectada;
- Auditor Arcano com cinco poses próprias, aparato preservado e descarga separada da arte;
- Cadáveres visuais blindados, arcanos e ágeis, com restos próprios de chefe;
- contrato procedural de animações e preset Windows Desktop.
- fundo híbrido ilustrado com parallax atmosférico, névoa e luz procedural.

## Eventos da run

| Entrada da onda | Evento | Decisão principal |
|---:|---|---|
| 4 | Uma Oferta Silenciosa | segurança econômica ou vantagem que fortalece a Concordata de Ferro |
| 7 | Carga de Sepultura | Ossos ou Carne/Sangue |
| 11 | Restos do Marechal | reforço permanente de Zumbis ou grande lote de Ossos |
| 13 | Arcanista Cativo | Almas ou Pontos de Fábrica |
| 16 | Núcleo do Auditor | reforço espectral ou Pontos de Fábrica |

As decisões resolvidas e os modificadores permanentes são preservados no checkpoint.

## Fusões

- Liga de Ossuário: 12 Ossos + 6 Carne → 2 Pontos de Fábrica.
- Formação Vinculada: 2 Sangue + 3 Almas → 1 Fantasma sem custo de produção.

As transações são atômicas: recursos nunca são consumidos quando a receita é inválida ou não há espaço no exército.

## Arquitetura prática

`scripts/game/main_controller.gd` coordena a cena jogável. O projeto agora separa cenas, estado e regras por domínio:

- `scenes/core/`: entrada da aplicação;
- `scenes/world/`: gameplay e Cadáver;
- `scenes/units/`: cenas-base de aliados e inimigos;
- `scripts/game/`: controlador, `RunDirector`, ondas, arquétipos, eventos, receitas, fusões e combate;
- `scripts/factory/`: Doutrina e produção;
- `scripts/economy/`: recursos e diretivas de processamento;
- `scripts/ui/`: componentes reutilizáveis de interface;
- `scripts/visual/`: sprites e feedback visual;
- `scripts/audio/`: identidade sonora, pools e roteamento de eventos;
- `scripts/core/`: localização, configurações, save e shell;
- `tests/`: regressão headless por domínio.

`RunDirector` é a fonte do estado da Onda e do resultado da run. `RunSummaryFormatter` monta a apresentação final sem conhecer nós da cena. `CombatFormationPolicy` concentra geometria e posicionamento; `CombatRuntimeCoordinator` concentra seleção comum, aplicação de dano e limpeza de estado; `UndeadArmyRegistry` concentra coleções, capacidade e ocupação dos slots. `GameplayHudPresenter` formata HUD e métricas, enquanto `GameplayPanelCoordinator` garante exclusividade entre Fábrica, Doutrina, Rituais, Fusões e modais. `UpgradeCatalog`, `SynergyCatalog`, `MetaUnlockCatalog`, `OperatorCatalog`, `StartingModifierCatalog` e `ChallengeCatalog` concentram progressão e requisitos estáveis. As APIs de compatibilidade continuam ativas para preservar saves, cenas e testes durante a migração.

## Critérios de estabilidade

Antes de publicar qualquer milestone:

1. importar o projeto no Godot sem erros;
2. executar todos os `*_runner.gd` em modo headless;
3. executar `tests/balance/full_run_runner.gd` e confirmar vitória das estratégias Bone e Flesh;
4. testar F5, F6, pausa, idiomas, checkpoint e reinício manualmente;
5. validar integridade das 422 chaves nos três idiomas;
6. revisar `git diff` e manter o worktree limpo após o push.

## Próxima etapa

A v0.5.0 está concluída e a v0.6.0 já possui onboarding, acessibilidade, apresentação audiovisual V1, direção de arte consolidada, três tropas, os três invasores básicos, Marechal e Auditor animados por estados. O perfil v3 acompanha progresso durante a própria run, enquanto o settings v2 guarda tutorial e acessibilidade sem misturar esses dados com a partida. O catálogo localizado possui 422 chaves completas em inglês, português do Brasil e espanhol, verificadas automaticamente. Os próximos blocos da vertical slice são Capataz e arte da Fábrica, além de áudio produzido, música, revisão editorial e medição de performance externa.

O build local v0.6.0-dev validado está em `builds/windows/NecroWorks.exe`, fora do Git, com 119.231.312 bytes e SHA-256 `82D2ADA7DDB62F4806D7DFC6A5A1DCE8194903ACFC746108A96C2282E8B01D0F`. Fontes de conceito, documentação, testes e os protótipos substituídos do Auditor, Marechal, Guerreiro Humano, Mago, Elfo, Esqueleto e Zumbi estão excluídos do pacote. Os templates oficiais Windows do Godot 4.7.1 permanecem instalados localmente.

O polimento visual final, áudio, acessibilidade ampliada e preparação comercial permanecem no escopo da v0.6.0 e v0.7.0.
