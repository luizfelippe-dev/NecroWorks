# NecroWorks

> **Industrial Reanimation Solutions**  
> **Waste Nothing. Raise Everything.**

**NecroWorks** é um roguelite 2D com elementos de autobattler, estratégia, automação e progressão incremental, desenvolvido em **Godot 4.7.1** com **GDScript**.

O jogador transforma o campo de batalha em uma linha de produção necromântica:

**Enemy → Corpse → Resources → Undead → Bigger Army → Stronger Waves → Upgrades → Synergies**

A proposta central é criar um jogo fácil de entender, satisfatório de assistir e com profundidade emergente: poucas regras devem gerar muitas combinações.

---

## Estado atual

**Versão estável mais recente:** `v0.0.3`  
**Versão em desenvolvimento:** `v0.1.0 — First Run`

### Implementado

- combate automático;
- HP, dano e cooldown;
- múltiplos Skeletons;
- HP e cooldown individuais;
- target-based movement;
- retarget de Enemy e Skeletons;
- Corpse;
- processamento de Corpse;
- Bones;
- criação de Skeleton;
- Waves;
- scaling de HP e dano;
- Elite Wave a cada 5 Waves;
- HUD de Wave;
- 10 upgrades acumuláveis;
- escolha de 3 upgrades aleatórios entre Waves;
- 4 sinergias automáticas;
- métricas de run;
- placeholders visuais para unidades dinâmicas;
- recuperação do exército após perda total enquanto houver recursos disponíveis.

### Em desenvolvimento

- Boss Wave;
- Victory;
- Game Over;
- Restart Run;
- encerramento da primeira run completa.

---

## Upgrades atuais

| Upgrade | Efeito |
|---|---|
| Sharpened Bones | +25% Skeleton Damage |
| Bone Plating | +25 Skeleton Max HP |
| Efficient Recycling | +2 Bones por Corpse |
| Rapid Assault | +15% Attack Speed |
| Death March | +20% Movement Speed |
| Mass Production | -1 Bone no custo de Skeleton |
| Heavy Bones | +50% Damage, -20% Attack Speed |
| Bone Harvest | +20% chance de Bones extras ao processar Corpse |
| Reassembly | +15% chance de Skeleton reviver com 50% HP |
| Final Service | Skeleton causa dano ao Enemy ao morrer |

---

## Sinergias atuais

| Sinergia | Requisitos | Efeito |
|---|---|---|
| Recycling Plant | Efficient Recycling + Bone Harvest | dobra o bônus de Bone Harvest |
| Second Shift | Reassembly + Final Service | revive e causa parte do dano de Final Service |
| Bone Assembly Line | Mass Production + Efficient Recycling | chance de produzir Skeleton grátis ao processar Corpse |
| Overclocked Ossuary | Heavy Bones + Rapid Assault | chance de ataque duplo |

---

## Tecnologia

- **Engine:** Godot 4.7.1
- **Linguagem:** GDScript
- **Dimensão:** 2D
- **Plataforma inicial:** Windows
- **Distribuição planejada:** Steam
- **Modo:** single-player
- **Versionamento:** Git + GitHub

---

## Filosofia de desenvolvimento

O projeto segue desenvolvimento incremental:

```text
implementar
→ testar
→ corrigir
→ documentar
→ commit
→ push
→ próxima funcionalidade
```

Durante a fase de protótipo, gameplay e arquitetura funcional têm prioridade sobre arte definitiva.

---

## Próximo milestone

### `v0.1.0 — First Run`

Objetivo:

```text
Wave 1
→ crescimento
→ upgrades
→ sinergias
→ Elite Waves
→ Boss
→ Victory / Game Over
→ Run Summary
→ Restart
```

Depois disso o projeto entra em expansão de economia necromântica, variedade de unidades, Factory, conteúdo, polimento e preparação comercial para Steam.

Consulte `docs/ROADMAP.md` para o plano completo.
