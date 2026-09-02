# Contrato de Animações

O combate usa cinco estados visuais comuns. Cada unidade pode trocar a implementação provisória por spritesheets ou animações desenhadas sem alterar a lógica da partida.

| Estado | Intenção | Duração-base do protótipo |
|---|---|---:|
| `idle` | manter a unidade viva e legível | contínua |
| `move` | indicar deslocamento e direção | 0,16 s por impulso |
| `attack` | antecipação curta e avanço no golpe | 0,18 s |
| `hit` | confirmar dano recebido | 0,15 s |
| `death` | retirar a unidade visualmente | 0,22 s |

`scripts/visual/unit_animation_driver.gd` é o adaptador atual. Ele trabalha sobre o `UnitSprite`, preserva escala, posição e cor-base e emite sinais no começo e no fim de cada ação.

## Regras para a arte final

- todas as unidades precisam dos cinco estados;
- ataques ranged acrescentam projétil/VFX sem substituir o estado `attack`;
- impactos devem ser mais rápidos que ataques e nunca esconder a barra de vida;
- chefes podem ter antecipações maiores, mas mantêm os mesmos nomes de estado;
- a morte deve entregar o ponto exato usado para criar o Cadáver;
- a animação não decide dano, cooldown, alvo ou recompensa.

O componente atual fornece movimento procedural mínimo. Spritesheets finais serão conectados por trás desta interface durante o polimento da vertical slice.

## Texturas por estado

`UnitAnimationDriver.configure_state_textures()` aceita um dicionário parcial ou completo com os mesmos cinco nomes de estado. Ao iniciar uma ação, o driver troca a textura antes do tween; ao concluir `move`, `attack` ou `hit`, restaura `idle`. O estado `death` mantém sua textura até a unidade sair da árvore.

Esse caminho permite integrar poses finais gradualmente. Uma unidade pode receber primeiro `idle` e `attack`, continuar usando a textura-base nos demais estados e completar o conjunto depois, sem alterar combate, dano ou cooldown.

Os arquivos em `assets/sprites/animation_concepts/` são referências de pose, não atlases prontos. A versão final deve usar frames individuais ou células uniformes com pivô dos pés idêntico. Não se deve cortar o concept sheet em cinco partes iguais: as silhuetas têm larguras diferentes e atravessam os limites visuais.

## Movimento reduzido

Quando a preferência está ativa, `UnitAnimationDriver` remove idle, avanços, rotações e mudanças de escala. Impacto preserva apenas um flash curto e morte preserva o desaparecimento imediato, porque ambos comunicam estado essencial. A mesma preferência congela parallax, névoa e pulsos do cenário, além de eliminar o voo do token de processamento. Nenhuma dessas mudanças altera duração de ataque, dano ou cooldown.

## Integração V1

Ataques e impactos do runtime agora acionam o contrato de animação. A camada independente `CombatFeedback` complementa esses estados com traço de direção e número de dano. Anéis são reservados para habilidades, invocação, morte e presença de Chefe; não aparecem em cada golpe comum para evitar poluição visual em formações grandes.
