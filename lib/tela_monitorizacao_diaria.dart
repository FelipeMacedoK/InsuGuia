import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/paciente.dart';
import 'models/registro_insulina.dart';
import 'services/firestore_service.dart';
import 'services/insulina_calculo_service.dart';

class TelaMonitorizacaoDiaria extends StatefulWidget {
  const TelaMonitorizacaoDiaria({super.key});

  @override
  State<TelaMonitorizacaoDiaria> createState() =>
      _TelaMonitorizacaoDiariaState();
}

class _TelaMonitorizacaoDiariaState extends State<TelaMonitorizacaoDiaria> {
  final _firestoreService = FirestoreService();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final _dateFormatDate = DateFormat('dd/MM/yyyy');

  Paciente? _pacienteSelecionado;
  DateTime _dataSelecionada = DateTime.now();
  late TextEditingController _glicemiaController;
  late TextEditingController _doseController;
  SensibilidadeInsulina? _sensibilidadeDoTratamento;

  @override
  void initState() {
    super.initState();
    _glicemiaController = TextEditingController();
    _doseController = TextEditingController();
  }

  @override
  void dispose() {
    _glicemiaController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _adicionarRegistro() {
    final glicemia = double.tryParse(_glicemiaController.text);
    final dose = double.tryParse(_doseController.text);

    if (glicemia == null || dose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha glicemia e dose corretamente')),
      );
      return;
    }

    if (_pacienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um paciente')),
      );
      return;
    }

    // Criar registro
    final registro = RegistroInsulina(
      id: '',
      pacienteId: _pacienteSelecionado!.id,
      pacienteNome: _pacienteSelecionado!.nome,
      glicemia: glicemia,
      doseInsulina: dose,
      tipoInsulina: 'Regular', // Ou conforme prescrição
      dataRegistro: _dataSelecionada,
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    );

    _firestoreService.addRegistroInsulina(registro).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro adicionado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
      _glicemiaController.clear();
      _doseController.clear();
      setState(() {});
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    });
  }

  String _obterSugestaoDose(double glicemia) {
    if (_sensibilidadeDoTratamento == null) {
      return 'Configure sensibilidade na prescrição';
    }

    final tabela = InsulinaCalculoService.obterTabelaCorrecao(
      _sensibilidadeDoTratamento!,
    );

    if (glicemia < 70) {
      return '🔴 HIPOGLICEMIA - Ofereça glicose 50% imediatamente';
    } else if (glicemia < 100) {
      return '⚠️ BAIXA - Ofereça lanche';
    } else if (glicemia <= 180) {
      return '✅ ADEQUADA - Sem correção necessária (0 UI sugerido)';
    } else if (glicemia <= 250) {
      final dose = tabela['181_250'] ?? 0;
      return '⚠️ ELEVADA - Sugerir ${dose.toStringAsFixed(0)} UI de Regular';
    } else if (glicemia <= 350) {
      final dose = tabela['251_350'] ?? 0;
      return '🔴 MUITO ELEVADA - Sugerir ${dose.toStringAsFixed(0)} UI de Regular';
    } else {
      final dose = tabela['maior_351'] ?? 0;
      return '🚨 CRÍTICA - Sugerir ${dose.toStringAsFixed(0)} UI de Regular + avaliar';
    }
  }

  Color _obterCorSugestao(double glicemia) {
    if (glicemia < 70) return Colors.red;
    if (glicemia < 100) return Colors.orange;
    if (glicemia <= 180) return Colors.green;
    if (glicemia <= 250) return Colors.orange;
    if (glicemia <= 350) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitorização Diária')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aviso
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Registre as glicemias e doses conforme protocolo. '
                      'O app sugerirá ajustes.',
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
                      });
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // Seleção de data
            const Text(
              'Data e Hora',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_dateFormat.format(_dataSelecionada)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final dataSelecionada = await showDatePicker(
                  context: context,
                  initialDate: _dataSelecionada,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );

                if (dataSelecionada != null) {
                  final horaSelecionada = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dataSelecionada),
                  );

                  if (horaSelecionada != null) {
                    setState(() {
                      _dataSelecionada = DateTime(
                        dataSelecionada.year,
                        dataSelecionada.month,
                        dataSelecionada.day,
                        horaSelecionada.hour,
                        horaSelecionada.minute,
                      );
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 20),

            // Entrada de glicemia
            const Text(
              'Glicemia Capilar (mg/dL)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _glicemiaController,
              decoration: const InputDecoration(
                labelText: 'Glicemia',
                border: OutlineInputBorder(),
                suffixText: 'mg/dL',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Sugestão dinâmica
            if (_glicemiaController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _obterCorSugestao(
                    double.tryParse(_glicemiaController.text) ?? 0,
                  ).withOpacity(0.1),
                  border: Border.all(
                    color: _obterCorSugestao(
                      double.tryParse(_glicemiaController.text) ?? 0,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _obterSugestaoDose(
                    double.tryParse(_glicemiaController.text) ?? 0,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _obterCorSugestao(
                      double.tryParse(_glicemiaController.text) ?? 0,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Entrada de dose
            const Text(
              'Dose Aplicada (UI)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: 'Dose',
                border: OutlineInputBorder(),
                suffixText: 'UI',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Botão adicionar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Adicionar Registro'),
                onPressed: _adicionarRegistro,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Histórico do dia
            const Text(
              'Registros do Dia',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (_pacienteSelecionado != null)
              StreamBuilder<List<RegistroInsulina>>(
                stream: _firestoreService
                    .getRegistrosPorPaciente(_pacienteSelecionado!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filtrar registros do dia selecionado
                  final registrosDia = snapshot.data!
                      .where((r) =>
                          _dateFormatDate.format(r.dataRegistro) ==
                          _dateFormatDate.format(_dataSelecionada))
                      .toList();

                  if (registrosDia.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Nenhum registro para ${_dateFormatDate.format(_dataSelecionada)}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  // Calcular estatísticas
                  final glicemias = registrosDia.map((r) => r.glicemia).toList();
                  final media = glicemias.isEmpty
                      ? 0.0
                      : glicemias.reduce((a, b) => a + b) / glicemias.length;
                  final maxima = glicemias.isEmpty
                      ? 0.0
                      : glicemias.reduce((a, b) => a > b ? a : b);
                  final minima = glicemias.isEmpty
                      ? 0.0
                      : glicemias.reduce((a, b) => a < b ? a : b);

                  return Column(
                    children: [
                      // Card de estatísticas
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatCard(
                                'Mínima',
                                '${minima.toStringAsFixed(0)} mg/dL',
                                Colors.blue,
                              ),
                              _buildStatCard(
                                'Média',
                                '${media.toStringAsFixed(0)} mg/dL',
                                Colors.green,
                              ),
                              _buildStatCard(
                                'Máxima',
                                '${maxima.toStringAsFixed(0)} mg/dL',
                                Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista de registros
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: registrosDia.length,
                        itemBuilder: (context, index) {
                          final registro = registrosDia[index];
                          final cor = _obterCorSugestao(registro.glicemia);

                          return Card(
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: cor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: cor),
                                ),
                                child: Center(
                                  child: Text(
                                    '${registro.glicemia.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: cor,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                DateFormat('HH:mm').format(registro.dataRegistro),
                              ),
                              subtitle: Text(
                                'Dose: ${registro.doseInsulina.toStringAsFixed(0)} UI',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _firestoreService
                                      .deleteRegistroInsulina(registro.id)
                                      .then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Registro removido com sucesso'),
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}
