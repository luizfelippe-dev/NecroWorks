# NecroWorks v0.6.2 — Apresentação e continuidade de movimento

**Data:** 11/09/2026

## O que mudou

A revisão da v0.6.1 não resolveu a naturalidade do movimento: repetir duas poses com transição de transparência criava duplicação de silhueta e não equivalia a desenhar uma caminhada. Nesta versão retirei esse mecanismo.

- A passada mantém um relógio contínuo, acompanha o deslocamento observado e não recomeça a cada chamada de movimento.
- Um shader articula a região inferior da pose V1, com âncoras diferentes para cada família. Fantasmas usam ondulação; tanques têm cadência e amplitude próprias.
- O ataque tem entrada curta e recuperação contínua. Receber dano produz flash/recuo independente, sem cancelar o ataque.
- Morte é terminal, inclusive ao alternar Movimento Reduzido; não altera liberações de slots, cadáveres ou recompensas.
- O menu inicial ganhou uma ilustração de entrada da fábrica, hierarquia de ações, fontes próprias e atmosfera discreta.
- A HUD usa cartões de recursos, ícones nativos, números alinhados, molduras industriais e progresso de onda/processamento/produção.
- As dez sinergias ficam dentro de uma área rolável; nomes longos podem quebrar linha sem sair do painel.
- Botões de produção mostram unidade, quantidade e custo. A dica explica a reserva de recursos e a fila temporizada.

## Limites do passe

Não foram desenhados novos frames de personagens. Há movimento procedural contínuo sobre as cinco poses existentes de cada família. Isso elimina os reinícios e o efeito de dupla imagem, mas não substitui uma animação autoral de pernas, quadris, braços e armas. A avaliação de naturalidade continua aberta: primeiro validar uma família em gameplay, depois investir em spritesheets ou rig articulado para as demais.

Dano, alcance, cooldown, movimento de combate, recompensas e economia não foram rebalanceados neste passe. Um novo resultado visual não justifica mudar a dificuldade sem evidência de jogo.

## Validação reproduzível

- `tests/visual/unit_animation_driver_runner.gd`: continuidade, simulação a 30/60/144 Hz, impacto independente, sequências opcionais e morte terminal.
- `tests/visual/unit_sprite_runner.gd`: integração dos cinco estados nas onze famílias.
- `tests/ui/presentation_layout_runner.gd`: três idiomas, lote de dez, cartões, métricas, limites dos controles, barras e acessibilidade.
- `tests/visual/synergy_bounds_runner.gd`: dez sinergias acessíveis sem escapar do recorte.
- `tools/capture_presentation.gd`: renderização real de menu/HUD e comparação de quatro fases da passada, com perfil e checkpoint descartáveis.
- `tools/validate_release.ps1`: suíte completa, exportação Windows e smoke test. Evidência do build atual em `BUILDING.md`.

Capturas não são assets de runtime e ficam em `artifacts/presentation/`, fora do pacote e do Git. Os testes de geometria não substituem avaliação de legibilidade em escala do Windows ou uma run manual.

## Proveniência do menu

Asset versionado: `assets/backgrounds/necroworks_title_v2.png`.
Referência: `assets/reference/necrodesignv2.png`.
Gerado pela ferramenta integrada de imagens da OpenAI em 11/09/2026.
Origem local: `C:/Users/Dev20/.codex/generated_images/01a0156e-b04c-75f0-92ab-e737e28a40dd/exec-a98b5394-3984-467a-b850-ef04f380b3d8.png`.

O bitmap não contém botões nem textos; tudo que é interativo continua sendo interface do Godot. A procedência e os gates de revisão comercial também constam em `ASSET_PROVENANCE.md`.

### Prompt utilizado

```text
Use case: stylized-concept
Asset type: production title-screen background for the dark industrial necromancy game NecroWorks, landscape 16:9
Primary request: a richly painted cinematic view of the reanimation factory at night, based on the industrial fortress in the reference. The factory should feel ancient, dangerous and operational, with green soul energy powering its massive skull-shaped furnace gate, oxidized bronze pipes, riveted black iron, tall chimneys, hanging chains, faint smoke and warm furnace embers. Refined game key art, not a screenshot.
Input images: Image 1 is atmosphere, architecture and materials reference only.
Composition/framing: foreground low angle on cobbled causeway; the impressive skull furnace and imposing factory occupy the right 60% of the canvas. The left 40% remains very dark quiet smoke/shadow with low-detail stone for an overlaid game title and menu. Strong depth, complete wide composition, no divided panels.
Lighting/mood: green portal glow on the right, dim amber lamps, heavy charcoal atmosphere, controlled contrast and painterly texture. Premium dark-fantasy game art consistent with the supplied reference.
Constraints: no characters, no HUD, no typography, no logos, no watermarks, no borders. Do not bake interface elements into the illustration. Preserve the necromantic factory identity.
```

## Fontes

Arquivos baixados dos diretórios oficiais do Google Fonts, com avisos SIL OFL 1.1 preservados:

- [Cinzel](https://github.com/google/fonts/tree/main/ofl/cinzel) — `assets/fonts/cinzel/`;
- [Barlow](https://github.com/google/fonts/tree/main/ofl/barlow) — `assets/fonts/barlow/`;
- [Barlow Condensed](https://github.com/google/fonts/tree/main/ofl/barlowcondensed) — `assets/fonts/barlow_condensed/`.

Os arquivos `OFL.txt` entram no pacote junto das fontes. Símbolos econômicos e molduras são desenhados pelo código do projeto.

## Próxima avaliação

Jogar uma run completa com atenção à marcha das tropas, leitura de dano enquanto atacam, lotes de produção e rolagem das sinergias. Registrar família, estado, resolução e trecho do combate que ainda parecer artificial. Depois validar arte de animação própria em uma unidade antes de ampliar a produção para onze famílias.
