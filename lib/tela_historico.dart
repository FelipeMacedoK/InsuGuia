import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/registro_insulina.dart';
import 'models/paciente.dart';
import 'services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  final _firestoreService = FirestoreService();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  String? _selectedPacienteId; // null = todos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Aplicações')),
      body: Column(
        children: [
          // Dropdown de pacientes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<List<Paciente>>(
              stream: _firestoreService.getPacientes(),
              builder: (context, snapPacientes) {
                if (snapPacientes.hasError) {
                  final err = snapPacientes.error;
                  String mensagem = 'Erro ao carregar pacientes.';
                  if (err is FirebaseException) {
                    debugPrint(
                      'FirebaseException getPacientes: ${err.code} - ${err.message}',
                    );
                    if (err.code == 'permission-denied') {
                      mensagem = 'Sem permissão para acessar pacientes.';
                    }
                  }
                  return Text(mensagem);
                }

                if (snapPacientes.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                final pacientes = snapPacientes.data ?? [];

                final items = <DropdownMenuItem<String?>>[];
                items.add(
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos os pacientes'),
                  ),
                );

                for (final p in pacientes) {
                  items.add(
                    DropdownMenuItem<String?>(value: p.id, child: Text(p.nome)),
                  );
                }

                return Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.filter_list),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        initialValue: _selectedPacienteId,
                        items: items,
                        onChanged: (value) {
                          setState(() {
                            _selectedPacienteId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por paciente',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              },
            ),
          ),

          // Lista de registros
          Expanded(
            child: StreamBuilder<List<RegistroInsulina>>(
              stream: _selectedPacienteId == null
                  ? _firestoreService.getRegistrosInsulina()
                  : _firestoreService.getRegistrosPorPaciente(
                      _selectedPacienteId!,
                    ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  final err = snapshot.error;
                  String mensagem = 'Erro ao carregar registros.';
                  if (err is FirebaseException) {
                    debugPrint(
                      'FirebaseException getRegistrosInsulina: ${err.code} - ${err.message}',
                    );
                    if (err.code == 'permission-denied') {
                      mensagem =
                          'Sem permissão para acessar registros. Verifique regras do Firestore.';
                    } else if (err.code == 'failed-precondition' ||
                        (err.message ?? '').toString().toLowerCase().contains(
                          'index',
                        )) {
                      final detalhe = err.message ?? '';
                      mensagem =
                          'Consulta requer índice no Firestore. Crie o índice no Console do Firebase.\nDetalhe: $detalhe';
                      debugPrint('Firestore index required: $detalhe');
                    } else {
                      mensagem = 'Erro no serviço ao carregar registros.';
                      debugPrint(
                        'FirebaseException getRegistrosInsulina (detail): ${err.code} - ${err.message}',
                      );
                    }
                  } else {
                    debugPrint('Stream error getRegistrosInsulina: $err');
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(mensagem, textAlign: TextAlign.center),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final registros = snapshot.data ?? [];

                if (registros.isEmpty) {
                  return const Center(
                    child: Text('Nenhum registro encontrado'),
                  );
                }

                return ListView.builder(
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final registro = registros[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(
                          'Paciente: ${registro.pacienteNome}\n'
                          'Data: ${_dateFormat.format(registro.dataRegistro)}',
                        ),
                        subtitle: Text(
                          'Glicemia: ${registro.glicemia} mg/dL\n'
                          'Dose: ${registro.doseInsulina}U (${registro.tipoInsulina})',
                        ),
                        leading: const Icon(Icons.monitor_heart),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirma = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar exclusão'),
                                content: const Text(
                                  'Deseja realmente excluir este registro?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );

                            if (confirma == true) {
                              try {
                                await _firestoreService.deleteRegistroInsulina(
                                  registro.id,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Registro excluído com sucesso',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                String mensagem = 'Erro ao excluir registro.';
                                if (e is FirebaseException) {
                                  debugPrint(
                                    'FirebaseException deleteRegistroInsulina: ${e.code} - ${e.message}',
                                  );
                                  if (e.code == 'permission-denied') {
                                    mensagem =
                                        'Sem permissão para excluir registro. Verifique regras do Firestore.';
                                  } else {
                                    mensagem = 'Erro no serviço: ${e.message}';
                                  }
                                } else {
                                  debugPrint(
                                    'Exception deleteRegistroInsulina: $e',
                                  );
                                  mensagem = 'Erro ao excluir registro: $e';
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(mensagem),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
