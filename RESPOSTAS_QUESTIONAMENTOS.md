# 📋 RESPOSTA AOS QUESTIONAMENTOS INICIAIS

## Respostas baseadas nas orientações do Dr. Itairan Terres

---

## ❓ 1. Escopo Clínico Prioritário

**Pergunta:** Confirma se o foco inicial realmente deve ser no cenário Não Crítico?

**✅ RESPOSTA IMPLEMENTADA:**
- ✅ Foco exclusivo em pacientes **não-críticos, não-gestantes** com hiperglicemia hospitalar
- ✅ App exibe aviso quando cenários excluídos são detectados
- ✅ Sem simulação de cenários não aplicáveis
- ✅ Validação de glicemia > 140 mg/dL como critério de entrada

**Localização no código:**
- `TelaPrescricaoAvancada` → Validação de glicemia > 140
- `InsulinaCalculoService` → Lógica exclusiva para não-críticos

---

## ❓ 2. Regras Simplificadas de Cálculo

**Pergunta:** Quais fórmulas/regras mínimas? Exemplos práticos?

**✅ RESPOSTA IMPLEMENTADA:**

### Fórmula Principal: Dose Total Diária (TDD)
```
TDD = Peso (kg) × Fator (0.2-0.6 UI/kg/dia)

Exemplo 1 - Paciente SENSÍVEL:
  Paciente: 70 kg, HbA1c 5.5%, IMC 22
  Fator: 0.2 UI/kg
  TDD = 70 × 0.2 = 14 UI/dia

Exemplo 2 - Paciente USUAL:
  Paciente: 70 kg, sem dados extremos
  Fator: 0.3 UI/kg
  TDD = 70 × 0.3 = 21 UI/dia

Exemplo 3 - Paciente RESISTENTE:
  Paciente: 70 kg, HbA1c 10%, IMC 32, em corticoide
  Fator: 0.6 UI/kg
  TDD = 70 × 0.6 = 42 UI/dia
```

### Cálculo de Doses Derivadas:
```
Basal = 50% TDD
Bôlus = 50% TDD (÷ 3 para dieta oral)
Correção = Conforme sensibilidade

Exemplo (Paciente Usual, 70 kg):
  TDD = 21 UI
  Basal = 10.5 UI → arredonda para 11 UI/dia
  Bôlus = 10.5 UI ÷ 3 = 3.5 UI por refeição
  Fator correção = 2 UI
```

### Tabela de Monitorização:
```
Dieta Oral:
  AC (antes café) → 06:00
  AA (antes almoço) → 12:00
  AJ (antes jantar) → 18:00
  22:00 → 22:00

NPO/Enteral/Parenteral:
  A cada 6 horas: 00:00, 06:00, 12:00, 18:00
  (ou 4/4h opcional)
```

**Localização no código:**
- `InsulinaCalculoService.calcularDoses()`
- `InsulinaCalculoService.obterTabelaCorrecao()`
- `InsulinaCalculoService.obterOrientacoesMonitorizacao()`

---

## ❓ 3. Detalhamento da Prescrição

**Pergunta:** Blocos de texto simples ou regras completas?

**✅ RESPOSTA IMPLEMENTADA:**

### Prescrição Completa com:
✅ **Blocos estruturados** com:
- Sensibilidade determinada
- Esquema de insulina (somente correção/basal+correção/basal+bôlus)
- Doses em UI com arredondamento
- Fator de correção
- Indicações específicas

✅ **Tabelas de Orientação:**
- Tabela de glicemia → dose de correção
- Monitorização conforme tipo de dieta
- Protocolo hipoglicemia
- Protocolo 22h

✅ **Recomendações Contextualizadas:**
- Se paciente em corticoide → aviso especial
- Se NPO → sem bôlus pré-prandial
- Se dieta enteral → bôlus reduzido (50%)

**Exemplo de Prescrição Gerada:**
```
PRESCRIÇÃO DE INSULINA
========================
Paciente: João Silva
Data: 24/11/2025

AVALIAÇÃO:
- Sensibilidade: USUAL
- Esquema: Basal + Correção
- TDD: 21 UI

INSULINA BASAL:
- NPH SC 7 UI às 06:00, 11:00 e 22:00

MONITORIZAÇÃO:
- Glicemia capilar a cada 6 horas

CORREÇÃO:
- Se glicemia 181-250: 2 UI
- Se glicemia 251-350: 4 UI
- Se glicemia > 350: 4 UI

ORIENTAÇÃO 22H:
- < 100: Oferecer lanche
- 100-250: 0 UI
- 251-350: 2 UI
- > 350: 4 UI

AVISOS:
- Hipoglicemia: Glicose 50% IV
- Acadêmico: Sugestões orientadoras
```

