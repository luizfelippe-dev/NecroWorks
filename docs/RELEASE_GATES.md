# NecroWorks — Gates de Release

**02/10 — transporte:** 87/87 runners em 122,71 s; exportação e smoke Windows aprovados. Build: 126.437.744 bytes, SHA-256 `89651C217017E5E7FEB30B5598F210C44403E53B65141F2D0E38AE4FB6A28FCC`. Capturas 1280×720 inspecionadas. O commit anterior 6e8d823 também passou remotamente na execução 36926406429. Dados abaixo são históricos.

Gate mais recente, 01/10 — prensa: 87/87 runners em 93,85 s, exercitando hardlink sem extensão; exportação e smoke Windows aprovados. Build: 126.436.704 bytes, SHA-256 `CEAB6E1F991AFFCB98A28F464DB5559DC20730FFD72EBDE0C491BF08E9D0BF7A`. Três fases da prensa capturadas a 1028×578. A correção de CI já passou remotamente em 36925391852; o resultado abaixo antecede este corte. Testes técnicos não aprovam diversão nem encerram animação autoral.

Validação atual de 01/10: 86/86 runners em 96,13 s; exportação e smoke test Windows aprovados. Executável com 125.048.192 bytes e SHA-256 `62BB73449F4D698ECBF09F77B12416594F192EA2B5FBF960F0362081D6909422`. Incidente contextual e epílogo capturados em 720p nos três idiomas; regressão narrativa reexecutada após ajuste de atualização visual na troca de idioma. Aceite completo de v0.6.4/v0.6.5 continua aberto. As notas datadas abaixo são históricas.

**Atualizado em:** 15/09/2026

Atualização de 17/09: 86/86 runners em 110,46 s; exportação e smoke test aprovados. Build: 125.035.880 bytes, SHA-256 `550FBCE17665586410935A5B6E762784091DAFAE2F9F440D3A54E5CC23CC1C45`. HUD e cartas capturados nos três idiomas a 1280×720; alternância operação/histórico, preparação e prévias sem mutação cobertas pelas regressões. Os números de 15/09 abaixo são históricos.

## Gate automatizado

Correção de CI em 01/10: a execução 36923892079 produziu 86 logs vazios usando o atalho para o Godot gráfico. O gate agora resolve o executável, aguarda cada processo, registra pelo `--log-file`, limita cada etapa a dez minutos e importa o projeto antes da regressão. A correção foi exercitada localmente com o executável gráfico, não apenas com o console. Log ausente/vazio interrompe o gate com diagnóstico da ferramenta.

```powershell
.\tools\validate_release.ps1 -GodotPath "C:\caminho\Godot_v4.7.1-stable_win64_console.exe"
```

O comando executa todos os runners em ordem estável, exige marcador `PASS`, rejeita erro de script mesmo quando o processo retorna código zero, grava logs em `artifacts/validation/`, exporta o Windows release, inicia um smoke test e registra tamanho e SHA-256. A workflow `release-gate.yml` repete a regressão em Windows no GitHub Actions.

Na v0.6.2, a suíte reúne 79 runners. O teste de apresentação cobre os três idiomas, lotes de produção e mínimos reais dos controles; a regressão de sinergias verifica rolagem dentro do painel. Capturas renderizadas são produzidas por `tools/capture_presentation.gd`, sem usar o perfil de quem joga. No Windows, o smoke test espera explicitamente o processo gráfico terminar e verifica seu código de saída e os logs de erro; iniciar o processo sem esperar não conta como aprovação.

## Matriz manual antes da demo

O corte inicial da v0.6.4 acrescenta `wave_preparation_runner.gd`: a fase precisa sobreviver ao checkpoint, congelar relógios e filas, localizar o painel e rejeitar início duplicado. A suíte de run completa deve acionar o início explicitamente; vitória automática não pode depender de tempo gratuito na preparação.

