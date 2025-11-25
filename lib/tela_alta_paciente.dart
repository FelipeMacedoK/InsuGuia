import 'package:flutter/material.dart';
import 'models/paciente.dart';
import 'models/registro_insulina.dart';
import 'services/firestore_service.dart';

class TelaAltaPaciente extends StatefulWidget {
  const TelaAltaPaciente({super.key});

  @override
  State<TelaAltaPaciente> createState() => _TelaAltaPacienteState();
}

class _TelaAltaPacienteState extends State<TelaAltaPaciente> {
  final _firestoreService = FirestoreService();
  Paciente? _pacienteSelecionado;
  List<RegistroInsulina>? _registros;
  final TextEditingController _observacoesController = TextEditingController();

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  void _carregarRegistros() {
    if (_pacienteSelecionado == null) return;

    _firestoreService
        .getRegistrosPorPaciente(_pacienteSelecionado!.id)
        .first
        .then((registros) {
      setState(() => _registros = registros);
    });
  }

  Widget _buildOrientacaoCard(
    String titulo,
    String descricao,
    IconData icone,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alta do Paciente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aviso
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Preencha informações de alta e receba sugestões de conduta.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seleção de paciente
            const Text(
              'Paciente',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Paciente>>(
              stream: _firestoreService.getPacientes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final pacientes = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Selecione Paciente',
                    border: OutlineInputBorder(),
                  ),
                  items: pacientes.map((p) {
                    return DropdownMenuItem(value: p.id, child: Text(p.nome));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _pacienteSelecionado =
                            pacientes.firstWhere((p) => p.id == value);
                        _carregarRegistros();
                      });
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            if (_pacienteSelecionado != null) ...[
              // Resumo do internamento
              const Text(
                'Resumo do Internamento',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        'Paciente:',
                        _pacienteSelecionado!.nome,
                      ),
                      _buildInfoRow(
                        'Idade:',
                        '${_pacienteSelecionado!.idade} anos',
                      ),
                      _buildInfoRow(
                        'IMC:',
                        '${_pacienteSelecionado!.imc.toStringAsFixed(1)} kg/m²',
                      ),
                      if (_pacienteSelecionado!.hemoglobinaGlicada != null)
                        _buildInfoRow(
                          'HbA1c:',
                          '${_pacienteSelecionado!.hemoglobinaGlicada}%',
                        ),
                      if (_registros != null)
                        _buildInfoRow(
                          'Total de registros:',
                          '${_registros!.length} aplicações',
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Observações
              const Text(
                'Observações Clínicas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Comentários sobre a internação',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Paciente respondeu bem ao tratamento...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Orientações de alta
              const Text(
                'Recomendações para Alta',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _buildOrientacaoCard(
                'Continuidade do Tratamento',
                'Manter acompanhamento ambulatorial com endocrinologista dentro de 4 semanas. '
                'Se paciente era diabético antes, retomar medicações prévias conforme prescrição do especialista.',
                Icons.local_hospital,
              ),
              const SizedBox(height: 12),

              _buildOrientacaoCard(
                'Monitorização de Glicemia',
                'Manter registro de glicemias domiciliares conforme orientação do seu médico. '
                'Trazer registros para consulta de acompanhamento.',
                Icons.show_chart,
              ),
              const SizedBox(height: 12),

              _buildOrientacaoCard(
                'Dieta e Estilo de Vida',
                'Seguir orientações nutricionais fornecidas. '
                'Manter atividade física regular conforme capacidade clínica. '
                'Evitar alimentos ultraprocedados.',
                Icons.restaurant,
              ),
              const SizedBox(height: 12),

              _buildOrientacaoCard(
                'Medicações',
                'Tomar insulina ou antidiabéticos conforme prescrição. '
                'Se dúvidas sobre uso, contatar farmacêutico ou médico. '
                'Não fazer ajustes sem orientação profissional.',
                Icons.medication,
              ),
              const SizedBox(height: 12),

              _buildOrientacaoCard(
                'Emergências',
                'Se apresentar sintomas de hipoglicemia (tremor, suor, confusão), '
                'consumir 15g de carboidrato simples (suco, mel, açúcar). '
                'Se não melhorar em 15min ou perda de consciência, chamar ambulância.',
                Icons.emergency,
              ),
              const SizedBox(height: 12),

              _buildOrientacaoCard(
                'Conciliação Medicamentosa',
                'Levar lista de medicações atuais para consulta com seu médico. '
                'Informar se está tomando corticoides ou outros medicamentos. '
                'Nunca descontinuar medicação sem orientação.',
                Icons.checklist,
              ),
              const SizedBox(height: 24),

              // Botão finalizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Confirmar Alta'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmar Alta'),
                          content: const Text(
                            'Você confirma que o paciente está apto para alta hospitalar '
                            'com as orientações acima?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Alta registrada com sucesso'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                // Aqui poderia salvar informações de alta
                                _observacoesController.clear();
                                setState(() => _pacienteSelecionado = null);
                              },
                              child: const Text('Confirmar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
