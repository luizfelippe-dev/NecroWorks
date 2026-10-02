# Proveniência dos Assets

## Refinaria e guerreiro V2 — 02/10/2026

Gerados com a ferramenta integrada de imagens da OpenAI, alpha preservado e arquivos originais copiados sem edição de pixels. Referência de identidade do guerreiro: `assets/sprites/units/skeleton_warrior_v1/idle.png`. Não são desenhos manuais. Revisão comercial de termos e divulgação de conteúdo gerado continua obrigatória antes da Steam.

- `assets/sprites/factory/rare_refinery_v1.png`: carcaça única, duas metades consultadas por região para preservar desbloqueios separados.
- `assets/sprites/units/skeleton_warrior_v2/walk_sheet.png`: oito células 4×2, recortes deslocados 16 px proporcionais dentro das margens transparentes para evitar resíduos vizinhos.
- `assets/sprites/units/skeleton_warrior_v2/recovery_sheet.png`: somente células 5, 6 e 7 usadas, após impacto antigo; restantes não aprovadas para runtime. Segunda tentativa de folha 2×2 foi descartada por ultrapassar células e não integra o projeto.

### Prompts usados nos assets integrados

Refinaria: “Use case: stylized-concept. Create a single 2D game asset: two connected gothic industrial refinery vessels side by side, front view, aspect ratio 3:1, transparent background. Left blood distillation pressure vessel, right arcane soul condenser. Aged brass pipes, riveted black iron, small gauges, skull reliefs, left tiny red indicator and right violet indicator. Detailed painted pixel-art-inspired style for NecroWorks. Each vessel has a large EMPTY TRANSPARENT rectangular front chamber. Left window spans x 13%-35%, y 20%-80%; right window x 65%-87%, y20%-80%. These are holes, no fill or contents: engine adds fluid and energy behind them. Common low iron base, all silhouette within image, no text or labels, no characters, no floor, no backdrop. Readable at 290x90 pixels.”

Caminhada: “Use case: stylized-concept. Reference is character identity only. Produce a transparent animation sprite sheet, exactly 4 columns by 2 rows of equal square cells, 8 full body frames total, read left to right then next row. Same skeleton warrior, sword held forward in right hand, round skull shield in left, green backpack, facing RIGHT in all frames. A continuous in-place WALK CYCLE: contact right foot forward, down, passing, up, contact left foot forward, down, passing, up. Clearly alternate leg poses; bend knees and lift trailing foot. Same skull, equipment, proportions, lighting and scale every cell. Pelvis at same cell center, feet ground line at 88% cell height, crown at20%. Keep sword and shield within each cell, no clipping, no extra limbs, no text, no grid lines, no background. Crisp detailed pixel-art-inspired painted style matching reference. All eight characters equally sized and centered independently. This is animation production, not eight copies of the same stance.”

Recuperação: “Use case: stylized-concept. Character reference only. Transparent sprite sheet of this SAME skeleton warrior sword and skull shield, green backpack, facing RIGHT. Exactly 4 columns x 2 rows, eight full-body animation frames in equal square cells. ATTACK AND RECOVERY: frame1 sword extended forward at impact, frame2 follow-through downward, frame3 low follow-through, frame4 retract elbow, frame5 raise sword to guard, frame6 settle shield, frame7 balanced guard, frame8 same guard as reference. Keep skull identity armor shield sword constant. Actual joint articulation, no motion blur, no trails, no text, no grid, no floor. All bodies identical height, pelvis centered at same cell coordinate, feet on same ground line at88% cell height. Entire sword and body inside each cell with generous margins. Detailed painted pixel-art-inspired game art. Frame1 already hits because gameplay damage is instantaneous; this sheet must not delay impact.”

**Atualizado em:** 11/09/2026 — v0.6.2

Este registro acompanha os assets visuais criados especificamente para o projeto e evita dúvidas futuras durante a preparação comercial.

## Referências de direção

### Prensa de materiais — 01/10/2026

- Arquivo: `assets/sprites/factory/material_press_v1.png`.
- Gerado pela ferramenta integrada de imagens da OpenAI, fundo transparente, sem imagens externas fornecidas nesta geração. Fonte copiada sem alterações de pixels; o jogo dimensiona o sprite.
- Carcaça estática; esteira, pistão, carga e saída são animações de código sincronizadas com a simulação. Não se trata de uma sequência desenhada quadro a quadro.
- Revisão comercial de proveniência e declaração de conteúdo gerado permanece parte do gate de publicação.

