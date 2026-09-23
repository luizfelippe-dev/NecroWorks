# NecroWorks — Protocolo de Playtest

**Atualizado em:** 11/09/2026

## Objetivo

Medir se uma pessoa nova entende o ciclo Cadáver → processamento → recursos → produção → composição, reconhece a causa de uma derrota e sente vontade de iniciar outra run. O teste não serve para confirmar uma opinião existente.

## Rodadas

1. Rodada observacional com 5–10 pessoas, sem explicar controles além do que o jogo apresenta.
2. Correção dos três maiores pontos de confusão ou abandono.
3. Rodada ampliada com 20–30 pessoas e build congelada.
4. Comparação das cinco linhas estratégicas: enxame de Ossos, frontline de Carne, caster de Almas, híbrida e automação.

## Registro mínimo

Para instrumentar uma sessão, execute `NecroWorks.exe -- --measure-run`. Ao chegar à tela final, `user://playtest_latest.json` recebe o relatório local; a próxima sessão medida substitui esse arquivo. Sem a flag não há gravação. O relatório registra tempo sem pausa, combate, ociosidade de produção com recursos disponíveis, perdas e primeira mudança observada em ordens, aprimoramentos, diretriz e automação. Ordens automáticas também contam: não interpretar esse campo isoladamente como decisão humana interessante.

O escopo é o segmento da sessão atual. Continuar uma run não recupera tempos anteriores; o campo `scope` torna essa limitação explícita. Copie o relatório junto ao hash do build e às observações da pessoa. Uma saída antes da tela final não exporta relatório. A avaliação qualitativa da primeira decisão continua sendo feita pelo observador.

- versão e hash do build;
- duração, onda alcançada e resultado;
- inimigos derrotados e Cadáveres processados;
- tropas criadas/perdidas por família;
- recursos finais, diretivas, operador e contrato;
- upgrades, sinergias e causa de derrota;
- primeiro ponto de dúvida, primeiro momento satisfatório e motivo de abandono;
- intenção de jogar outra run e de recomendar.

O histórico local das vinte runs já registra a maior parte da telemetria mecânica. Observações e respostas devem ser coletadas com consentimento, sem dados pessoais desnecessários.

## Foco visual da v0.6.2

Observar marcha contínua, ataque sob dano simultâneo, diferenças entre famílias, legibilidade dos custos e entendimento da fila. Testar as dez sinergias com rolagem e os três idiomas. Registrar família, estado, resolução e trecho em vídeo quando houver rigidez, deslizamento ou deformação aparente. O shader atual não equivale a uma caminhada desenhada quadro a quadro.

## Perguntas sem indução

- Qual é o objetivo do jogo?
- Que decisão sua mais alterou o resultado?
- Por que a última luta terminou daquele jeito?
- O que você tentaria diferente na próxima run?
- O que diferencia NecroWorks de outros roguelites ou autobattlers?

## Critério para avançar à demo

- pelo menos 80% concluem o tutorial sem ajuda;
- pelo menos 70% explicam corretamente o ciclo econômico;
- pelo menos 60% identificam uma decisão que mudou a run;
- nenhuma falha bloqueante, corrupção ou perda silenciosa;
- nenhum ponto único de interface causa abandono recorrente;
- mais de uma build aparece espontaneamente entre as runs;
- a maioria entende a causa da derrota apresentada pelo jogo.

Esses números são metas internas de decisão, não garantias de vendas.
