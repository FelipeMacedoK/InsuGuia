import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/prescricao.dart';
import 'models/paciente.dart';
import 'services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';

class TelaHistoricoPrescricoes extends StatefulWidget {
  const TelaHistoricoPrescricoes({super.key});

  @override
  State<TelaHistoricoPrescricoes> createState() =>
      _TelaHistoricoPrescricoesState();
}

class _TelaHistoricoPrescricoesState extends State<TelaHistoricoPrescricoes> {
  final _firestoreService = FirestoreService();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  String? _selectedPacienteId; // null = todas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Prescrições')),
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
                    child: Text('Todas as prescrições'),
                  ),
                );

                for (final p in pacientes) {
                  items.add(
                    DropdownMenuItem<String?>(
                      value: p.id,
                      child: Text(p.nome),
                    ),
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

          // Lista de prescrições
          Expanded(
            child: StreamBuilder<List<Prescricao>>(
              stream: _selectedPacienteId == null
                  ? _firestoreService.getPrescricoes()
                  : _firestoreService
                      .getPrescricoesPorPaciente(_selectedPacienteId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  final err = snapshot.error;
                  String mensagem = 'Erro ao carregar prescrições.';
                  if (err is FirebaseException) {
                    debugPrint(
                      'FirebaseException getPrescricoes: ${err.code} - ${err.message}',
                    );
                    if (err.code == 'permission-denied') {
                      mensagem = 'Sem permissão para acessar prescrições.';
                    }
                  }
                  return Center(child: Text(mensagem));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final prescricoes = snapshot.data ?? [];

                if (prescricoes.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma prescrição encontrada'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: prescricoes.length,
                  itemBuilder: (context, index) {
                    final prescricao = prescricoes[index];
                    final isVencida = prescricao.dataVencimento != null &&
                        prescricao.dataVencimento!.isBefore(DateTime.now());

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prescricao.pacienteNome,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _dateFormat
                                            .format(prescricao.dataPrescricao),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isVencida)
                                  const Chip(
                                    label: Text('Vencida'),
                                    backgroundColor: Colors.red,
                                    labelStyle:
                                        TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                            const Divider(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tipo de Insulina:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        prescricao.tipoInsulina,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dose:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${prescricao.dosePrescrita} UI',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Frequência:',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        prescricao.frequencia,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (prescricao.dataVencimento != null)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Vencimento:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd/MM/yyyy')
                                              .format(prescricao
                                                  .dataVencimento!),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: isVencida
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Indicações: ${prescricao.indicacoes}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'Confirmar exclusão'),
                                          content: const Text(
                                              'Tem certeza que deseja excluir esta prescrição?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                try {
                                                  await _firestoreService
                                                      .deletePrescricao(
                                                          prescricao.id);
                                                  if (!mounted) return;
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Prescrição excluída com sucesso!'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } catch (e) {
                                                  if (!mounted) return;
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Erro: $e'),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text('Excluir'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
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
