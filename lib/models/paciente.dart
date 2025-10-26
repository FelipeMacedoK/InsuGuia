class Paciente {
  final String id;
  final String nome;
  final int idade;
  final double peso;
  final double altura;
  final String diagnostico;
  final DateTime dataCadastro;
  final String userId; // ID do usuário que cadastrou o paciente

  Paciente({
    required this.id,
    required this.nome,
    required this.idade,
    required this.peso,
    required this.altura,
    required this.diagnostico,
    required this.dataCadastro,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'idade': idade,
      'peso': peso,
      'altura': altura,
      'diagnostico': diagnostico,
      'dataCadastro': dataCadastro.toIso8601String(),
      'userId': userId,
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
    );
  }
}