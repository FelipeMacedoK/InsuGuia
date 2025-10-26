class RegistroInsulina {
  final String id;
  final String pacienteId;
  final String pacienteNome;
  final double glicemia;
  final double doseInsulina;
  final String tipoInsulina;
  final DateTime dataRegistro;
  final String userId;

  RegistroInsulina({
    required this.id,
    required this.pacienteId,
    required this.pacienteNome,
    required this.glicemia,
    required this.doseInsulina,
    required this.tipoInsulina,
    required this.dataRegistro,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'pacienteId': pacienteId,
      'pacienteNome': pacienteNome,
      'glicemia': glicemia,
      'doseInsulina': doseInsulina,
      'tipoInsulina': tipoInsulina,
      'dataRegistro': dataRegistro.toIso8601String(),
      'userId': userId,
    };
  }

  factory RegistroInsulina.fromMap(String id, Map<String, dynamic> map) {
    return RegistroInsulina(
      id: id,
      pacienteId: map['pacienteId'] ?? '',
      pacienteNome: map['pacienteNome'] ?? '',
      glicemia: (map['glicemia'] ?? 0.0).toDouble(),
      doseInsulina: (map['doseInsulina'] ?? 0.0).toDouble(),
      tipoInsulina: map['tipoInsulina'] ?? '',
      dataRegistro: DateTime.parse(map['dataRegistro']),
      userId: map['userId'] ?? '',
    );
  }
}