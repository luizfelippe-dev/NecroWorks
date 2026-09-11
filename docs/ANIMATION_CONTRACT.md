# Contrato de Animações

**Atualizado em:** 11/09/2026 — v0.6.2

O combate usa cinco comandos visuais comuns. Cada unidade pode trocar a implementação procedural por spritesheets ou animações desenhadas sem alterar a lógica da partida.

| Estado | Intenção | Duração-base do protótipo |
|---|---|---:|
| `idle` | manter a unidade viva e legível | contínua |
| `move` | indicar deslocamento e direção | 0,48–0,85 s por ciclo-base, conforme a família |
| `attack` | dar continuidade e recuperação ao impacto | 0,30–0,38 s, conforme a família |
| `hit` | confirmar dano recebido | 0,14 s |
| `death` | retirar a unidade visualmente | 0,22 s |

`scripts/visual/unit_animation_driver.gd` é o adaptador atual. Ele trabalha sobre o `UnitSprite`, preserva escala, posição e cor-base e emite sinais nas transições de estado principais. O flash de dano também pode coexistir com uma ação em andamento.

## Regras para a arte final

- todas as unidades precisam dos cinco estados;
- ataques ranged acrescentam projétil/VFX sem substituir o estado `attack`;
- impactos devem ser mais rápidos que ataques e nunca esconder a barra de vida;
- chefes podem ter antecipações maiores, mas mantêm os mesmos nomes de estado;
- a morte deve entregar o ponto exato usado para criar o Cadáver;
- a animação não decide dano, cooldown, alvo ou recompensa.

Na v0.6.2, o movimento é contínuo: o driver observa a posição real da unidade e mantém uma fase de passada independente das chamadas de `play("move")`. Entrada e saída da locomoção usam aproximação suave; distância percorrida e perfil da família ajustam a cadência. O shader `unit_motion.gdshader` alterna deslocamentos locais da região inferior da textura, usando âncoras de pernas próprias para cada silhueta. Fantasmas recebem ondulação espectral em lugar do apoio de pernas.

O ataque aplica avanço, rotação curta, deformação localizada e recuperação sobre a pose V1. Seu evento chega depois que o combate resolveu o impacto; a apresentação não posterga dano para criar uma antecipação fictícia. O flash e o recuo de `hit` possuem timer independente e não interrompem movimento ou ataque.

Este passe não adiciona frames desenhados de caminhada ou ataque. O runtime deixa de criar `FrameBlend` e de repetir texturas V1 como se fossem quadros novos. A naturalidade dessa deformação ainda precisa de playtest humano, sobretudo em armas largas, capas e formações cheias. Os limites e o escopo visual estão registrados em [PRESENTATION_UPDATE.md](PRESENTATION_UPDATE.md).

## Texturas por estado

`UnitAnimationDriver.configure_state_textures()` aceita um dicionário parcial ou completo com os mesmos cinco nomes de estado. `configure_motion()` recebe o perfil procedural fornecido por `UnitSpriteCatalog`. `configure_frame_sequences()` continua aceitando pelo menos duas texturas para `move` e `attack`, mas `get_animation_sequences()` devolve um dicionário vazio para as onze famílias atuais. A interface fica reservada para sequências com quadros próprios.

Um pedido de `move` recebido durante um ciclo ativo é aceito sem reiniciar a fase. A continuidade do deslocamento real mantém a caminhada, e uma pequena tolerância impede oscilação de estado entre atualizações. Ao concluir ataque ou impacto, o driver retoma `move` se ainda observar locomoção; caso contrário, retorna a `idle`. O estado `death` bloqueia novos comandos e mantém sua textura até a saída da árvore.

Esse caminho permite integrar poses finais gradualmente. Uma unidade pode receber primeiro `idle` e `attack`, continuar usando a textura-base nos demais estados e completar o conjunto depois, sem alterar combate, dano ou cooldown.

Os arquivos em `assets/sprites/animation_concepts/` são referências de pose, não atlases prontos. A versão final deve usar frames individuais ou células uniformes com pivô dos pés idêntico. Não se deve cortar o concept sheet em cinco partes iguais: as silhuetas têm larguras diferentes e atravessam os limites visuais.

## Guerreiro Esqueleto V1

A primeira família completa está em `assets/sprites/units/skeleton_warrior_v1/`. Os cinco estados usam canvas quadrado, transparência real e importação limitada a 512 px. `UnitSpriteCatalog` entrega o conjunto ao driver; `main_controller.gd` aciona `move` durante deslocamento, `attack` no golpe, `hit` no dano e `death` antes de retirar o nó.

A pose de morte permanece por 0,24 s depois que a unidade sai das coleções de combate e libera o slot. Barra de vida e rótulo são ocultados imediatamente. Portanto, a apresentação não bloqueia reposição, Doutrina, recuperação rara ou condição de derrota.

## Zumbi Tank V1

A segunda família completa está em `assets/sprites/units/zombie_tank_v1/`. O mesmo contrato controla cinco poses independentes, mas a escala de canvas preserva a massa maior do tanque e a morte usa uma silhueta horizontal. O perfil atual adota passada mais lenta e amplitude menor; após o ataque, o estado acompanha o deslocamento observado. A morte permanece até a retirada visual.

Assim como no Esqueleto, `kill_zombie()` libera coleção, estado runtime e slot antes da espera visual de 0,24 s. Isso impede que a animação altere capacidade, reposição automática, métricas ou condição de derrota.

## Fantasma V1

