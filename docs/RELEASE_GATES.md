# NecroWorks — Gates de Release

**Atualizado em:** 11/09/2026

## Gate automatizado

```powershell
.\tools\validate_release.ps1 -GodotPath "C:\caminho\Godot_v4.7.1-stable_win64_console.exe"
```

O comando executa todos os runners em ordem estável, exige marcador `PASS`, rejeita erro de script mesmo quando o processo retorna código zero, grava logs em `artifacts/validation/`, exporta o Windows release, inicia um smoke test e registra tamanho e SHA-256. A workflow `release-gate.yml` repete a regressão em Windows no GitHub Actions.

Na v0.6.2, a suíte reúne 79 runners. O teste de apresentação cobre os três idiomas, lotes de produção e mínimos reais dos controles; a regressão de sinergias verifica rolagem dentro do painel. Capturas renderizadas são produzidas por `tools/capture_presentation.gd`, sem usar o perfil de quem joga. No Windows, o smoke test espera explicitamente o processo gráfico terminar e verifica seu código de saída e os logs de erro; iniciar o processo sem esperar não conta como aprovação.

## Matriz manual antes da demo

- F5, F6, nova partida, continuar, pausa, reinício e saída;
- PT-BR, inglês e espanhol;
- 1280×720, 1600×900, 1920×1080, 16:10 e ultrawide;
- escala de Windows em 100%, 125% e 150%;
- Movimento Reduzido, Alto Contraste e volumes separados;
- save novo, migrado, corrompido, backup e atualização entre builds;
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
