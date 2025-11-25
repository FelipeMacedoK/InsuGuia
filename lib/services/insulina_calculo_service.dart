enum SensibilidadeInsulina { sensivel, usual, resistente }

enum EsquemaInsulina { somenteCorracao, basalCorracao, basalBolus }

enum TipoDieta { oral, npo, enteral, parenteral }

class DosesInsulina {
  final double tdd; // Dose Total Diária
  final double basalDiaria; // Dose basal diária
  final double bolusDiario; // Dose de bôlus diária (50% TDD)
  final double corracao; // Dose de correção base

  DosesInsulina({
    required this.tdd,
    required this.basalDiaria,
    required this.bolusDiario,
    required this.corracao,
  });
}

class InsulinaCalculoService {
  // Critérios para sensibilidade à insulina
  static SensibilidadeInsulina determinarSensibilidade({
    required double? hemoglobinaGlicada,
    required double? imc,
    required bool usaCorticoide,
  }) {
    // Se usa corticoide, considerar mais resistente
    if (usaCorticoide) {
      return SensibilidadeInsulina.resistente;
    }

    // Se hemoglobina glicada disponível e > 9%, considerar resistente
    if (hemoglobinaGlicada != null && hemoglobinaGlicada > 9.0) {
      return SensibilidadeInsulina.resistente;
    }

    // Se IMC > 30 (obeso), considerar resistente
    if (imc != null && imc > 30) {
      return SensibilidadeInsulina.resistente;
    }

    // Se hemoglobina glicada < 6%, considerar sensível
    if (hemoglobinaGlicada != null && hemoglobinaGlicada < 6.0) {
      return SensibilidadeInsulina.sensivel;
    }

    // Padrão: usual
    return SensibilidadeInsulina.usual;
  }

  // Determinar esquema de insulina baseado em critérios clínicos
  static EsquemaInsulina determinarEsquema({
    required double glicemiaAdmissao,
    required List<double> glicemiasRegistradas,
    required bool usaInsulinaPrevia,
    required TipoDieta tipoDieta,
  }) {
    // Critério 1: Se já usa insulina, precisa de basal
    if (usaInsulinaPrevia) {
      if (tipoDieta == TipoDieta.npo) {
        return EsquemaInsulina.basalCorracao;
      } else if (tipoDieta == TipoDieta.oral) {
        return EsquemaInsulina.basalBolus;
      } else {
        return EsquemaInsulina.basalBolus; // enteral/parenteral
      }
    }

    // Contar glicemias > 180 mg/dL
    int glicemiasAltas = glicemiasRegistradas
        .where((g) => g > 180)
        .length;

    // Contar glicemias > 250 mg/dL (severa)
    int glicemiasSeversas = glicemiasRegistradas
        .where((g) => g > 250)
        .length;

    // Critério 2: Se tem mais de 1 glicemia > 180 ou severa (> 250)
    if (glicemiasAltas > 1 || glicemiasSeversas > 0) {
      if (tipoDieta == TipoDieta.npo) {
        return EsquemaInsulina.basalCorracao;
      } else if (tipoDieta == TipoDieta.oral) {
        return EsquemaInsulina.basalBolus;
      } else {
        return EsquemaInsulina.basalBolus; // enteral/parenteral
      }
    }

    // Critério 3: Se tem no máximo 1 glicemia > 180 e nenhuma > 250
    // ou se glicemia máxima entre 180-200
    if (glicemiasAltas <= 1 && glicemiasSeversas == 0) {
      return EsquemaInsulina.somenteCorracao;
    }

    // Padrão
    return EsquemaInsulina.somenteCorracao;
  }

