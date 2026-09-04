# Direção de Arte

**Atualizado em:** 02/09/2026

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

O Guerreiro Esqueleto, o Zumbi Tank, o Fantasma, o Guerreiro Humano, o Mago e o Elfo já foram exportados em cinco canvases quadrados e integrados em suas pastas V1. O Fantasma fixa a linguagem espectral: núcleo verde preso por bronze, massa ciano-violeta e silhueta estreita de projétil. O Guerreiro Humano fixa a linha viva: aço cinza, couro marrom, tecido carmesim e escudo retangular sem brilho necromântico. O Mago usa latão, carvão e violeta concentrado em cajado e frasco, com corpo estreito e pouca blindagem. O Elfo fecha o trio invasor com cabelo claro, tecido verde, couro escuro e arco recurvo. `UnitAnimationDriver.configure_state_textures()` mantém a substituição fora das regras de combate.

## Interface e cenário

A interface usa painéis de metal escuro, bordas quentes e acentos verdes. Molduras devem organizar a informação sem competir com a batalha. Botões importantes precisam de estado normal, foco, hover, pressionado, bloqueado e selecionado.

O cenário híbrido atual preserva a ilustração como base e deixa névoa, luz, parallax e feedback em código. Essa divisão é intencional: a imagem sustenta identidade e detalhe; o runtime sustenta resposta, acessibilidade e variação.

## Critério para a vertical slice

Uma captura sem explicação precisa comunicar, em poucos segundos, quem ataca, quem está vencendo, o que a Fábrica produz e por que um cadáver importa. A arte só passa a ser considerada final quando também funcionar em movimento, em formações cheias e com Interface de Alto Contraste ou Movimento Reduzido.
