# Proveniência dos Assets

Este registro acompanha os assets visuais criados especificamente para o projeto e evita dúvidas futuras durante a preparação comercial.

## Referências de direção

- `assets/reference/necrodesign.png` — referência visual inicial;
- `assets/reference/necrodesignv2.png` — direção principal de horror industrial, metal escuro e energia necromântica verde.

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

## Áudio procedural V1 — 02/09/2026

Os seis efeitos atuais são sintetizados em runtime por `scripts/audio/combat_audio_manager.gd`. Não usam gravações, samples ou bibliotecas externas. Essa camada serve para validar cadência e mixagem; os efeitos e a música finais precisarão de autoria ou licença comercial documentada aqui antes da Steam.