Prompt utilizado:

> Use case: stylized-concept. Asset type: single transparent sprite of an industrial necromantic material-processing press housing for a 2D side-view game NecroWorks. Create a richly detailed game-ready machine chassis, horizontal 3:1 silhouette, worn black iron, dull brass rivets, ivory bone fittings, tiny green status lamps. Orthographic straight side view, no perspective floor, no background, actual transparent alpha. Composition: a horizontal low conveyor bed extends from left edge to right edge in lower quarter; two vertical massive metal support pillars at 36% and 70% of width support an upper hydraulic cylinder housing. In the center between pillars is a completely EMPTY transparent working chamber from 30% to 70% height where the game will animate a descending ram and a corpse payload. Do not paint any ram or piston into this open chamber; no character, no body, no blood, no products, no text or symbols. A few pipes and gears on the sides, strong legible silhouette, hand-painted crisp dark fantasy pixel-art-inspired details matching a gothic industrial factory, readable at 300x120 game units. Chassis itself remains stationary: moving belt slats and ram will be drawn by the game. Keep everything fully inside canvas with minimal transparent margin. This is one finished machine asset, not a sprite sheet or concept panel.

- `assets/reference/necrodesign.png` — referência visual inicial;
- `assets/reference/necrodesignv2.png` — direção principal de horror industrial, metal escuro e energia necromântica verde.

## Apresentação v0.6.2 — 11/09/2026

### Arte da tela inicial

- arquivo: `assets/backgrounds/necroworks_title_v2.png`;
- criação específica para NecroWorks com a ferramenta integrada de geração de imagens da OpenAI;
- referência interna: `assets/reference/necrodesignv2.png`;
- função: fundo ilustrado da tela inicial, com o portão da fábrica como foco e área de leitura para título e controles;
- integração: `scripts/visual/title_atmosphere.gd` e `scripts/core/game_shell.gd`;
- texto, logotipo tipográfico e botões são renderizados pela interface, sem depender de texto na imagem;
- prompt completo e registro do passe: [PRESENTATION_UPDATE.md](PRESENTATION_UPDATE.md).

A ilustração é um asset de apresentação interna. A adequação final de contraste, composição e identidade depende de avaliação visual no jogo.

### Tipografia

| Fonte | Arquivo | Uso | Origem e licença |
|---|---|---|---|
| Cinzel | `assets/fonts/cinzel/Cinzel.ttf` | títulos e marca tipográfica | Google Fonts; Cinzel Project Authors; SIL OFL 1.1 |
| Barlow Medium | `assets/fonts/barlow/Barlow-Medium.ttf` | textos, botões e números | Google Fonts; Barlow Project Authors; SIL OFL 1.1 |
| Barlow Condensed Medium | `assets/fonts/barlow_condensed/BarlowCondensed-Medium.ttf` | alternativa compacta disponível no tema | Google Fonts; Barlow Project Authors; SIL OFL 1.1 |

Cada pasta contém seu `OFL.txt`. O preset Windows inclui `assets/fonts/*/OFL.txt` para distribuir os avisos junto das fontes. `necro_ui_theme.gd` centraliza o uso dessas famílias.

### Símbolos, molduras e movimento

`resource_glyph.gd` desenha os quatro símbolos econômicos; `industrial_panel_frame.gd` desenha bordas internas e rebites. Esses elementos são geometria produzida pelo próprio código do projeto e não incorporam packs externos de ícones.

`unit_motion.gdshader` e os perfis de `UnitSpriteCatalog` animam as texturas V1 existentes com deformação contínua e âncoras por família. A v0.6.2 não adiciona spritesheets nem quadros de personagens desenhados ou gerados. `FrameBlend` e as sequências de texturas repetidas deixaram o caminho atual de apresentação. O contrato e seus limites estão em [ANIMATION_CONTRACT.md](ANIMATION_CONTRACT.md).

## Sprites de chefe — 31/08/2026

### Marechal da Sepultura

- arquivo: `assets/sprites/bosses/grave_marshal_prototype.png`;
- criação original para NecroWorks;
- referências internas: `necrodesignv2.png` e `human_warrior_prototype.png`;
- função: chefe da Onda 10 e restos exclusivos.

### Auditor Arcano

