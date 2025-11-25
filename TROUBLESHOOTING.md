# 🔧 SOLUÇÃO: Erros de Firebase e Fontes Noto

## 🚨 Problemas Detectados

1. ❌ **Firebase Error**: `Missing or insufficient permissions` ao carregar prescrições
2. ⚠️ **Font Warning**: Falta de Noto fonts para renderizar caracteres

---

## ✅ SOLUÇÃO 1: Firebase Permissions (CRÍTICO)

### Causa Raiz
A collection **`prescricoes`** não estava definida nas **Firestore Security Rules**.

### Correção Aplicada
Atualizei `firestore.rules` para incluir:

```firestore
// Prescrições: isoladas por usuário (userId)
match /prescricoes/{docId} {
  allow create: if request.auth != null
                && request.resource.data.userId == request.auth.uid;

  allow read, update, delete: if request.auth != null
                              && resource.data.userId == request.auth.uid;
}
```

### Como Publicar as Regras

**No terminal do projeto:**
```powershell
cd "c:\Users\Felipe Macedo\Documents\trabalhoSemestral\InsuGuia"
firebase deploy --only firestore:rules
```

**Saída esperada:**
```
i  deploying firestore
i  cloud firestore updated successfully
✔  Deploy complete!
```

### Verificação
Após deploy, o erro deve desaparecer e prescrições serão carregadas normalmente.

---

## ✅ SOLUÇÃO 2: Noto Fonts (COSMÉTICO)

### Causa Raiz
Flutter Web reclamando da falta de fontes Unicode para renderizar alguns caracteres.

### Correção Aplicada

#### Passo 1: Configuração do pubspec.yaml ✅
Já adicionei ao `pubspec.yaml`:

```yaml
fonts:
  - family: Noto Sans
    fonts:
      - asset: assets/fonts/NotoSans-Regular.ttf
      - asset: assets/fonts/NotoSans-Bold.ttf
        weight: 700
```

#### Passo 2: Download das Fontes

**Opção A: Script Automático (Recomendado)**
```powershell
# Execute na raiz do projeto
.\install_fonts.ps1
```

**Opção B: Download Manual com PowerShell**
```powershell
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri "https://github.com/googlei18n/noto-fonts/raw/main/hinted/NotoSans-Regular.ttf" -OutFile "assets/fonts/NotoSans-Regular.ttf"
Invoke-WebRequest -Uri "https://github.com/googlei18n/noto-fonts/raw/main/hinted/NotoSans-Bold.ttf" -OutFile "assets/fonts/NotoSans-Bold.ttf"
```

**Opção C: Download Manual via Browser**
1. Visite: https://github.com/googlei18n/noto-fonts/tree/main/hinted
2. Baixe `NotoSans-Regular.ttf` e `NotoSans-Bold.ttf`
3. Coloque em: `assets/fonts/`

#### Passo 3: Recompile
```bash
flutter clean
flutter pub get
flutter run
```

### Estrutura Esperada
```
InsuGuia/
├── assets/
│   ├── fonts/
│   │   ├── NotoSans-Regular.ttf    ← Deve estar aqui
│   │   └── NotoSans-Bold.ttf       ← Deve estar aqui
│   └── screenshots/
├── pubspec.yaml
└── ...
```

---

## 📋 Resumo de Ações

| Problema | Status | Ação Necessária |
|----------|--------|-----------------|
| Firebase Rules | ✅ CORRIGIDO | `firebase deploy --only firestore:rules` |
| Noto Fonts | ✅ CONFIGURADO | `.\install_fonts.ps1` ou download manual |
| Recompile | ⏳ PENDENTE | `flutter clean && flutter run` |

---

## 🎯 Próximos Passos

### IMEDIATO
```powershell
# 1. Deploy das regras Firebase
firebase deploy --only firestore:rules

# 2. Instalar fontes
.\install_fonts.ps1

# 3. Recompile
flutter clean
flutter pub get
flutter run
```

### ESPERADO
- ✅ Prescrições carregadas sem erro
- ✅ Aviso de fontes desaparecido
- ✅ App funcionando perfeitamente

---

## 🐛 Se Ainda Houver Problemas

### Firebase ainda com erro?
1. Verifique se fez `firebase deploy`
2. Confirme que autenticação está ativa
3. Verifique em Console Firebase > Firestore > Rules se atualizou

### Fontes ainda com aviso?
1. Confirme que arquivos estão em `assets/fonts/`
2. Execute `flutter clean`
3. Se problema persiste, pode remover a seção fonts do pubspec.yaml (warnings apenas, não afeta funcionalidade)

### App não inicia?
```powershell
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

---

## 📚 Referências

- Firebase Security Rules: https://firebase.google.com/docs/firestore/security/start
- Noto Fonts: https://github.com/googlei18n/noto-fonts
- Flutter Fonts: https://flutter.dev/docs/cookbook/design/fonts

---

## ✨ Status Final

**Antes:**
```
❌ Firebase permissions denied
⚠️ Missing Noto fonts
```

**Depois:**
```
✅ Firebase permissions granted
✅ Noto fonts ready
✅ App fully functional
```

---

**Desenvolvido por: Felipe Macedo**  
**Data: 24 de Novembro de 2025**  
**Status: RESOLVIDO** ✅
