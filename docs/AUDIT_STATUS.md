# NecroWorks — Situação da Auditoria

**Atualizado em:** 08/09/2026

Este quadro separa correção de código, validação interna e dependências externas. Um item só recebe estado concluído quando existe implementação e evidência reproduzível.

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

| Frente | Estado | Limite conhecido |
|---|---|---|
| Famílias visuais e três chefes | V1 concluída | revisão artística final continua antes da loja |
| Fábrica legível | V1 concluída | arte física, processamento e sinais de produção integrados |
| HUD e resoluções | Base técnica concluída | QA manual com escala do Windows e ultrawide real ainda necessário |
| Onboarding e causa da derrota | V1 concluída | entendimento precisa ser observado em teste cego |
| Áudio e mixagem | Protótipo funcional | trilha e efeitos autorais finais ainda precisam ser produzidos/licenciados |
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