- arquivo: `assets/sprites/bosses/arcane_auditor_prototype.png`;
- criação original para NecroWorks;
- referências internas: `necrodesignv2.png` e `mage_prototype.png`;
- função: chefe da Onda 15 e restos exclusivos.

### Capataz

- arquivo: `assets/sprites/units/foreman_prototype.png`;
- criação original para NecroWorks;
- função: chefe final da Onda 20 e restos exclusivos.

Os arquivos continuam classificados como arte de protótipo. Antes da página da Steam, cada asset precisa de revisão final de silhueta, animação, consistência de escala e inspeção de transparência.

## Cenário industrial — 31/08/2026

- arquivo: `assets/backgrounds/necroworks_factory_battlefield_v1.png`;
- criação original para NecroWorks;
- referência interna: `necrodesignv2.png`;
- composição: fortaleza industrial distante, campo de pedra livre para combate e plataforma inferior;
- integração: camada estática combinada com parallax, névoa, pulsos verdes e divisor procedural.

O cenário foi criado sem personagens, HUD, texto ou logotipos. A região central mantém contraste reduzido para preservar nomes e barras de vida.

## Estudos de animação — 02/09/2026

### Guerreiro Esqueleto

- arquivo: `assets/sprites/animation_concepts/skeleton_warrior_five_state_v1.png`;
- criação específica para NecroWorks com a ferramenta de geração de imagens da OpenAI;
- referências internas: `skeleton_prototype.png` e `necrodesignv2.png`;
- conteúdo: poses de idle, movimento, ataque, impacto e morte;
- formato: PNG RGBA, 2172×724, fundo transparente;
- situação: direção aprovada; não integrado como atlas porque as caixas das poses são irregulares.

### Zumbi Tank

- arquivo: `assets/sprites/animation_concepts/zombie_tank_five_state_v1.png`;
- criação específica para NecroWorks com a ferramenta de geração de imagens da OpenAI;
- referências internas: `zombie_prototype.png` e `necrodesignv2.png`;
- conteúdo: poses de idle, movimento, ataque, impacto e morte;
- formato: PNG RGBA, 2172×724, fundo transparente;
- situação: direção aprovada; não integrado como atlas porque as caixas das poses são irregulares.

Os originais gerados permanecem fora do repositório no armazenamento local da ferramenta. As cópias versionadas acima são as fontes de trabalho do projeto e ficam excluídas do build Windows enquanto forem apenas conceito. Antes da distribuição comercial, os frames finais ainda passarão por recorte técnico, consistência de pivô, revisão manual e conferência dos termos aplicáveis à geração.

## Guerreiro Esqueleto — família de runtime V1 — 03/09/2026

- pasta: `assets/sprites/units/skeleton_warrior_v1/`;
- arquivos: `idle.png`, `move.png`, `attack.png`, `hit.png` e `death.png`;
- criação específica para NecroWorks com a ferramenta de geração de imagens da OpenAI;
- referências internas: `skeleton_prototype.png` e `skeleton_warrior_five_state_v1.png`;
- formato-fonte: PNG RGBA, 1254×1254, fundo transparente;
- importação de runtime: limite de 512 px, sem mipmaps;
- integração: `UnitSpriteCatalog` e `UnitAnimationDriver`;
- revisão: transparência, dimensões, fallback e cinco transições cobertos por regressão.

Os prompts preservaram identidade, equipamento e paleta do protótipo e pediram uma única pose por canvas, alinhamento de base, margem segura e ausência de cenário, texto, sombra ou efeitos externos. Quando a primeira geração trouxe um quadriculado opaco, cada pose afetada passou por uma etapa separada de extração de fundo antes de entrar no repositório.

## Zumbi Tank — família de runtime V1 — 03/09/2026

- pasta: `assets/sprites/units/zombie_tank_v1/`;
- arquivos: `idle.png`, `move.png`, `attack.png`, `hit.png` e `death.png`;
- criação específica para NecroWorks com a ferramenta de geração de imagens da OpenAI;
- referências internas: `zombie_prototype.png` e `zombie_tank_five_state_v1.png`;
- formato-fonte: PNG RGBA, 1254×1254, fundo transparente;
- importação de runtime: limite de 512 px, sem mipmaps;
- integração: `UnitSpriteCatalog` e `UnitAnimationDriver`;
- revisão: alpha nos quatro cantos, dimensões, escala, transições e retirada visual cobertos por regressão.

