# Gerando o build Windows

O preset `Windows Desktop` exporta para `builds/windows/NecroWorks.exe`. A pasta `builds` fica fora do Git.

## Requisitos

- Godot 4.7.1 stable;
- templates de exportação da mesma versão;
- projeto importado sem erros;
- 79 runners aprovados antes de distribuir o executável.

O pacote oficial completo de templates possui aproximadamente 1,28 GB. No editor, a instalação fica em **Editor → Manage Export Templates**. A versão instalada deve aparecer como `4.7.1.stable`. Os templates Windows x86_64 oficiais foram instalados e usados com sucesso em 01/09/2026.

## Exportação pelo terminal

```powershell
Godot_v4.7.1-stable_win64_console.exe `
  --headless `
  --path . `
  --export-release "Windows Desktop" `
  "builds/windows/NecroWorks.exe"
```

## Checklist do primeiro build externo

1. iniciar pelo menu principal;
2. testar New Run e Continue;
3. trocar entre PT-BR, inglês e espanhol;
4. testar fullscreen, áudio, pausa, Movimento Reduzido e Alto Contraste;
5. concluir, pular e rever o tutorial pelos três idiomas;
6. concluir ao menos uma run;
7. confirmar Auto-coleta após concluir a Onda 5;
8. testar os três operadores e contratos disponíveis;
9. iniciar o executável em outro computador sem o editor;
10. registrar versão, commit e resultado do teste em `docs/DEVLOG.md`.

## Build validado

- arquivo local: `builds/windows/NecroWorks.exe`;
- tamanho: 125.000.592 bytes;
- SHA-256: `ECD158932E17A8E68CA59D91DA5DD43883AE153090C87E6F1DD0D422B3FAEC7E`;
- exportação release v0.6.2 e inicialização headless aprovadas em 11/09/2026;
- gate integral aprovado com 79 runners em 101,80 segundos antes da exportação;
- fontes em `assets/reference/`, `assets/sprites/animation_concepts/`, `docs/` e `tests/` ficam fora do pacote;
- os antigos `arcane_auditor_prototype.png`, `grave_marshal_prototype.png`, `foreman_prototype.png`, `elf_prototype.png`, `human_warrior_prototype.png`, `mage_prototype.png`, `skeleton_prototype.png` e `zombie_prototype.png` permanecem como referências no repositório, mas não entram no executável;
- ferramentas de desenvolvimento e capturas em `artifacts/` ficam fora do pacote;
- fontes Cinzel/Barlow e seus três avisos `OFL.txt` foram incluídos na exportação;
- o diretório `builds/` permanece ignorado pelo Git.

Os logs e o resumo legível por máquina ficam em `artifacts/validation/`, também ignorado. Assinatura, instalador, depot Steam e teste em outra máquina continuam obrigatórios antes de distribuição pública.
