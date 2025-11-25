# InsuGuia - Aplicativo Acadêmico de Suporte à Prescrição de Insulina

## 📋 Visão Geral

InsuGuia é um aplicativo acadêmico desenvolvido para **estudantes de Sistemas de Informação** que visa apoiar a prescrição de insulina em pacientes hospitalares **em cenário não-crítico** com hiperglicemia hospitalar, seguindo as **diretrizes da Sociedade Brasileira de Diabetes (SBD)**.

⚠️ **AVISO**: Este é um projeto acadêmico. As sugestões são meramente orientadoras e devem ser individualizadas pelo médico responsável.

---

## 🎯 Escopo Clínico

### População Alvo
- ✅ Pacientes **não-críticos**
- ✅ Pacientes **não-gestantes**
- ✅ Pacientes com **hiperglicemia hospitalar** (glicemia capilar > 140 mg/dL)

---

## 🚀 Funcionalidades Implementadas

### 1. **Autenticação e Gestão de Usuários**
- Login/Signup com Firebase Authentication
- Logout
- Persistência de sessão

### 2. **Cadastro de Pacientes**
- Informações demográficas (nome, idade, peso, altura)
- Diagnóstico clínico
- **Dados clínicos avançados:**
  - Creatinina (mg/dL)
  - Hemoglobina glicada (%)
  - Glicemia na admissão
  - Histórico de uso de insulina
  - Uso de corticoides
  
- **Cálculos automáticos:**
  - IMC (Índice de Massa Corporal)
  - TFG (Taxa de Filtração Glomerular) via escore CKD-EPI

### 3. **Registros de Insulina**
- Registro de doses aplicadas
- Armazenamento de glicemias
- Histórico completo com filtros por paciente

### 4. **Prescrição Avançada de Insulina**

#### Avaliação Clínica Inicial
1. **Determinação da Sensibilidade à Insulina:**
   - **Sensível**: Pacientes com HbA1c < 6%, IMC < 25, sem corticoides
   - **Usual**: Pacientes com perfil padrão
   - **Resistente**: HbA1c > 9%, IMC > 30, uso de corticoides

2. **Determinação do Esquema de Insulina:**
   - **Somente Correção**: Glicemia 180-200 mg/dL, máx 1 glicemia > 180/dia, nenhuma > 250
   - **Basal + Correção**: NPO, múltiplas glicemias altas
   - **Basal + Bôlus**: Dieta oral com glicemias persistentes > 250 ou uso prévio de insulina

#### Cálculos Automáticos
- **Dose Total Diária (TDD):** 0.2-0.6 UI/kg/dia (conforme sensibilidade)
- **Dose Basal:** 50% da TDD distribuída ao longo do dia
- **Dose de Bôlus:** 50% da TDD dividida em 3 refeições
- **Fator de Correção:** Baseado em sensibilidade

#### Tipos de Insulina Suportados
- **Basais:** NPH, Glargina, Degludeca
- **Ação Rápida:** Regular, Aspart, Glulisina, Lispro

#### Recomendações de Monitorização
- **Dieta Oral:** AC (café), AA (almoço), AJ (jantar) + 22h
- **NPO/Enteral/Parenteral:** A cada 6 horas (opcional 4/4h)

### 5. **Histórico de Prescrições**
- Visualização de todas as prescrições
- Filtros por paciente
- Indicador de prescrições vencidas
- Exclusão de prescrições com confirmação

### 6. **Histórico de Aplicações**
- Registro completo de doses aplicadas
- Associação com paciente
- Visualização temporal

---

## 📊 Lógica Clínica Implementada

### Critérios para Insulinoterapia
Conforme diretrizes SBD:
1. Paciente já fazia uso prévio de insulina, OU
2. Glicemia > 180 mg/dL

### Determinação do Esquema
```
SE paciente usa insulina:
  SE em NPO → Basal/Correção
  SE em dieta oral → Basal/Bôlus
  SE enteral/parenteral → Basal/Bôlus (dose reduzida)
SENÃO:
  SE glicemias altas persistentes (> 1/dia) OU severas (> 250) → Basal/Correção ou Bôlus
  SENÃO → Somente Correção
```

