import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/paciente.dart';
import 'models/prescricao.dart';
import 'services/firestore_service.dart';

class TelaPrescricao extends StatefulWidget {
  const TelaPrescricao({super.key});

  @override
  State<TelaPrescricao> createState() => _TelaPrescricaoState();
}

class _TelaPrescricaoState extends State<TelaPrescricao> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  Paciente? _pacienteSelecionado;
  bool _isLoading = false;
  double dosePrescrita = 0;
  String tipoInsulina = 'Regular';
  String frequencia = 'Uma vez ao dia';
  final TextEditingController _indicacoesController = TextEditingController();
  DateTime? _dataVencimento;

  final List<String> _tiposInsulina = [
    'Regular',
    'NPH',
    'Lenta',
    'Ultra-rápida',
    'Análogo lento',
  ];

  final List<String> _frequencias = [
    'Uma vez ao dia',
    'Duas vezes ao dia',
    'Três vezes ao dia',
    'Conforme necessário',
  ];

  @override
  void dispose() {
    _indicacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataVencimento(BuildContext context) async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataVencimento = dataSelecionada;
      });
    }
  }

  Future<void> _salvarPrescricao() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pacienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um paciente')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prescricao = Prescricao(
        id: '',
        pacienteId: _pacienteSelecionado!.id,
        pacienteNome: _pacienteSelecionado!.nome,
        dosePrescrita: dosePrescrita,
        tipoInsulina: tipoInsulina,
        frequencia: frequencia,
        indicacoes: _indicacoesController.text,
        dataPrescricao: DateTime.now(),
        dataVencimento: _dataVencimento,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      await _firestoreService.addPrescricao(prescricao);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescrição adicionada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Limpar formulário
      _formKey.currentState!.reset();
      setState(() {
        _pacienteSelecionado = null;
        dosePrescrita = 0;
        tipoInsulina = 'Regular';
        frequencia = 'Uma vez ao dia';
        _indicacoesController.clear();
        _dataVencimento = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar prescrição: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescrição de Insulina')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seleção de paciente
              StreamBuilder<List<Paciente>>(
                stream: _firestoreService.getPacientes(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    final err = snapshot.error;
                    String mensagem = 'Erro ao carregar pacientes.';
                    if (err is FirebaseException) {
                      debugPrint(
                        'FirebaseException getPacientes: ${err.code} - ${err.message}',
                      );
                      if (err.code == 'permission-denied') {
                        mensagem = 'Sem permissão para acessar pacientes.';
                      }
                    }
                    return Text(
                      mensagem,
                      style: const TextStyle(color: Colors.red),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final pacientes = snapshot.data!;
                  if (pacientes.isEmpty) {
                    return const Text(
                      'Nenhum paciente cadastrado.',
                      style: TextStyle(color: Colors.red),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecione o Paciente',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _pacienteSelecionado?.id,
                    items: pacientes.map((paciente) {
                      return DropdownMenuItem(
                        value: paciente.id,
                        child: Text(paciente.nome),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _pacienteSelecionado = pacientes.firstWhere(
                            (p) => p.id == value,
                          );
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione um paciente';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Tipo de Insulina
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Insulina',
                  border: OutlineInputBorder(),
                ),
                initialValue: tipoInsulina,
                items: _tiposInsulina.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      tipoInsulina = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione um tipo de insulina';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dose Prescrita
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Dose Prescrita (UI)',
                  border: OutlineInputBorder(),
                  suffixText: 'UI',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a dose';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Dose deve ser um número maior que 0';
                  }
                  return null;
                },
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    setState(() {
                      dosePrescrita = parsed;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Frequência
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Frequência',
                  border: OutlineInputBorder(),
                ),
                initialValue: frequencia,
                items: _frequencias.map((freq) {
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(freq),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      frequencia = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione uma frequência';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Indicações
              TextFormField(
                controller: _indicacoesController,
                decoration: const InputDecoration(
                  labelText: 'Indicações / Observações',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: Aplicar antes das refeições',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe as indicações';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Data de Vencimento
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _dataVencimento != null
                      ? 'Vencimento: ${DateFormat('dd/MM/yyyy').format(_dataVencimento!)}'
                      : 'Selecionar Data de Vencimento',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selecionarDataVencimento(context),
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isLoading ? 'Salvando...' : 'Salvar Prescrição',
                  ),
                  onPressed: _isLoading ? null : _salvarPrescricao,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
