# NecroWorks v0.6.0 — Aceite da Vertical Slice

**Fechada em:** 08/09/2026

## Promessa comprovada

Uma run completa demonstra o diferencial de NecroWorks: invasores mortos viram Cadáveres, Cadáveres entram na Fábrica, recursos alimentam receitas e a composição produz uma resposta diferente para a onda seguinte.

## Escopo aceito

- shell completo com Nova Partida, Continuar, Opções, Codex, histórico, loadout e pausa;
- 20 ondas, Elites, três chefes, eventos, upgrades, sinergias e dois finais;
- cinco famílias permanentes do exército e três arquétipos básicos de invasor;
- Fábrica, processamento, produção em lote, Doutrina, automação e quatro recursos;
- progressão horizontal, operadores, contratos, desafios e descobertas;
- PT-BR, inglês e espanhol com integridade automatizada;
- tutorial, Movimento Reduzido e Alto Contraste;
- onze famílias visuais com cinco estados, Cadáveres, cenário, maquinário e VFX;
- nove sinais SFX, ambiente industrial e volumes separados;
- checkpoint e perfil transacionais, migrações, backup e diagnóstico de derrota;
- exportação Windows reproduzível, smoke test e CI.

## Critérios aprovados

- suíte integral sem erro de parser/runtime e com marcador `PASS` por cenário;
- runs determinísticas completas de Ossos e Carne;
- matriz de cinco builds resolvida sem timeout;
- horda máxima de 36 unidades dentro do orçamento headless de diagnóstico;
- seis resoluções sem corte do viewport lógico;
- catálogo localizado sem chave duplicada, ausente ou vazia;
- build release inicia fora do editor e possui hash registrado.

## Evidência final

- Godot: `4.7.1.stable.official.a13da4feb`;
- regressão: 78 runners aprovados em 73,22 segundos;
- Windows release: 122.944.360 bytes;
- SHA-256: `7DBEAD6A35314013D62E60A08A22B8588EA0D84C63697186C9A82739E3498B13`.

## Fora do aceite técnico

Esta entrega não afirma que o jogo está pronto para venda. Revisão linguística nativa, playtest cego, trilha e efeitos comerciais finais, direitos dos assets, perfil em hardware real, instalação limpa e integração Steam pertencem à v0.7.0. Esses gates estão documentados e não são mascarados como testes automatizados.
