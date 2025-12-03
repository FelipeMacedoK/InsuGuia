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
                      import 'package:flutter/material.dart';

                      // Tela de monitorização removida — placeholder simples.
                      // O usuário solicitou simplificação; esta tela não é mais usada no fluxo.

                      class TelaMonitorizacaoDiaria extends StatelessWidget {
                        const TelaMonitorizacaoDiaria({super.key});

                        @override
                        Widget build(BuildContext context) {
                          return Scaffold(
                            appBar: AppBar(title: const Text('Monitorização (removida)')),
                            body: const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text(
                                  'A tela de monitorização diária foi removida para simplificar o protótipo.\n\nUse as telas de Prescrição e Histórico.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        }
                      }
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
                          )
                        },
                      ),
                    ],
                  )
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
