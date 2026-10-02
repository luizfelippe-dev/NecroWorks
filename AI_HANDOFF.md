# NecroWorks — Continuidade do Desenvolvimento

**Atualizado em:** 02/10/2026

## Estado atual

A v0.6.2 preserva a vertical slice técnica e revisa sua apresentação: menu ilustrado, HUD industrial com cartões e métricas alinhadas, sinergias roláveis e movimento procedural contínuo nas onze famílias. O ataque não é mais cancelado pelo flash de dano. Não foram produzidos frames novos de personagens; o shader trabalha sobre as poses V1, e a naturalidade ainda precisa de avaliação em uma run manual. Regras, economia e balanceamento permanecem intactos.

A auditoria de 14/09 reabriu confiabilidade, apresentação e validação comercial. O primeiro corte torna gameplay e temporizadores pausáveis, isola os checkpoints de testes e corrige o caminho consultado por Continuar. A auditoria anterior e seu gate técnico não comprovam prontidão comercial. Todos os novos itens e critérios estão na abertura de `docs/ROADMAP.md` (v0.6.3–v0.6.6).

## Ordem de continuação

02/10 — essência arcana: a cabeça da fila emite uma esfera até o extrator usando o timer existente (trajeto até 65%, concentração no restante). O corpo não é ocultado. Sinais de conclusão confirmam Sangue/Almas no painel de recursos, sem crédito adicional. Movimento reduzido dispensa viagens. Regressão cobre referência destruída, sucessão, preparação e reconstrução do apresentador. Arte final das máquinas e animação de personagens continuam abertas.

02/10 — refinaria: `RareRefineryVisual` apresenta Sangue e Almas a partir dos timers reais. Indicadores procedurais só aparecem após desbloqueio, respeitam preparação e movimento reduzido, sem escrever em economia ou saves. Capturas `--refinery` usam perfil descartável com desbloqueios explícitos; gameplay normal conserva a progressão. CI 37010427159 do commit 615aaaf aprovado. Este corte é funcional, não arte final das máquinas; transporte arcano e confirmação de saída ainda pendentes.

02/10 — oficina de tropas integrada por `UndeadWorkshopVisual`: lê filas, receitas e timers; anima montagem e cuba, confirma unidade criada sem alterar economia ou saves. Capturas 1280×720 verificadas e regressão dedicada. CI anterior 37009011996 confirmado como sucesso. Próximos cortes: Sangue/Almas, animação de personagem aprovada e setores distintos. Não declarar a revisão de experiência encerrada.

02/10: confirmado sucesso remoto do commit 6e8d823 (run 36926406429). Transferência visual de materiais integrada: cabeça da fila sai visualmente do campo, percorre a entrada e é prensada sem duplicação. Visibilidade restaurada ao retirar reserva/apresentador. Pausa, modo reduzido, proporção da carga e sucessão da fila cobertos. O ciclo não ganhou tempo extra: upgrades rápidos encurtam também a animação. Próximos cortes continuam sendo outras rotas, animação de personagem aprovada e setores distintos; não confundir trajetória de sprite com animação final de coletor físico.

Novo corte de 01/10: CI corrigido e execução remota 36925391852 aprovada. O gate resolve hardlinks sem extensão e usa logs nativos após importação. Cadáveres agora usam `death.png` com AtlasTexture cacheada. `MaterialProcessorVisual` lê a fila real e anima entrada/prensa/saída com arte própria; não altera economia. Falta transferência física (o corpo ainda fica marcado em fila no campo), arte/animação de outras máquinas, família de animação aprovada e cenários distintos. A revisão de experiência no topo do roadmap passa a orientar os próximos cortes.

Em 01/10, a narrativa da v0.6.5 entrou nos cinco eventos existentes: revelação antecipada, falas condicionadas às escolhas e epílogo de vitória com variante do núcleo. Catálogo deriva as falas do histórico já salvo; nenhum schema novo. As duas colunas do fim de run têm rolagem. Próximos focos: animação autoral, identidade sonora e avaliação humana de ritmo/chefes. Não declarar v0.6.4 ou v0.6.5 completas.

Novo corte de 23/09: especiais deixaram de escolher alvos aleatórios. Marechal pressiona proximidade, Auditor distância e Capataz agrupamento de raio 180. Avisos têm antecedência mínima de um segundo e proteção contra saturação de feedback. Não há esquiva manual: revisar composição, reposição e perdas em uma run humana antes de aprovar contrajogo/balanceamento. Os alvos são determinados no impacto, não travados no aviso. A v0.6.5 continua aberta.

Em 23/09 entraram escala de textos táticos (settings v5), medição opcional por segmento e prioridade de áudio de chefe. Ambas as versões 0.6.4 e 0.6.5 seguem abertas: não confundir instrumentação com medição humana concluída nem escala de alguns textos com toda a interface. Próximo trabalho: ritmo inicial, escala dos demais controles, mecânicas próprias dos chefes e produção/aprovação de uma família de animação.

O painel operacional, a alternância com histórico e as prévias de sinergia nas cartas já foram implementados em 17/09. O diagnóstico considera preparação e cadáveres reservados para extração. Não marcar escala configurável, medição da primeira decisão ou aprovação com jogadores como concluídas por essas mudanças.

1. seguir v0.6.4 por escala de interface e medição da primeira decisão; preparação, primeiro ciclo, consulta de sinergias e diagnóstico de gargalos já estão implementados;
2. preservar a suíte de confiabilidade e as fronteiras de apresentação concluídas na v0.6.3;
3. validar a experiência em run manual; o aceite técnico não certifica hardware mínimo nem prontidão comercial;
4. aprovar animação autoral de uma família e validar as novas ameaças espaciais dos chefes;
5. revisar cartas, automação e testes de equilíbrio com investimentos equivalentes;
6. medir release real e conduzir teste cego antes da preparação Steam.

## Comandos

Narrativa, fábrica, rituais, doutrina, modificadores e loadout já possuem validação defensiva antes da restauração. O shell informa recuperação/proteção e falhas de gravação em três idiomas, com nova tentativa e pausa em caso de falha durante a run. As métricas por rota persistem no checkpoint; distribuição desconhecida de saves antigos é identificada como tal. A migração v1→v2 continua necessária e não deve ser removida.

```powershell
.\tools\validate_release.ps1 -GodotPath "C:\caminho\Godot_v4.7.1-stable_win64_console.exe"
```

- `F5`: aplicação completa.
- `F6`: gameplay direto.
- `Esc`: pausa.
- `F3`: depuração.

## Documentos principais

- `docs/RENDERED_PROFILING.md`: cenário reproduzível, comparação local de frames e limites da medição;

- `docs/PRESENTATION_UPDATE.md`: escopo, limitações e evidências da apresentação v0.6.2;
- `docs/PROJECT_STATE.md`: estado técnico;
- `docs/ROADMAP.md`: ordem e marcos;
- `docs/GAME_DESIGN.md`: regras e balanceamento;
- `docs/LORE.md`: mundo e narrativa;
- `docs/ARCHITECTURE.md`: fronteiras de código;
- `docs/ASSET_PROVENANCE.md`: origem e revisão dos assets;
- `docs/PLAYTEST_PROTOCOL.md`: validação com jogadores;
- `docs/RELEASE_GATES.md`: critérios de build e publicação.
