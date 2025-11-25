# 🔤 Setup de Fontes Noto

O Flutter está reclamando da falta de **Noto fonts** para renderizar corretamente alguns caracteres, especialmente em web.

## ✅ Como Resolver

### Opção 1: Download Automático (Recomendado)
Execute este comando PowerShell na raiz do projeto:

```powershell
# Baixa as fontes Noto Sans do Google
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://github.com/googlei18n/noto-fonts/raw/main/hinted/NotoSans-Regular.ttf" -OutFile "assets/fonts/NotoSans-Regular.ttf"
Invoke-WebRequest -Uri "https://github.com/googlei18n/noto-fonts/raw/main/hinted/NotoSans-Bold.ttf" -OutFile "assets/fonts/NotoSans-Bold.ttf"

Write-Host "✅ Fontes Noto instaladas com sucesso!" -ForegroundColor Green
```

### Opção 2: Download Manual
1. Visite: https://github.com/googlei18n/noto-fonts/tree/main/hinted
2. Baixe:
   - `NotoSans-Regular.ttf`
   - `NotoSans-Bold.ttf`
3. Coloque em: `assets/fonts/`

### Opção 3: Remover o Requisito (Menos Recomendado)
Se não precisa de suporte a caracteres especiais, remova a seção fonts do `pubspec.yaml`:

```yaml
# fonts:
#   - family: Noto Sans
#     fonts:
#       - asset: assets/fonts/NotoSans-Regular.ttf
#       - asset: assets/fonts/NotoSans-Bold.ttf
#         weight: 700
```

---

## 🔍 Status Atual

✅ Configuração de fontes adicionada ao `pubspec.yaml`  
✅ Pasta `assets/fonts/` criada  
⏳ Aguardando download dos arquivos .ttf

---

## 📝 Estrutura Esperada

```
project/
├── assets/
│   └── fonts/
│       ├── NotoSans-Regular.ttf
│       └── NotoSans-Bold.ttf
├── pubspec.yaml
└── ...
```

---

## 🚀 Após Instalar as Fontes

Execute:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 💡 Notas

- As fontes Noto são livres e open-source (SIL Open Font License)
- Melhoram significativamente a renderização em web
- Reduzem avisos durante build

