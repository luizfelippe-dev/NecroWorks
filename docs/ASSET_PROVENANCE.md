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

## Áudio procedural V1 — 02/09/2026

Os seis efeitos atuais são sintetizados em runtime por `scripts/audio/combat_audio_manager.gd`. Não usam gravações, samples ou bibliotecas externas. Essa camada serve para validar cadência e mixagem; os efeitos e a música finais precisarão de autoria ou licença comercial documentada aqui antes da Steam.
