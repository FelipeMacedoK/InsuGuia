import 'package:flutter/material.dart';
import 'tela_cadastro.dart';
import 'tela_registro_insulina.dart';
import 'tela_historico.dart';

void main() {
  runApp(const InsuGuiaApp());
}

class InsuGuiaApp extends StatelessWidget {
  const InsuGuiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsuGuia Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
      ),
      home: const TelaPrincipal(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TelaPrincipal extends StatelessWidget {
  const TelaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InsuGuia Mobile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aplicativo acadêmico para apoio à prescrição de insulina '
              'em pacientes hospitalares (cenário não crítico).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Cadastro de Paciente'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TelaCadastro()));
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.medication),
              label: const Text('Registrar Dose de Insulina'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TelaRegistroInsulina()));
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Histórico de Aplicações'),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TelaHistorico()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
