import 'package:flutter/material.dart';

class TelaCadastro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Usuário')),
            TextField(decoration: InputDecoration(labelText: 'Senha'), obscureText: true),
            ElevatedButton(onPressed: () {}, child: Text('Cadastrar')),
          ],
        ),
      ),
    );
  }
}