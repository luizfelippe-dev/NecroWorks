# Contrato de Áudio

O áudio usa nove IDs estáveis e uma camada ambiente industrial. A implementação atual sintetiza sinais curtos e um loop de oito segundos para validar ritmo, prioridade e mixagem sem depender de arquivos provisórios.

| ID | Uso | Prioridade |
|---|---|---:|
| `attack` | ataque comum aliado ou inimigo | baixa |
| `hit` | dano confirmado | baixa |
| `death` | unidade removida | média |
| `ability` | habilidade arcana ou invocação | alta |
| `boss` | entrada, especial ou morte de Chefe | máxima |
| `wave` | começo de Onda comum | média |
| `processing` | Cadáver recebido e processado | média |
| `production` | unidade concluída pela linha | média |
| `machine_blocked` | máquina sem recurso, vaga ou capacidade | alta |

`CombatAudioManager` cria os streams uma vez, reutiliza dez players e alterna levemente o pitch. Ataque e impacto possuem cooldown próprio para que uma formação inteira não dispare dezenas de sons no mesmo frame. Efeitos usam `SFX`, ambiente usa `Music` e a interface possui `UI`; os três barramentos permanecem subordinados ao `Master` e têm controles persistentes próprios.

## Troca por áudio final

Os IDs e chamadas permanecem iguais. A produção final pode substituir cada `AudioStreamWAV` e o ambiente procedural por arquivos importados sem tocar na resolução do combate. Sons e música finais precisam ser originais ou possuir licença comercial registrada em `ASSET_PROVENANCE.md`.

## Regras de mixagem

- Chefe e habilidade precisam atravessar a massa sem exigir volume desconfortável;
- ataque e impacto comuns não podem encobrir decisões entre Ondas;
- morte deve confirmar remoção sem competir com o alerta de Chefe;
- pausar e abrir opções deve manter controle pelo volume Master;
- Movimento Reduzido altera movimento visual, não remove informação sonora.
