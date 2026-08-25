# NecroWorks — Estado do Projeto

**Atualizado em:** 24/08/2026

**Versão funcional:** v0.4.0 — Build Diversity & Content

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
- `F6` em `main.tscn`: partida direta para desenvolvimento.
- `Esc`: pausa durante a partida.
- `F3`: alterna o painel de depuração.

Configurações são gravadas em `user://necroworks_settings.cfg`. O checkpoint da run usa `user://necroworks_run.json` com schema versionado.

## Conteúdo atual

- 20 ondas;
- Elites nas ondas 5, 9, 14 e 18;
- Marechal da Sepultura na onda 10;
- Auditor Arcano na onda 15;
- Capataz na onda 20;
- Guerreiro Humano, Mago e Elfo;
- Esqueleto Guerreiro, Arqueiro Esqueleto, Zumbi Tank, Fantasma, Lich e Servos temporários;
- 30 upgrades, incluindo três raros;
- 10 sinergias;
- cinco eventos narrativos com escolhas persistentes;
- dez descobertas vinculadas às rotas desses eventos;
- duas escolhas de Cadáver de Chefe;
- duas receitas de Fusão Necromântica;
- Fábrica, filas temporizadas, processamento, auto-coleta e Doutrina de Exército;
- Blood, Souls, Bones e Flesh com fontes e usos próprios;
- menu principal, pausa, opções, localização e checkpoint;
- interface localizada em inglês, português do Brasil e espanhol.

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

`main.gd` ainda é o orquestrador do protótipo. Regras estáveis já foram extraídas para catálogos e políticas em `scripts/`:

- `scripts/game/`: ondas, arquétipos, eventos, receitas, fusões e combate;
- `scripts/factory/`: Doutrina e produção;
- `scripts/economy/`: recursos e diretivas de processamento;
- `scripts/ui/`: componentes reutilizáveis de interface;
- `scripts/visual/`: sprites e feedback visual;
- `scripts/core/`: localização, configurações, save e shell;
- `tests/`: regressão headless por domínio.

Novas regras puras devem continuar saindo de `main.gd`. Estado de cena, coordenação de nós e apresentação podem permanecer nele até a próxima etapa de refatoração.

## Critérios de estabilidade

Antes de publicar qualquer milestone:

1. importar o projeto no Godot sem erros;
2. executar todos os `*_runner.gd` em modo headless;
3. executar `tests/balance/full_run_runner.gd` e confirmar vitória das estratégias Bone e Flesh;
4. testar F5, F6, pausa, idiomas, checkpoint e reinício manualmente;
5. revisar `git diff` e manter o worktree limpo após o push.

## Próxima etapa

A v0.4.1 será uma consolidação técnica e visual. O principal débito é `main.gd`, que chegou a 10,746 linhas e ainda concentra responsabilidades demais. A extração será incremental, preservando F5/F6, saves e os testes existentes. O mesmo milestone define sprites próprios de chefe, famílias de Cadáver, contrato de animações, fundo híbrido e o primeiro preset de exportação Windows.

Depois disso, a v0.5.0 será dedicada à meta progressão. A prioridade é criar desbloqueios que ampliem possibilidades, um Codex de unidades, inimigos e lore, histórico de runs e migração de save além do schema 1. Nenhuma progressão permanente deve virar apenas aumento numérico por repetição.

O polimento visual final, áudio, tutorial, acessibilidade e preparação comercial permanecem no escopo da v0.6.0 e v0.7.0.
