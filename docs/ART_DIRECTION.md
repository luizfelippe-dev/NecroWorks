# Direção de Arte

## Refinaria procedural — 02/10/2026

Vermelho diferencia o enchimento hemático; violeta, a concentração de almas. Dois vasos geométricos com tubos e medidor fornecem a leitura funcional. Não equivalem ao acabamento ilustrado da oficina e não encerram a arte da fábrica. A apresentação arcana ainda não transporta o corpo nem representa a saída até o HUD.

## Oficina V1 — 02/10/2026

Montador e cuba compartilham ferro escuro, latão e luz verde da prensa. Câmaras abertas recebem a pose da receita revelada pelo timer; braço e bolhas comunicam trabalho. Apresentação procedural sobre arte estática, não animação quadro a quadro. Captura integrada em 1280×720 verificada.

## Prioridade de sensação — 01/10/2026

Cadáveres precisam parecer restos no chão, não miniaturas em pé. A pose de morte existente agora alimenta o coletável sem dessaturação pesada. A prensa de materiais combina carcaça ilustrada com partes móveis e fases ligadas à fila real. É a primeira máquina desse novo passe; transferência física e outras rotas continuam pendentes. Movimento de câmera, partículas ou tintas não substituem animação de personagem aprovada nem ambientes realmente diferentes.

**Atualizado em:** 11/09/2026 — v0.6.2

NecroWorks combina horror industrial, fantasia sombria e leitura de autobattler. A arte precisa vender a fantasia de uma fábrica que transforma derrota em produção: ferro oxidado, latão gasto, osso, couro, vidro químico e energia necromântica verde.

`assets/reference/necrodesignv2.png` é a referência principal de composição. Ela define atmosfera e hierarquia, mas não é um layout que precisa ser copiado pixel por pixel.

## Regras de leitura

- aliados ocupam a metade esquerda e olham para a direita;
- invasores ocupam a metade direita e olham para a esquerda;
- a silhueta e a função da tropa precisam ser reconhecíveis antes dos detalhes;
- verde identifica energia necromântica e funcionamento da Fábrica;
- vermelho comunica dano e ameaça viva; roxo fica reservado ao arcano e às Almas;
- o centro do campo permanece menos contrastado que personagens, barras e VFX;
- partículas nunca escondem barra de vida, nome, alvo ou decisão de interface;
- sangue, ossos e deterioração podem ser fortes, sem transformar a tela em ruído visual.

## Famílias jogáveis

### Esqueletos

Corpo estreito, juntas expostas, arma com leitura rápida e mecanismos verdes presos ao torso. O Guerreiro usa escudo e espada; o Arqueiro preserva a mesma origem industrial, mas abre a pose e destaca o arco. A animação deve parecer precisa e mecânica, como uma ferramenta montada na linha de produção.

### Zumbis

Massa larga, centro de gravidade baixo e equipamento pesado. O Zumbi Tank precisa parecer capaz de absorver impacto mesmo parado. Ataques têm peso, passos são lentos e a morte ocupa mais espaço horizontal que a do Esqueleto.

### Espectrais

Fantasmas e Liches usam roxo, verde frio e transparência controlada. Transparência não pode reduzir a leitura da silhueta. O Lich deve parecer um operador arcano da fábrica; o Fantasma, uma munição instável e veloz.

## Invasores e chefes

Humanos usam aço, tecido e cores mais quentes. Magos carregam geometria arcana; Elfos usam couro, placas leves, tecido verde e linhas compridas definidas por arco, orelhas e aljava. Chefes precisam ser reconhecidos pelo contorno, não apenas pelo tamanho ou pelo nome. Cada chefe mantém um material dominante e um VFX próprio: ferro para o Marechal, energia arcana para o Auditor e maquinário de produção para o Capataz.

## Escala e exportação de personagens

Cada ação final será entregue como uma sequência separada, sem texto, cenário, sombra projetada ou elementos cortados. Todos os frames de uma mesma unidade devem compartilhar canvas, pivô dos pés, escala e direção.

Estados obrigatórios:

1. `idle`;
2. `move`;
3. `attack`;
4. `hit`;
5. `death`.

Os concept sheets em `assets/sprites/animation_concepts/` fecham pose, equipamento e linguagem de movimento do Guerreiro Esqueleto e do Zumbi Tank. Eles não são atlases de runtime: as caixas das poses são irregulares e algumas silhuetas atravessam a coluna visual seguinte. O recorte automático causaria vazamento ou amputação de pixels.

O preset Windows exclui essa pasta do pacote distribuído. As fontes permanecem no repositório para orientar a produção, sem aumentar o executável enquanto não forem assets de runtime.