O prompt-base preservou tanque dorsal, ombreira, olhos verdes, proporções pesadas, paleta e direção lateral. Cada chamada gerou somente uma pose com canvas quadrado, baseline e margem segura. Movimento, ataque, impacto e morte vieram inicialmente com o quadriculado incorporado; uma segunda passagem de extração removeu apenas o fundo antes da integração.

`zombie_prototype.png` continua versionado como referência de identidade, mas foi retirado do pacote Windows depois que a família V1 assumiu todas as referências de runtime.

## Fantasma — família de runtime V1 — 03/09/2026

- pasta: `assets/sprites/units/ghost_v1/`;
- arquivos: `idle.png`, `move.png`, `attack.png`, `hit.png` e `death.png`;
- criação específica para NecroWorks com a ferramenta de geração de imagens da OpenAI;
- referências internas: `necrodesignv2.png`, `skeleton_warrior_v1/idle.png` e `zombie_tank_v1/idle.png`;
- formato-fonte: PNG RGBA, 1254×1254, fundo transparente;
- importação de runtime: limite de 512 px, sem mipmaps;
- integração: cena própria, `UnitSpriteCatalog` e `UnitAnimationDriver`;
- revisão: identidade, alpha, dimensões, escala, cinco transições e retirada visual cobertos por regressão.

O idle estabeleceu a identidade antes das outras poses: corpo ciano-violeta, rosto ósseo, núcleo verde, coleira, braceletes, tubos e cauda. Movimento, ataque, impacto e morte reutilizaram esse arquivo como referência direta. Ataque e impacto passaram por extração de fundo; a primeira morte foi descartada por não comunicar derrota e substituída por uma dissipação baixa e horizontal.

`skeleton_prototype.png` continua versionado como registro da primeira passagem, mas deixou o pacote Windows quando o Fantasma recebeu sua própria arte.

## Guerreiro Humano — família de runtime V1 — 04/09/2026

- pasta: `assets/sprites/units/human_warrior_v1/`;
- arquivos: `idle.png`, `move.png`, `attack.png`, `hit.png` e `death.png`;
- criação específica para NecroWorks com a ferramenta integrada de geração de imagens da OpenAI;
- referências internas: `human_warrior_prototype.png`, `skeleton_warrior_v1/idle.png` e `necrodesignv2.png`;
- formato-fonte: PNG RGBA, 1254×1254, fundo transparente;
- importação de runtime: limite de 512 px, sem mipmaps;
- integração: cena do inimigo, `UnitSpriteCatalog`, `UnitAnimationDriver` e fluxo de retirada inimiga;
- revisão: identidade, direção para a esquerda, alpha nos quatro cantos, dimensões, cinco transições e retirada visual cobertos por regressão.

O prompt-base preservou rosto, barba, cabelo curto, armadura de aço, couro, tecido carmesim, espada e escudo do protótipo. As poses pediram guarda ociosa, avanço protegido, golpe horizontal, recuo de impacto e morte horizontal sem gore. Gerações com quadriculado opaco passaram por extração de fundo individual; o idle foi normalizado em canvas quadrado antes da extração final.

`human_warrior_prototype.png` permanece versionado como referência histórica, mas deixou o pacote Windows depois que a família V1 assumiu cena e catálogo.

## Mago — família de runtime V1 — 04/09/2026

- pasta: `assets/sprites/units/mage_v1/`;
- arquivos: `idle.png`, `move.png`, `attack.png`, `hit.png` e `death.png`;
- criação específica para NecroWorks com a ferramenta integrada de geração de imagens da OpenAI;
- referências internas: `mage_prototype.png`, `human_warrior_v1/idle.png` e `necrodesignv2.png`;
- formato-fonte: PNG RGBA, 1254×1254, fundo transparente;
- importação de runtime: limite de 512 px, sem mipmaps;
- integração: `UnitSpriteCatalog`, `UnitAnimationDriver` e fluxo de retirada inimiga;
- revisão: identidade, escala entre poses, margem do cajado, alpha, dimensões, cinco transições e retirada visual cobertos por regressão.

O prompt preservou a Maga viva, cabelo preso, olho violeta, casaco escuro, painéis roxos, proteções de latão, cajado industrial e frasco dorsal. As ações pediram avanço baixo, conjuração, recuo e morte horizontal. As cinco fontes passaram por extração de fundo. A primeira descarga foi descartada por tocar a borda; a segunda foi reduzida, mas encolhia a personagem. A pose final concentra uma esfera no cajado e deixa projétil e rastro para o VFX do runtime.