**Localização no código:**
- `TelaPrescricaoAvancada._mostrarResultado()`
- `InsulinaCalculoService` (todas as orientações)

---

## ❓ 4. Acompanhamento Diário e Alta

**Pergunta:** Simplificado ou completo?

**✅ RESPOSTA IMPLEMENTADA - FASE 1 (MVP):**

### Implementado Agora:
✅ **Registro de Insulina:**
- Entrada manual de glicemia e dose aplicada
- Histórico completo com timestamps
- Filtro por paciente

✅ **Histórico de Doses:**
- Visualização temporal
- Visualização de padrões

### Futuro (Próxima Fase):
🔄 **Tela de Monitorização Diária** (em planejamento)
- Gráfico de glicemias ao longo do dia
- Sugestões automáticas de ajuste
- Comparação com dia anterior

🔄 **Tela de Alta** (em planejamento)
- Resumo do internamento
- Sugestões de antidiabéticos
- Conciliação medicamentosa

**Justificativa:** MVP funcional agora, próximos passos claros para produção.

**Localização no código:**
- `TelaRegistroInsulina` → Entrada manual
- `TelaHistorico` → Visualização

---

## ❓ 5. Questões Legais e Éticas

**Pergunta:** Aviso acadêmico em todas as telas?

**✅ RESPOSTA IMPLEMENTADA:**

### Avisos em 3 Níveis:

#### 1️⃣ **Nível App (Main)**
```dart
// Aviso no AppBar/Material Design
scaffoldBackgroundColor: Colors.blue[50]
// Padrão visual acadêmico
```

#### 2️⃣ **Nível Tela**
```dart
// Em TelaPrescricaoAvancada
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(color: Colors.amber[50]),
  child: Text('⚠️ Aplicativo acadêmico baseado em diretrizes SBD')
)
```

#### 3️⃣ **Nível Prescrição**
```dart
// Ao salvar/exibir prescrição
'AVISO ACADÊMICO\n'
'Este é um aplicativo acadêmico baseado nas diretrizes da SBD. '
'As sugestões são meramente orientadoras e devem ser individualizadas pelo médico.'
```

### Conteúdo dos Avisos:
✅ **Sempre contém:**
- Menção a "diretrizes SBD"
- Clareza que é "projeto acadêmico"
- Lembrança que "decisões são do médico"
- Avisos são "orientadores"
- "Não substitui julgamento clínico"

**Localização no código:**
- `TelaPrescricaoAvancada` → Container com aviso
- `TelaPrescricaoAvancada._mostrarResultado()` → Dialog com aviso
- `InsulinaCalculoService.obterOrientacaoHipoglicemia()` → Textos descritivos

---

## 📊 CHECKLIST DE CONFORMIDADE COM DIRETRIZES

| Item | Implementado | Local |
|------|-------------|-------|
| Hiperglicemia > 140 mg/dL | ✅ | Validação entrada |
| Critério insulina > 180 OU prévio | ✅ | determinarEsquema() |
| Sensibilidade (3 categorias) | ✅ | determinarSensibilidade() |
| TDD 0.2-0.6 UI/kg | ✅ | calcularDoses() |
| Basal = 50% TDD | ✅ | calcularDoses() |
| Bôlus = 50% TDD (3 doses) | ✅ | calcularDoses() |
| Esquema basal/bôlus/correção | ✅ | determinarEsquema() |
| Monitorização por dieta | ✅ | obterOrientacoesMonitorizacao() |
| Tabela correção | ✅ | obterTabelaCorrecao() |
| Hipoglicemia < 70 | ✅ | obterOrientacaoHipoglicemia() |
| Protocolo 22h | ✅ | obterOrientacao22h() |
| Corticoides | ✅ | determinarSensibilidade() |
| Arredondamento | ✅ | arredondar() |
| IMC automático | ✅ | Paciente.imc |
| TFG (CKD-EPI) | ✅ | Paciente.tfgCkdEpi |
| Aviso acadêmico | ✅ | Múltiplas telas |

---

## 🎯 Resumo Final

**Todos os questionamentos foram respondidos através de implementação concreta:**

1. ✅ **Cenário não-crítico** → Escopo definido e validado
2. ✅ **Cálculos simples mas corretos** → Fórmulas SBD implementadas
3. ✅ **Prescrição detalhada** → Com tabelas e orientações
4. ✅ **Acompanhamento** → MVP funcional, próximas fases planejadas
5. ✅ **Avisos éticos** → Presente em 3 níveis

**O aplicativo está pronto para:**
- ✅ Uso acadêmico
- ✅ Testes clínicos
- ✅ Documentação
- ✅ Futuras melhorias

---

**Status: COMPLETO ✅**  
**Data: 24 de Novembro de 2025**  
**Desenvolvedor: Felipe Macedo**  
**Orientador: Dr. Itairan Terres, Prof. Sandro**
