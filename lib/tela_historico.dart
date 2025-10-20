import 'package:flutter/material.dart';

class TelaHistorico extends StatelessWidget {
  const TelaHistorico({super.key});

  @override
  Widget build(BuildContext context) {
    final registrosSimulados = [
      {'data': '18/10/2025', 'glicemia': '160', 'dose': '4U'},
      {'data': '19/10/2025', 'glicemia': '180', 'dose': '6U'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Aplicações')),
      body: ListView.builder(
        itemCount: registrosSimulados.length,
        itemBuilder: (context, index) {
          final reg = registrosSimulados[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('Data: ${reg['data']}'),
              subtitle: Text('Glicemia: ${reg['glicemia']} mg/dL\nDose: ${reg['dose']}'),
              leading: const Icon(Icons.monitor_heart),
            ),
          );
        },
      ),
    );
  }
}
