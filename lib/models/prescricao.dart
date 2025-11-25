class Prescricao {
  final String id;
  final String pacienteId;
  final String pacienteNome;
  final double dosePrescrita;
  final String tipoInsulina;
  final String frequencia; // Ex: "Uma vez ao dia", "Duas vezes ao dia", etc
  final String indicacoes;
  final DateTime dataPrescricao;
  final DateTime? dataVencimento;
  final String userId; // ID do usuário que criou a prescrição

  Prescricao({
    required this.id,
    required this.pacienteId,
    required this.pacienteNome,
    required this.dosePrescrita,
    required this.tipoInsulina,
    required this.frequencia,
    required this.indicacoes,
    required this.dataPrescricao,
    this.dataVencimento,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'pacienteId': pacienteId,
      'pacienteNome': pacienteNome,
      'dosePrescrita': dosePrescrita,
      'tipoInsulina': tipoInsulina,
      'frequencia': frequencia,
      'indicacoes': indicacoes,
      'dataPrescricao': dataPrescricao.toIso8601String(),
      'dataVencimento': dataVencimento?.toIso8601String(),
      'userId': userId,
    };
  }

  factory Prescricao.fromMap(String id, Map<String, dynamic> map) {
    return Prescricao(
      id: id,
      pacienteId: map['pacienteId'] ?? '',
      pacienteNome: map['pacienteNome'] ?? '',
      dosePrescrita: (map['dosePrescrita'] ?? 0.0).toDouble(),
      tipoInsulina: map['tipoInsulina'] ?? '',
      frequencia: map['frequencia'] ?? '',
      indicacoes: map['indicacoes'] ?? '',
      dataPrescricao: DateTime.parse(map['dataPrescricao']),
      dataVencimento: map['dataVencimento'] != null 
          ? DateTime.parse(map['dataVencimento']) 
          : null,
      userId: map['userId'] ?? '',
    );
  }
}
