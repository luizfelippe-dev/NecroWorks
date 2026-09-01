# Gerando o build Windows

O preset `Windows Desktop` exporta para `builds/windows/NecroWorks.exe`. A pasta `builds` fica fora do Git.

## Requisitos

- Godot 4.7.1 stable;
- templates de exportação da mesma versão;
- projeto importado sem erros;
- 50 runners aprovados antes de distribuir o executável.

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
4. testar fullscreen, áudio e pausa;
5. concluir ao menos uma run;
6. iniciar o executável em outro computador sem o editor;
7. registrar versão, commit e resultado do teste em `docs/DEVLOG.md`.

## Build validado

- arquivo local: `builds/windows/NecroWorks.exe`;
- tamanho: 113.020.464 bytes;
- SHA-256: `11F3AD2C7EA885F85BFF6EBA153D04534A9E1EC309A402D5A2A7610CDB696628`;
- exportação release e inicialização headless aprovadas em 01/09/2026;
- o diretório `builds/` permanece ignorado pelo Git.