A família espectral está em `assets/sprites/units/ghost_v1/`. Coleira, tubos, braceletes e núcleo de Alma preservam a origem fabril; cauda e braços definem direção e velocidade. A transparência existe dentro do material espectral, mas o PNG mantém contorno e contraste suficientes para leitura a 96 px.

O movimento usa uma silhueta lançada para frente, o ataque concentra energia entre as mãos, o impacto abre o corpo e a morte colapsa a unidade horizontalmente. `kill_ghost()` também resolve coleção e slot antes dos 0,24 s de dissipação visual.

## Guerreiro Humano V1

A primeira família inimiga completa está em `assets/sprites/units/human_warrior_v1/`. O escudo lidera o deslocamento, a espada cruza a silhueta no ataque e a abertura involuntária da guarda comunica impacto. A morte é baixa e horizontal, com arma solta e escudo junto ao corpo.

`kill_enemy()` remove o Guerreiro Humano das coleções e tabelas de combate, cria o Cadáver e atualiza a Onda antes dos 0,24 s reservados à pose final.

## Mago V1

A família arcana está em `assets/sprites/units/mage_v1/`. Cajado de duas mãos, frasco dorsal, latão, tecido violeta e silhueta estreita mantêm o papel de atacante frágil. Movimento abaixa o centro de massa; ataque concentra uma esfera pequena no cajado; impacto abre a guarda; morte apaga o olho e abandona a arma.

O rastro de ataque e a Rajada Arcana continuam no `CombatFeedback` e no `EnemyCombatPolicy`. As texturas não decidem alvo, dano em área ou supressão. `kill_enemy()` usa a mesma retirada visual de 0,24 s para Guerreiro e Mago.

## Elfo V1

A família de precisão está em `assets/sprites/units/elf_v1/`. Cabelo claro, orelhas longas, couro escuro, placas leves, tecido verde, aljava e arco recurvo mantêm uma silhueta viva e ágil. O movimento reduz a postura, o ataque tensiona o arco, o impacto quebra a base e a morte ocupa o chão com arco separado do corpo.

A textura de ataque contém apenas a flecha encaixada. Trajetória, alvo prioritário e multiplicador do Tiro de Precisão continuam no `CombatFeedback` e no `EnemyCombatPolicy`. O Elfo compartilha com Guerreiro e Mago a retirada de 0,24 s após a resolução do Cadáver.

## Marechal da Sepultura V1

O primeiro chefe completo está em `assets/sprites/bosses/grave_marshal_v1/`. Aço escuro, latão, capa carmesim, escudo em forma de lápide e cutelo de escavação contaminado sustentam uma massa visual maior que a dos invasores comuns. Avanço conserva o escudo à frente; ataque abre a guarda; impacto desloca o peso; morte espalha corpo, escudo e arma horizontalmente.

O runtime mantém altura de chefe e usa o mesmo driver das unidades comuns. Dano em área, cadência especial, recompensa e transição da Onda continuam fora da arte. `kill_enemy()` resolve o Cadáver e a progressão antes de preservar a pose final por 0,24 s.

## Auditor Arcano V1

A família arcana está em `assets/sprites/bosses/arcane_auditor_v1/`. Máscara, orelhas longas, vestes de carvão e violeta, latão, reator do cajado, frascos dorsais e documentos encantados permanecem reconhecíveis nos cinco estados. Movimento avança com o aparato compacto; ataque concentra a sentença no cajado e na mão livre; impacto desorganiza os documentos; morte distribui corpo e instrumentos horizontalmente.

A descarga de quatro alvos, a cadência especial e a decisão sobre o Núcleo continuam no combate e na narrativa. A arte não emite o projétil e não altera o encontro.

## Capataz V1

A família do chefe final está em `assets/sprites/bosses/foreman_v1/`. Ferro enegrecido, latão gasto, faixas de risco, pano vermelho, capacete, charuto, martelo-reator, manopla e reservatórios violetas sustentam a maior massa visual da run. A marcha desloca o peso; o ataque arma o golpe sem desenhar sua onda; o impacto quebra a postura; a morte deita corpo e martelo numa faixa horizontal.

O `Industrial Crush`, seus seis alvos, a conclusão da Onda 20 e o resumo da run continuam fora do driver visual. Os três chefes agora usam o mesmo contrato de cinco estados e altura ampliada.

## Movimento reduzido

Quando a preferência está ativa, `UnitAnimationDriver` zera a deformação do shader e remove oscilação ociosa, avanços e rotações. Impacto preserva apenas um flash curto; morte desaparece imediatamente. As texturas continuam identificando os estados. A mesma preferência congela a atmosfera da tela inicial, parallax, névoa e pulsos do cenário, além de eliminar o voo do token de processamento. Nenhuma dessas mudanças altera dano, cooldown ou economia.

## Integração V1

Ataques e impactos do runtime agora acionam o contrato de animação. A camada independente `CombatFeedback` complementa esses estados com traço de direção e número de dano. Anéis são reservados para habilidades, invocação, morte e presença de Chefe; não aparecem em cada golpe comum para evitar poluição visual em formações grandes.

Arqueiro Esqueleto e Lich completam o mesmo contrato com cinco PNGs RGBA cada. O Arqueiro preserva arco, flecha, aljava e silhueta de retaguarda; o Lich preserva cajado, coroa óssea e núcleo espectral. Com essas duas famílias, todas as onze apresentações atuais de aliados, invasores e chefes possuem idle, movimento, ataque, impacto e morte sem alterar a simulação.