### Arredondamento de Doses
- Arredonda para unidades inteiras (adaptável para pares conforme dispositivo)

### Orientações Especiais
- **Hipoglicemia (< 70 mg/dL):** Glicose 50% IV/VO
- **Glicemia 22h:** Lanche se < 100, sem insulina se 100-250, doses progressivas acima
- **Pacientes em Corticoide:** Intensificar monitorização

---

## 🏗️ Arquitetura Técnica

### Estrutura de Dados

#### Modelo: Paciente
```dart
- id, nome, idade
- peso (kg), altura (m)
- diagnostico
- creatinina (mg/dL)
- hemoglobinaGlicada (%)
- usaInsulinaPrevia (bool)
- usaCorticoide (bool)
- glicemiaAdmissao (mg/dL)
- Cálculos automáticos: IMC, TFG
```

#### Modelo: Prescricao
```dart
- pacienteId, pacienteNome
- dosePrescrita (UI)
- tipoInsulina
- frequencia
- indicacoes
- dataPrescricao, dataVencimento
```

#### Modelo: RegistroInsulina
```dart
- pacienteId, pacienteNome
- glicemia, doseInsulina
- tipoInsulina
- dataRegistro
```

### Serviços

#### FirestoreService
- CRUD para Pacientes, Prescrições, Registros de Insulina
- Streams para atualização em tempo real
- Filtros por usuário logado

#### InsulinaCalculoService
- `determinarSensibilidade()`: Classifica paciente
- `determinarEsquema()`: Define tipo de insulina
- `calcularDoses()`: Calcula TDD e doses
- `obterTabelaCorrecao()`: Retorna doses de correção
- `obterOrientacoes*()`: Mensagens educativas

---

## 📱 Telas Principais

1. **Tela de Login/Signup** - Autenticação
2. **Tela Principal** - Dashboard com menu
3. **Tela de Cadastro** - Adicionar novos pacientes
4. **Tela de Prescrição Avançada** - Motor de cálculo
5. **Tela de Histórico de Prescrições** - Visualização
6. **Tela de Registro de Insulina** - Aplicações
7. **Tela de Histórico** - Doses aplicadas

---

## 🔒 Segurança e LGPD

- ✅ Autenticação obrigatória
- ✅ Dados isolados por usuário
- ✅ Preparado para avaliação de conformidade LGPD
- ✅ Aviso acadêmico em todas as prescrições

---

## 🚀 Próximos Passos / Futuras Melhorias

### Curto Prazo
- [ ] Tela de monitorização diária com ajustes de dose
- [ ] Tela de alta com conciliação de antidiabéticos
- [ ] Dashboard com estatísticas por paciente

### Médio Prazo
- [ ] Integração com sistemas hospitalares para importar dados clínicos
- [ ] Cálculo automático de TFG via escore CKD-EPI completo
- [ ] Sugestões para pacientes com uso de corticoides

### Longo Prazo
- [ ] Machine Learning para previsão de resposta à insulina
- [ ] Análise de padrões de glicemia ao longo da internação
- [ ] Suporte a múltiplos idiomas
- [ ] Versão para tablets com sincronização em tempo real

---

## 📚 Referências

- Diretrizes da Sociedade Brasileira de Diabetes (SBD) para Hiperglicemia Hospitalar
- Fórmula CKD-EPI para cálculo de TFG
- Firebase Firestore para persistência de dados
- Flutter para interface multiplataforma

---

## 🎓 Projeto Educacional

Este aplicativo foi desenvolvido como projeto extensão do Curso de Sistemas de Informação, com objetivo de:
- Aplicar conceitos de engenharia de software
- Integrar conhecimento médico com tecnologia
- Gerar ferramenta com alta aplicabilidade clínica
- Fomentar desenvolvimento de soluções em saúde digital

---