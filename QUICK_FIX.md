# 🆘 QUICK FIX - Erros Encontrados

## TL;DR (3 Passos = 5 Minutos)

```powershell
# 1. Deploy Firebase
firebase deploy --only firestore:rules

# 2. Instalar Fontes
.\install_fonts.ps1

# 3. Recompile
flutter clean && flutter pub get && flutter run
```

---

## ❌ Erro #1: Firebase - Permission Denied

**Mensagem:**
```
FirebaseException getPrescricoes: permission-denied
Missing or insufficient permissions
```

**Causa:** Rules não incluem collection `prescricoes`  
**Solução:** ✅ JÁ APLICADA no `firestore.rules`  
**Para Publicar:**
```bash
firebase deploy --only firestore:rules
```

---

## ⚠️ Erro #2: Missing Noto Fonts

**Mensagem:**
```
Could not find a set of Noto fonts to display all missing characters
```

**Causa:** Fontes Unicode não instaladas  
**Solução:** ✅ SCRIPT CRIADO `install_fonts.ps1`  
**Para Executar:**
```powershell
.\install_fonts.ps1
```

---

## 📁 Arquivos Criados para Ajudar

| Arquivo | Uso |
|---------|-----|
| `install_fonts.ps1` | ⭐ Execute isto primeiro |
| `TROUBLESHOOTING.md` | Guia completo |
| `CHECKLIST_RESOLUCAO.md` | Passo-a-passo detalhado |
| `STATUS_RESOLUCAO.md` | Status visual |

---

**Desenvolvido por: Felipe Macedo**  
**Status: ✅ PRONTO PARA APLICAR**
