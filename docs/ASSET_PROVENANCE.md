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

## Áudio procedural V1 — 02/09/2026

Os seis efeitos atuais são sintetizados em runtime por `scripts/audio/combat_audio_manager.gd`. Não usam gravações, samples ou bibliotecas externas. Essa camada serve para validar cadência e mixagem; os efeitos e a música finais precisarão de autoria ou licença comercial documentada aqui antes da Steam.
