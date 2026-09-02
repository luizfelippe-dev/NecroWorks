# Contrato de Áudio

O áudio de combate usa seis IDs estáveis. A implementação atual sintetiza efeitos curtos ao abrir a cena para validar ritmo e prioridade sem depender de arquivos provisórios.

| ID | Uso | Prioridade |
|---|---|---:|
| `attack` | ataque comum aliado ou inimigo | baixa |
| `hit` | dano confirmado | baixa |
| `death` | unidade removida | média |
| `ability` | habilidade arcana ou invocação | alta |
| `boss` | entrada, especial ou morte de Chefe | máxima |
| `wave` | começo de Onda comum | média |

`CombatAudioManager` cria os streams uma vez, reutiliza dez players e alterna levemente o pitch. Ataque e impacto possuem cooldown próprio para que uma formação inteira não dispare dezenas de sons no mesmo frame. Todos os players usam o barramento `Master`, respeitando a opção de volume existente.

## Troca por áudio final

Os IDs e chamadas permanecem iguais. A produção final pode substituir cada `AudioStreamWAV` por arquivos importados, acrescentar buses próprios de SFX e música e ajustar compressão sem tocar na resolução do combate. Sons finais precisam ser originais ou possuir licença comercial registrada em `ASSET_PROVENANCE.md`.

## Regras de mixagem

- Chefe e habilidade precisam atravessar a massa sem exigir volume desconfortável;
- ataque e impacto comuns não podem encobrir decisões entre Ondas;
- morte deve confirmar remoção sem competir com o alerta de Chefe;
- pausar e abrir opções deve manter controle pelo volume Master;
- Movimento Reduzido altera movimento visual, não remove informação sonora.
