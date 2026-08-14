# Corpse Factory

Corpse Factory é um roguelite 2D de autobattle e automação necromântica desenvolvido em Godot.

O jogador derrota hordas de inimigos, transforma seus cadáveres em recursos e utiliza esses recursos para construir um exército de mortos-vivos cada vez maior.

## Conceito central

> Waste nothing. Raise everything.

Inimigos não são apenas obstáculos: seus cadáveres são matéria-prima.

O loop central é:

1. Inimigos atacam.
2. Mortos-vivos os enfrentam automaticamente.
3. Inimigos mortos deixam cadáveres.
4. Cadáveres são processados.
5. O jogador recebe recursos.
6. Recursos criam novas criaturas.
7. O exército cresce.
8. Hordas maiores aparecem.
9. Upgrades criam sinergias e builds cada vez mais absurdas.

## Tecnologia

- Engine: Godot 4.7.1
- Linguagem: GDScript
- Dimensão: 2D
- Plataforma inicial: Windows
- Distribuição planejada: Steam
- Multiplayer: não planejado para a primeira versão

## Estado atual

Prototype v0.0.1 em desenvolvimento.

Implementado:

- Cena principal
- Skeleton provisório
- Enemy provisório
- Movimento automático
- HP
- Ataque automático
- Morte do inimigo

Próxima implementação:

- Sistema de cadáveres