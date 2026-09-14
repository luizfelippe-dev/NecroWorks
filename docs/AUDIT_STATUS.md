# NecroWorks — Situação da Auditoria

**Atualizado em:** 14/09/2026

Este quadro separa correção de código, validação interna e dependências externas. Um item só recebe estado concluído quando existe implementação e evidência reproduzível.

## Reabertura — 14/09/2026

As tabelas seguintes preservam o fechamento histórico de 08–11/09. A nova auditoria encontrou lacunas internas e reabre o aceite de confiabilidade e experiência. A ordem completa e os critérios estão em `ROADMAP.md`, v0.6.3–v0.6.6.

| Frente | Estado atual | Evidência / próximo corte |
|---|---|---|
| Pausa e tutorial | Corrigida neste corte | gameplay pausável; relógio/posições congelados por frames e retomada verificados |
| Reposição durante pausa | Corrigida neste corte | timer pausável permanece pendente e conclui após retomar |
| Save pessoal nos testes de shell/tutorial | Corrigida neste corte | caminhos de perfil, settings e checkpoint separados; Continuar usa caminho injetado |
| Evento inválido na retomada | Corrigida | ID/escolha anterior, tipos e escolha pertencente ao evento validados; backup e rejeição sem mutação cobertos pelo runner de integridade narrativa |
| Subcampos de checkpoint | Corrigida | fábrica, rituais, doutrina, modificadores e loadout com tipos/limites; runner cobre capacidade, defaults legados, preservação do arquivo e fallback |
| Feedback de persistência e métricas por rota | Corrigida | avisos localizados com nova tentativa; autosave falho pausa; distribuição persistida e legado identificado como desconhecido |
| Debug oculto | Corrigida | não monta texto nem analisa recuperação até ficar visível |
| HUD duplicado | Corrigida neste corte | labels e formatadores legados removidos; testes verificam dashboard visível; comparação renderizada documentada |
| Acoplamento de apresentação | Extração pontual concluída | produção/processamento/filas recebem snapshots puros; custos, bloqueios, lotes e idiomas cobertos; sem reescrita geral do controlador |
| Ritmo, builds, chefes e automação | Pendente | preparação utilizável, escolhas distintas e metas por receita |
| Animação, áudio, HUD e narrativa | Pendente | aprovação em movimento e sessão real, não somente poses/capturas |
| Performance, resoluções e equilíbrio | Pendente | ampliar testes parciais com renderização, custos equivalentes e pessoas novas |

Não há nova aprovação comercial nem fechamento da v0.6.3 neste corte.

Validação do corte: 79 runners passaram no gate com `-SkipExport`; a regressão de shell passou novamente após incluir a fila de produção. Não foi gerado novo executável e ainda falta inspeção manual dos menus e da pausa.

Validação do corte narrativo seguinte: 80 runners aprovados com `-SkipExport`, inclusive recuperação de JSON semanticamente inválido e migração v1→v2. Importação headless do editor aprovada; não houve novo export.

Validação dos campos operacionais: 81 runners aprovados com `-SkipExport`, incluindo defaults legados, limites e preservação do arquivo saudável; importação headless aprovada. Avisos de persistência e métricas por rota continuam pendentes.

O corte seguinte resolve esses avisos e métricas, chegando a 82 runners e 443 chaves localizadas. `persistence_feedback_runner.gd` cobre falha de autosave com pausa, nova tentativa, histórico em memória, perfil protegido, recuperação e rotas antigas. Capturas renderizadas em 1280×720 nos três idiomas ficam em `artifacts/presentation/persistence_*.png`. A consolidação das labels do HUD e a medição de frames reais permanecem abertas.

## Fase A — Confiabilidade

| Frente | Estado | Evidência |
|---|---|---|
| Gravação transacional | Concluída | arquivo temporário validado, backup e recuperação |
| Checkpoint de onda | Concluída | retomada restaura o início da onda, sem ganhos parciais |
| Schema e migrações | Concluída | validação de tipos, limites, IDs, filas e schemas futuros |
| Derrota e recuperação | Concluída | avaliador único considera exército, filas, recursos, capacidade e receitas |
| Falha, save/load e recompensa | Concluída | regressões de corrupção, escrita recusada, restore e não duplicação |
| Gate de release | Concluída | comando único, logs, CI, exportação e smoke test Windows |

## Fase B — Vertical slice

**Milestone técnica:** concluída como v0.6.0 em 08/09/2026. O aceite não absorve gates humanos ou comerciais.

**Build atual de playtest:** v0.6.2, com menu/HUD renovados, movimento contínuo e 79 regressões aprovadas. O passe v0.6.1 não encerrou o problema de naturalidade; a nova solução procedural segue sujeita à avaliação humana e não inclui frames desenhados novos.

| Frente | Estado | Limite conhecido |
|---|---|---|
| Famílias visuais e três chefes | V1 concluída | revisão artística final continua antes da loja |
| Fábrica legível | V1 concluída | arte física, processamento e sinais de produção integrados |
| HUD e resoluções | Base técnica concluída | QA manual com escala do Windows e ultrawide real ainda necessário |
| Onboarding e causa da derrota | V1 concluída | entendimento precisa ser observado em teste cego |
| Áudio e mixagem | V1 aceita | camada procedural suficiente para a slice; produção comercial segue na v0.7.0 |
| Balanceamento interno | Linha de base concluída | cinco builds automatizadas; diversão e dominância exigem jogadores e múltiplas sementes |
| Desempenho interno | Smoke concluído | meta de FPS depende de build release em hardware mínimo e recomendado |

## Gates externos

As fases abaixo não podem ser encerradas somente com alterações no repositório:

- testes cegos com pessoas que não conhecem o jogo;
- revisão editorial nativa de PT-BR, inglês e espanhol;
- teste em máquinas físicas, escalas de Windows e instalação limpa;
- confirmação de direitos comerciais, créditos e declaração de uso de IA;
- cadastro, página, depot, Playtest e revisão no Steamworks;
- produção das cápsulas, screenshots e trailer com gameplay final;
- validação de atualização, rollback e hotfix pela Steam.

Os procedimentos para executar essas etapas estão em `PLAYTEST_PROTOCOL.md` e `RELEASE_GATES.md`.