O Guerreiro Esqueleto, o Arqueiro Esqueleto, o Zumbi Tank, o Fantasma, o Lich, o Guerreiro Humano, o Mago, o Elfo e os três chefes já foram exportados em cinco canvases quadrados e integrados em suas pastas V1. O Fantasma fixa a linguagem espectral: núcleo verde preso por bronze, massa ciano-violeta e silhueta estreita de projétil. O Arqueiro usa osso, couro escuro e metal verde para comunicar retaguarda; o Lich concentra a leitura arcana em coroa, cajado e núcleo. O Guerreiro Humano fixa a linha viva: aço cinza, couro marrom, tecido carmesim e escudo retangular sem brilho necromântico. O Mago usa latão, carvão e violeta concentrado em cajado e frasco, com corpo estreito e pouca blindagem. O Elfo fecha o trio invasor com cabelo claro, tecido verde, couro escuro e arco recurvo. O Marechal amplia aço, latão e carmesim numa silhueta dominada pelo escudo-túmulo. O Auditor combina carvão, violeta, latão, documentos e vidraria. O Capataz encerra a escala com ferro enegrecido, faixas de risco, reservatórios e martelo-reator. `UnitAnimationDriver.configure_state_textures()` mantém a substituição fora das regras de combate.

## Interface e cenário

A interface usa metal verde-escuro, bronze gasto, títulos em marfim e acentos verdes. `necro_ui_theme.gd` concentra a paleta e os estados de botão. Molduras internas, linhas de luz e rebites são desenhados em código por `industrial_panel_frame.gd`. Botões importantes mantêm estado normal, foco, hover, pressionado, bloqueado e selecionado.

Cinzel dá identidade aos títulos. Barlow Medium mantém leitura em textos, números e métricas; Barlow Condensed Medium permanece no tema como alternativa para composições compactas. As três fontes vêm do Google Fonts, com licença SIL Open Font License 1.1 preservada ao lado dos arquivos em `assets/fonts/` e incluída no pacote Windows. Textos permanecem controles reais, localizáveis e compatíveis com Alto Contraste.

A HUD da v0.6.2 apresenta recursos em cartões individuais, com símbolos de osso, carne, sangue e Alma; métricas em colunas; retratos nas ações de produção; e barras para progresso da Onda e ciclos das máquinas. A diferenciação usa símbolo, nome e cor juntos. O rodapé mantém o espaço seguro já reservado para execução incorporada, e as molduras não ampliam as áreas de clique.

A tela inicial usa `assets/backgrounds/necroworks_title_v2.png`, criada para este passe a partir de `necrodesignv2.png`. A composição destaca o portão industrial e preserva uma região escura para título e ações. O deslocamento lento da arte pertence a `title_atmosphere.gd`; o gradiente de leitura, o título, a versão e todos os botões são elementos de interface. Nova Partida e Continuar têm prioridade sobre os atalhos de progressão e configuração.

O cenário híbrido atual preserva a ilustração como base e deixa névoa, luz, parallax e feedback em código. Essa divisão é intencional: a imagem sustenta identidade e detalhe; o runtime sustenta resposta, acessibilidade e variação.

O painel inferior ganhou uma segunda ilustração dedicada à linha física da Fábrica: processador ósseo, cuba de carne, prensa hemática, reservatórios de Alma e esteira. Ela permanece atrás dos controles com baixa opacidade, de modo que entradas, saídas e gargalos ganhem contexto sem reduzir a leitura dos cartões.

## Movimento na v0.6.2

As onze famílias continuam com as cinco poses V1 existentes. A caminhada agora usa fase contínua, peso de entrada e saída e deformação localizada, com âncoras de pernas ajustadas por família. Zumbis e chefes pesados marcham mais lentamente; arqueiros e Elfos usam cadência curta; conjuradores reduzem amplitude; o Fantasma recebe ondulação espectral. O ataque aplica recuperação sobre sua pose, e o dano recebido acrescenta feedback sem cancelar a ação em andamento.

Não foram produzidos novos quadros desenhados de personagens nesta versão. A camada procedural substitui a mistura duplicada de poses e mantém a porta aberta para animações quadro a quadro ou rig próprio. Ainda é preciso avaliar em jogo se cada arma, capa e membro conserva a forma durante o movimento. Uma suíte aprovada protege execução e estado, mas não demonstra, sozinha, qualidade de animação.

O registro do passe, incluindo o prompt da nova arte de abertura, está em [PRESENTATION_UPDATE.md](PRESENTATION_UPDATE.md).

## Critério para a vertical slice

Uma captura sem explicação precisa comunicar, em poucos segundos, quem ataca, quem está vencendo, o que a Fábrica produz e por que um cadáver importa. A arte só passa a ser considerada final quando também funcionar em movimento, em formações cheias e com Interface de Alto Contraste ou Movimento Reduzido.
