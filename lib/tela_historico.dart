import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/registro_insulina.dart';
import 'services/firestore_service.dart';

class TelaHistorico extends StatelessWidget {
  TelaHistorico({super.key});

  final _firestoreService = FirestoreService();
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Aplicações')),
      body: StreamBuilder<List<RegistroInsulina>>(
        stream: _firestoreService.getRegistrosInsulina(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar registros: ${snapshot.error}'),
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
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Excluir'),
                            ),
                          ],
                        ),
                      );

                      if (confirma == true) {
                        await _firestoreService
                            .deleteRegistroInsulina(registro.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registro excluído com sucesso'),
                            ),
                          );
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
    );
  }
}
