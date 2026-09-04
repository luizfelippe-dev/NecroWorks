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

## Guerreiro Esqueleto V1

A primeira família completa está em `assets/sprites/units/skeleton_warrior_v1/`. Os cinco estados usam canvas quadrado, transparência real e importação limitada a 512 px. `UnitSpriteCatalog` entrega o conjunto ao driver; `main_controller.gd` aciona `move` durante deslocamento, `attack` no golpe, `hit` no dano e `death` antes de retirar o nó.

A pose de morte permanece por 0,24 s depois que a unidade sai das coleções de combate e libera o slot. Barra de vida e rótulo são ocultados imediatamente. Portanto, a apresentação não bloqueia reposição, Doutrina, recuperação rara ou condição de derrota.

## Zumbi Tank V1

A segunda família completa está em `assets/sprites/units/zombie_tank_v1/`. O mesmo contrato controla cinco poses independentes, mas a escala de canvas preserva a massa maior do tanque e a morte usa uma silhueta horizontal. Movimento, ataque e impacto retornam ao idle; a morte permanece até a retirada visual.

Assim como no Esqueleto, `kill_zombie()` libera coleção, estado runtime e slot antes da espera visual de 0,24 s. Isso impede que a animação altere capacidade, reposição automática, métricas ou condição de derrota.

## Fantasma V1

A família espectral está em `assets/sprites/units/ghost_v1/`. Coleira, tubos, braceletes e núcleo de Alma preservam a origem fabril; cauda e braços definem direção e velocidade. A transparência existe dentro do material espectral, mas o PNG mantém contorno e contraste suficientes para leitura a 96 px.

O movimento usa uma silhueta lançada para frente, o ataque concentra energia entre as mãos, o impacto abre o corpo e a morte colapsa a unidade horizontalmente. `kill_ghost()` também resolve coleção e slot antes dos 0,24 s de dissipação visual.

## Guerreiro Humano V1

A primeira família inimiga completa está em `assets/sprites/units/human_warrior_v1/`. O escudo lidera o deslocamento, a espada cruza a silhueta no ataque e a abertura involuntária da guarda comunica impacto. A morte é baixa e horizontal, com arma solta e escudo junto ao corpo.

`kill_enemy()` remove o Guerreiro Humano das coleções e tabelas de combate, cria o Cadáver e atualiza a Onda antes dos 0,24 s reservados à pose final. Mago, Elfo e Chefes continuam usando o fallback procedural até receberem famílias próprias.

## Movimento reduzido

Quando a preferência está ativa, `UnitAnimationDriver` remove idle, avanços, rotações e mudanças de escala. Impacto preserva apenas um flash curto e morte preserva o desaparecimento imediato, porque ambos comunicam estado essencial. A mesma preferência congela parallax, névoa e pulsos do cenário, além de eliminar o voo do token de processamento. Nenhuma dessas mudanças altera duração de ataque, dano ou cooldown.

## Integração V1

Ataques e impactos do runtime agora acionam o contrato de animação. A camada independente `CombatFeedback` complementa esses estados com traço de direção e número de dano. Anéis são reservados para habilidades, invocação, morte e presença de Chefe; não aparecem em cada golpe comum para evitar poluição visual em formações grandes.