`mage_prototype.png` permanece como referência histórica, mas não entra mais no build Windows.

## Elfo — família de runtime V1 — 04/09/2026

- pasta: `assets/sprites/units/elf_v1/`;
- arquivos: `idle.png`, `move.png`, `attack.png`, `hit.png` e `death.png`;
- criação específica para NecroWorks com a ferramenta integrada de geração de imagens da OpenAI;
- referências internas: `elf_prototype.png`, `human_warrior_v1/idle.png` e `necrodesignv2.png`;
- formato-fonte final: PNG RGBA quadrado, 1254×1254, fundo transparente;
- importação de runtime: limite de 512 px, sem mipmaps;
- integração: `UnitSpriteCatalog`, `UnitAnimationDriver` e fluxo de retirada inimiga;
- revisão: identidade, direção para a esquerda, escala, margem de arco, alpha, cinco transições e retirada visual cobertos por regressão.

O prompt-base preservou a arqueira viva, cabelo claro preso, olhos verdes, orelhas longas, couro escuro, tecido verde, placas leves, arco recurvo e aljava. As ações pediram guarda controlada, avanço baixo, disparo compacto, recuo de impacto e morte horizontal sem gore. A flecha permanece encaixada na textura de ataque; alvo, trajetória e Tiro de Precisão continuam no runtime.

Idle, ataque, impacto e morte precisaram de extração dedicada porque as primeiras saídas incorporaram o quadriculado ao fundo. A primeira morte finalizada usava canvas horizontal; ela foi recomposta em canvas quadrado e extraída novamente para manter o contrato 512×512 sem cortar corpo ou arco.

`elf_prototype.png` permanece como referência histórica, mas não entra mais no build Windows.

## Marechal da Sepultura — família de runtime V1 — 04/09/2026

- pasta: `assets/sprites/bosses/grave_marshal_v1/`;
- arquivos: `idle.png`, `move.png`, `attack.png`, `hit.png` e `death.png`;
- criação específica para NecroWorks com a ferramenta integrada de geração de imagens da OpenAI;
- referências internas: `grave_marshal_prototype.png` e `human_warrior_v1/idle.png`;
- formato-fonte: PNG RGBA, 1254×1254, fundo transparente;
- importação de runtime: limite de 512 px, sem mipmaps;
- integração: `UnitSpriteCatalog`, `UnitAnimationDriver`, escala de chefe e retirada inimiga;
- revisão: identidade, massa, margem de equipamento, alpha, cinco transições e progressão de chefe cobertos por regressão.

O prompt preservou o comandante vivo, barba, cicatrizes, placas de aço escuro, latão, pele no ombro, capa carmesim, escudo em forma de lápide e cutelo de escavação contaminado. As ações pediram guarda imóvel, avanço pesado, golpe compacto, quebra de postura e queda horizontal sem gore. Os cinco arquivos iniciais incorporaram o quadriculado e passaram por extração individual antes da integração.

`grave_marshal_prototype.png` permanece como registro da direção original, mas não entra mais no build Windows.

## Auditor Arcano — família de runtime V1 — 04/09/2026

- pasta: `assets/sprites/bosses/arcane_auditor_v1/`;
- arquivos: `idle.png`, `move.png`, `attack.png`, `hit.png` e `death.png`;
- criação específica para NecroWorks com a ferramenta integrada de geração de imagens da OpenAI;
- referências internas: `arcane_auditor_prototype.png` e `mage_v1/idle.png`;
- formato-fonte: PNG RGBA, 1254×1254, fundo transparente;
- importação de runtime: limite de 512 px, sem mipmaps;
- integração: `UnitSpriteCatalog`, `UnitAnimationDriver`, escala de chefe e retirada inimiga;
- revisão: identidade, equipamento, margem, alpha, cinco transições e progressão de chefe cobertos por regressão.

O conjunto preserva a figura viva de orelhas longas, máscara, cabelo escuro, vestes de carvão e violeta, latão, reator do cajado, vidraria dorsal e documentos encantados. As poses pediram repouso autoritário, avanço controlado, sentença arcana compacta, recuo e morte horizontal sem gore. Repouso, movimento e morte incorporaram o quadriculado da primeira saída e passaram por extração de fundo. Ataque e impacto já vieram com alpha real.

`arcane_auditor_prototype.png` permanece como referência histórica, mas não entra mais no build Windows.

