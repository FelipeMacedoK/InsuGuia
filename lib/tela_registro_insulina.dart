import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/paciente.dart';
import 'models/registro_insulina.dart';
import 'services/firestore_service.dart';

class TelaRegistroInsulina extends StatefulWidget {
  const TelaRegistroInsulina({super.key});

  @override
  State<TelaRegistroInsulina> createState() => _TelaRegistroInsulinaState();
}

class _TelaRegistroInsulinaState extends State<TelaRegistroInsulina> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  Paciente? _pacienteSelecionado;
  bool _isLoading = false;
  double glicemia = 0;
  double dose = 0;
  String tipoInsulina = 'Regular';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Insulina')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<List<Paciente>>(
                stream: _firestoreService.getPacientes(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // Mensagem amigável e log para debug
                    final err = snapshot.error;
                    String mensagem = 'Erro ao carregar pacientes.';
                    if (err is FirebaseException) {
                      debugPrint('FirebaseException getPacientes stream: ${err.code} - ${err.message}');
                      if (err.code == 'permission-denied') {
                        mensagem = 'Sem permissão para acessar pacientes. Verifique as regras do Firestore.';
                      } else {
                        mensagem = 'Erro no serviço: ${err.message}';
                      }
                    } else {
                      debugPrint('Stream error getPacientes: $err');
                    }
                    return Text(mensagem, style: const TextStyle(color: Colors.red));
                  }

                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final pacientes = snapshot.data!;
                  if (pacientes.isEmpty) {
                    return const Text(
                      'Nenhum paciente cadastrado. Cadastre um paciente primeiro.',
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
              const Text(
                'Informe a glicemia e a dose aplicada:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Glicemia (mg/dL)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a glicemia';
                  }
                  final numero = double.tryParse(value);
                  if (numero == null) {
                    return 'Digite um número válido';
                  }
                  return null;
                },
                onChanged: (v) => glicemia = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Dose aplicada (U)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a dose';
                  }
                  final numero = double.tryParse(value);
                  if (numero == null) {
                    return 'Digite um número válido';
                  }
                  return null;
                },
                onChanged: (v) => dose = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Insulina',
                  border: OutlineInputBorder(),
                ),
                initialValue: tipoInsulina,
                items: const [
                  DropdownMenuItem(value: 'Regular', child: Text('Regular')),
                  DropdownMenuItem(value: 'NPH', child: Text('NPH')),
                  DropdownMenuItem(value: 'Glargina', child: Text('Glargina')),
                  DropdownMenuItem(value: 'Detemir', child: Text('Detemir')),
                ],
                onChanged: (value) {
                  setState(() => tipoInsulina = value ?? 'Regular');
                },
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Registrar'),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate() &&
                              _pacienteSelecionado != null) {
                            setState(() => _isLoading = true);
                            try {
                              final userId =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (userId == null) {
                                throw Exception('Usuário não autenticado');
                              }

                              final registro = RegistroInsulina(
                                id: '',
                                pacienteId: _pacienteSelecionado!.id,
                                pacienteNome: _pacienteSelecionado!.nome,
                                glicemia: glicemia,
                                doseInsulina: dose,
                                tipoInsulina: tipoInsulina,
                                dataRegistro: DateTime.now(),
                                userId: userId,
                              );

                              await _firestoreService.addRegistroInsulina(registro);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Registro salvo com sucesso!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              String mensagem = 'Erro ao salvar registro.';
                              if (e is FirebaseException) {
                                debugPrint('FirebaseException addRegistroInsulina: ${e.code} - ${e.message}');
                                if (e.code == 'permission-denied') {
                                  mensagem = 'Sem permissão para salvar registro. Verifique regras do Firestore.';
                                } else {
                                  mensagem = 'Erro no serviço ao salvar registro.';
                                  debugPrint('FirebaseException addRegistroInsulina (detail): ${e.code} - ${e.message}');
                                }
                              } else {
                                debugPrint('Exception addRegistroInsulina: $e');
                                mensagem = 'Erro ao salvar registro: $e';
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(mensagem),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          }
                        },
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Sugestão de prescrição (simulada):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('• Dieta: Normal'),
                      Text('• Insulina basal: NPH 0,2U/kg/dia'),
                      Text('• Insulina rápida: Regular conforme glicemia capilar'),
                      Text('• Orientações: Avaliar hipoglicemia se glicemia < 70 mg/dL'),
                    ],
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
