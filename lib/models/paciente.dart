import 'dart:math';

class Paciente {
  final String id;
  final String nome;
  final int idade;
  final double peso;
  final double altura;
  final String diagnostico;
  final DateTime dataCadastro;
  final String userId; // ID do usuário que cadastrou o paciente
  
  // Dados clínicos adicionais
  final double? creatinina; // mg/dL
  final double? hemoglobinaGlicada; // %
  final DateTime? dataHemoglobinaGlicada;
  final bool usaInsulinaPrevia; // Usuário de insulina antes da internação
  final bool usaCorticoide; // Está em uso de corticoides
  final double? glicemiaAdmissao; // mg/dL

  Paciente({
    required this.id,
    required this.nome,
    required this.idade,
    required this.peso,
    required this.altura,
    required this.diagnostico,
    required this.dataCadastro,
    required this.userId,
    this.creatinina,
    this.hemoglobinaGlicada,
    this.dataHemoglobinaGlicada,
    this.usaInsulinaPrevia = false,
    this.usaCorticoide = false,
    this.glicemiaAdmissao,
  });
  
  // Cálculos automáticos
  double get imc {
    if (altura <= 0) return 0;
    return peso / (altura * altura);
  }
  
  // Cálculo de TFG baseado no escore CKD-EPI (para males)
  double get tfgCkdEpi {
    if (creatinina == null || creatinina! <= 0) return 0;
    // Fórmula CKD-EPI simplificada (para homens com idade e creatinina)
    const a = 141;
    const b = 0.993;
    const c = 1.018; // multiplicador para mulheres seria 1.018, para homens 1.0
    
    double factor = (creatinina! / 0.7);
    if (factor < 1) {
      return a * pow(factor, -0.302) * pow(b, idade) * c;
    } else {
      return a * pow(factor, -1.200) * pow(b, idade) * c;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'idade': idade,
      'peso': peso,
      'altura': altura,
      'diagnostico': diagnostico,
      'dataCadastro': dataCadastro.toIso8601String(),
      'userId': userId,
      'creatinina': creatinina,
      'hemoglobinaGlicada': hemoglobinaGlicada,
      'dataHemoglobinaGlicada': dataHemoglobinaGlicada?.toIso8601String(),
      'usaInsulinaPrevia': usaInsulinaPrevia,
      'usaCorticoide': usaCorticoide,
      'glicemiaAdmissao': glicemiaAdmissao,
    };
  }

  factory Paciente.fromMap(String id, Map<String, dynamic> map) {
    return Paciente(
      id: id,
      nome: map['nome'] ?? '',
      idade: map['idade']?.toInt() ?? 0,
      peso: (map['peso'] ?? 0.0).toDouble(),
      altura: (map['altura'] ?? 0.0).toDouble(),
      diagnostico: map['diagnostico'] ?? '',
      dataCadastro: DateTime.parse(map['dataCadastro']),
      userId: map['userId'] ?? '',
      creatinina: map['creatinina'] != null ? (map['creatinina'] as num).toDouble() : null,
      hemoglobinaGlicada: map['hemoglobinaGlicada'] != null ? (map['hemoglobinaGlicada'] as num).toDouble() : null,
      dataHemoglobinaGlicada: map['dataHemoglobinaGlicada'] != null ? DateTime.parse(map['dataHemoglobinaGlicada']) : null,
      usaInsulinaPrevia: map['usaInsulinaPrevia'] ?? false,
      usaCorticoide: map['usaCorticoide'] ?? false,
      glicemiaAdmissao: map['glicemiaAdmissao'] != null ? (map['glicemiaAdmissao'] as num).toDouble() : null,
    );
  }
}