import 'package:flutter/material.dart';

class TelaRegistroInsulina extends StatelessWidget {
  const TelaRegistroInsulina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Insulina')),
      body: const Center(child: Text('Tela de Registro de Insulina')),
    );
  }
}