`contextual_tutorial_runner.gd` executa o primeiro ciclo usando ações reais, verifica persistência/retorno, três idiomas, descarte e evento antecipado. A captura renderizada deve confirmar que o cartão não cobre aliado, cadáver nem controles necessários ao objetivo atual.

`decision_clarity_runner.gd` protege a ordenação e os requisitos das dez sinergias e percorre os diagnósticos de fluxo com snapshots puros. `synergy_bounds_runner.gd`, localização e layout continuam obrigatórios para comprovar rolagem, textos traduzidos e separação da barra inferior.

Execução mais recente de 15/09: 86/86 runners em 89,33 s; 485 chaves localizadas; exportação e smoke test aprovados. Executável com 125.031.320 bytes e SHA-256 `8A2B1E5930C5B3449E91CB54687A15A81DB214ADE65D00742FC892FC6EC89A04`. Preparação, primeiro ciclo e consulta de sinergias foram inspecionados em 1280×720; isso ainda não substitui a matriz manual nem um playtest externo.

Na consolidação técnica v0.6.3, a suíte passa a 83 runners. O novo `production_controls_presenter_runner.gd` valida snapshots sem mutação, limites de recursos/capacidade/ordens, arqueiro bloqueado, fim de partida, lotes 1/10 e textos nos três idiomas. As regressões integradas de produção e layout continuam obrigatórias.

Execução de 14/09 após a extração: 83/83 em 85,06 s, exportação e smoke test headless aprovados. Executável local: 125.010.512 bytes, SHA-256 `E5DC5982EF13369745B1A4E02D63F5622AE5052C1A240B3F31879468D9ADD9B2`. A exportação reflete o workspace, incluindo ajustes locais preexistentes em `main.tscn` e `project.godot`, que não fazem parte deste commit. Não é uma nova medição renderizada.

A medição com desenho real é descrita em `RENDERED_PROFILING.md`. Deve rodar fora do gate headless, sem outros testes em paralelo; registrar renderer, janela, viewport, seed e composição final junto aos percentis. A amostra local não define requisitos mínimos.

A consolidação pós-auditoria acrescenta testes de pausa por frames, validação semântica e avisos de persistência. `tests/core/persistence_feedback_runner.gd` pode receber `-- --capture` em execução renderizada para gerar evidências dos avisos em `artifacts/presentation/`. Os arquivos de teste são isolados. A aprovação desses testes não substitui a matriz manual abaixo.

- F5, F6, nova partida, continuar, pausa, reinício e saída;
- PT-BR, inglês e espanhol;
- 1280×720, 1600×900, 1920×1080, 16:10 e ultrawide;
- escala de Windows em 100%, 125% e 150%;
- Movimento Reduzido, Alto Contraste e volumes separados;
- save novo, migrado, corrompido, backup e atualização entre builds;
- falha de gravação: aviso, pausa, confirmação, nova tentativa e retorno ao jogo;
- distribuição das rotas após Continuar e categoria desconhecida de checkpoints antigos;
- cinco builds, três chefes, eventos, fusões e todos os finais;
- instalação limpa em hardware mínimo e recomendado ainda a definir;
- depot Steam, overlay, Cloud e controle somente quando implementados.

## Severidade

- Bloqueante: crash, perda de progresso, softlock ou conteúdo anunciado inacessível.
- Alta: quebra recorrente de combate, save, tradução ou interface essencial.
- Média: problema claro com alternativa segura.
- Baixa: acabamento sem impacto no resultado ou entendimento.

Uma release candidate exige zero bloqueante e zero alta conhecida. Correções depois do freeze recebem versão, regressão completa e novo hash.

## Operação

Manter o build anterior disponível, notas de migração, canal de relato de bugs, modelo de reprodução e procedimento documentado de rollback/hotfix. O lançamento só é autorizado depois dos gates técnicos, externos, legais e comerciais; a aprovação da Valve não substitui QA próprio.