## Capataz — família de runtime V1 — 04/09/2026

- pasta: `assets/sprites/bosses/foreman_v1/`;
- arquivos: `idle.png`, `move.png`, `attack.png`, `hit.png` e `death.png`;
- criação específica para NecroWorks com a ferramenta integrada de geração de imagens da OpenAI;
- referências internas: `foreman_prototype.png` e `grave_marshal_v1/idle.png`;
- formato-fonte: PNG RGBA, 1254×1254, fundo transparente;
- importação de runtime: limite de 512 px, sem mipmaps;
- integração: `UnitSpriteCatalog`, `UnitAnimationDriver`, escala de chefe e retirada inimiga;
- revisão: identidade, martelo inteiro, margem, alpha, cinco transições e vitória cobertos por regressão.

O conjunto preserva o supervisor vivo integrado à armadura: barba, charuto, capacete de mineração, pano vermelho, ferro enegrecido, latão, faixas de risco, manopla, tubos, reservatórios violetas e martelo-reator. As poses pediram guarda compacta, marcha pesada, golpe sem onda externa, recuo e morte horizontal sem gore. A primeira guarda cortava o martelo e foi recomposta antes da aprovação. As cinco gerações passaram por extração de fundo; no ataque, a máscara final de alpha foi concluída por remoção técnica do quadriculado depois de três tentativas de extração integrada preservarem fundo opaco.

`foreman_prototype.png` permanece como referência histórica, mas não entra mais no build Windows.

## Arqueiro Esqueleto, Lich e Fábrica — 08/09/2026

- pastas: `assets/sprites/units/skeleton_archer_v1/` e `assets/sprites/units/lich_v1/`;
- arquivo: `assets/backgrounds/factory_floor_v1.png`;
- criação específica para NecroWorks com a ferramenta integrada de geração de imagens da OpenAI;
- referência interna: `assets/reference/necrodesignv2.png` e protótipos já registrados;
- sprites: cinco PNGs RGBA por família, importados com limite de 512 px;
- Fábrica: PNG de 1536×1024 importado com limite de 1024 px;
- revisão: transparência real, margens, identidade, cobertura dos cinco estados e legibilidade atrás da interface verificadas por regressão.

Esses assets são V1 de produção interna, não uma declaração automática de direitos para distribuição. Antes da Steam, os termos aplicáveis, a declaração de conteúdo gerado, créditos e qualquer material derivado precisam constar da revisão comercial final.

## Oficina de tropas V1 — 02/10/2026

`assets/sprites/factory/undead_workshop_v1.png`: criada com geração de imagens integrada da OpenAI para NecroWorks, fundo transparente, sem referência externa. Carcaça estática com duas câmaras vazias; unidades, braço, bolhas e progresso desenhados em runtime. Integração inspecionada em captura 1280×720. Não é arte desenhada manualmente nem spritesheet de animação. Revisão de termos e declaração de conteúdo gerado seguem no gate comercial.

Prompt: “Use case: stylized-concept. Asset type: one transparent 2D game sprite of a dual-module undead production workshop, straight-on side view, aspect 2:1, for NecroWorks gothic industrial factory. Black iron and aged brass with tiny sickly green indicator lamps, hand painted detailed pixel-art-inspired finish, readable at 320x160 game units. Left half: tall mechanical bone-assembly rack with a fully EMPTY open central chamber, from 15% to 36% canvas width and 25% to 75% canvas height; jointed tools folded at its sides. Right half: cylindrical flesh incubation vat with an EMPTY transparent front window from 63% to 82% canvas width and 25% to 75% height. Heavy riveted rims, copper pipes connect the two modules on a shared iron base. Both chambers remain transparent so game sprites can be drawn inside and animated. No characters, no corpses, no bones floating inside, no gore, no lettering, no logos, no background or floor. Keep entire connected workshop within canvas, minimal transparent margins. This is a single stationary chassis; the game adds moving tools, fluid, sparks and units.”

## Áudio procedural V1 — 02/09/2026

Os nove efeitos atuais são sintetizados em runtime por `scripts/audio/combat_audio_manager.gd`, e o ambiente industrial é sintetizado por `scripts/audio/industrial_ambient_manager.gd`. Não usam gravações, samples ou bibliotecas externas. Essa camada serve para validar cadência e mixagem; os efeitos e a música finais precisarão de autoria ou licença comercial documentada aqui antes da Steam.
