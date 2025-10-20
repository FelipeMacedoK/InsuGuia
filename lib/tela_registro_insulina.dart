import 'package:flutter/material.dart';

class TelaRegistroInsulina extends StatefulWidget {
  const TelaRegistroInsulina({super.key});

  @override
  State<TelaRegistroInsulina> createState() => _TelaRegistroInsulinaState();
}

class _TelaRegistroInsulinaState extends State<TelaRegistroInsulina> {
  final _formKey = GlobalKey<FormState>();
  double glicemia = 0;
  double dose = 0;

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
              const Text(
                'Informe a glicemia e a dose aplicada:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Glicemia (mg/dL)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => glicemia = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dose aplicada (U)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => dose = double.tryParse(v) ?? 0,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Registrar'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registro salvo com sucesso!')),
                  );
                },
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