  // Calcular doses de insulina
  static DosesInsulina calcularDoses({
    required double peso,
    required SensibilidadeInsulina sensibilidade,
    required EsquemaInsulina esquema,
  }) {
    // Fator de sensibilidade para cálculo da TDD
    late double fatorTDD;
    late double fatorBasal;

    switch (sensibilidade) {
      case SensibilidadeInsulina.sensivel:
        fatorTDD = 0.2; // UI/kg
        fatorBasal = 0.1; // UI/kg
        break;
      case SensibilidadeInsulina.usual:
        fatorTDD = 0.3; // UI/kg
        fatorBasal = 0.15; // UI/kg
        break;
      case SensibilidadeInsulina.resistente:
        fatorTDD = 0.6; // UI/kg
        fatorBasal = 0.3; // UI/kg
        break;
    }

    final tdd = peso * fatorTDD;
    final basalDiaria = peso * fatorBasal;
    final bolusDiario = tdd * 0.5; // 50% da TDD

    // Dose de correção (tabela 3 das diretrizes)
    // Baseada em sensibilidade
    late double corracao;
    switch (sensibilidade) {
      case SensibilidadeInsulina.sensivel:
        corracao = 1.0; // 1 UI para cada incremento de glicemia
        break;
      case SensibilidadeInsulina.usual:
        corracao = 2.0; // 2 UI para cada incremento de glicemia
        break;
      case SensibilidadeInsulina.resistente:
        corracao = 4.0; // 4 UI para cada incremento de glicemia
        break;
    }

    return DosesInsulina(
      tdd: arredondar(tdd),
      basalDiaria: arredondar(basalDiaria),
      bolusDiario: arredondar(bolusDiario),
      corracao: corracao,
    );
  }

  // Arredondar doses para inteiras (pode ser adaptado para pares conforme dispositivo)
  static double arredondar(double valor) {
    // Arredondar para o inteiro mais próximo
    return (valor).roundToDouble();
  }

  // Calcular tabela de correção baseada em sensibilidade
  static Map<String, double> obterTabelaCorrecao(
    SensibilidadeInsulina sensibilidade,
  ) {
    // Faixas de glicemia e doses correspondentes (em UI)
    return {
      'menor_100': 0, // Oferecer lanche (hipoglicemia)
      '100_180': 0, // Sem correção
      '181_250': sensibilidade == SensibilidadeInsulina.sensivel ? 1 : (sensibilidade == SensibilidadeInsulina.usual ? 2 : 4),
      '251_350': sensibilidade == SensibilidadeInsulina.sensivel ? 2 : (sensibilidade == SensibilidadeInsulina.usual ? 4 : 8),
      'maior_351': sensibilidade == SensibilidadeInsulina.sensivel ? 3 : (sensibilidade == SensibilidadeInsulina.usual ? 4 : 8),
    };
  }

  // Obter orientações para monitorização baseado no tipo de dieta
  static Map<String, dynamic> obterOrientacoesMonitorizacao(
    TipoDieta tipoDieta,
    EsquemaInsulina esquema,
  ) {
    if (tipoDieta == TipoDieta.oral) {
      return {
        'frequencia': 'AC, AA, AJ e 22h', // Antes café, almoço, jantar e 22h
        'horarios': ['06:00', '12:00', '18:00', '22:00'],
        'descricao': 'Antes do café, almoço, jantar e às 22 horas',
      };
    } else if (tipoDieta == TipoDieta.npo || tipoDieta == TipoDieta.enteral || tipoDieta == TipoDieta.parenteral) {
      return {
        'frequencia': '6/6h (opcional 4/4h)',
        'horarios': ['00:00', '06:00', '12:00', '18:00'],
        'descricao': 'A cada 6 horas (ou 4 horas opcional)',
      };
    }

    return {'frequencia': 'Conforme protocolo'};
  }

  // Orientações para hipoglicemia (< 70 mg/dL)
  static String obterOrientacaoHipoglicemia() {
    return '''
Se glicemia capilar < 70 mg/dL:
• Se paciente consciente e capaz de deglutir: Oferecer 30 mL de glicose 50% (ou alimento líquido açucarado)
• Se paciente inconsciente ou incapaz de deglutir: Aplicar 30 mL de glicose 50% IV em veia calibrosa
• Repetir glicemia capilar e administração de glicose a cada 15 minutos até glicemia > 100 mg/dL
    ''';
  }

  // Orientação para às 22h (snack time)
  static String obterOrientacao22h() {
    return '''
Orientação para glicemia das 22 horas:
• Abaixo de 100 mg/dL: Oferecer lanche
• 100 a 250 mg/dL: 0 UI
• 251 a 350 mg/dL: Aplicar 2 UI de Insulina Regular SC
• 351 ou acima: Aplicar 4 UI de Insulina Regular SC
    ''';
  }

  // Sugestão de monitorização com corticoide
  static String obterOrientacaoCorticoide() {
    return '''
Orientações especiais - Paciente em uso de corticoide:
• Aumenta sensibilidade à hiperglicemia
• Recomenda-se intensificar monitorização de glicemia
• Pode necessitar de aumentos nas doses de insulina
• Avaliar reclassificação de sensibilidade para RESISTENTE
    ''';
  }
}
