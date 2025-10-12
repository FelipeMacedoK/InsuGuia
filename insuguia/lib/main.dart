import 'package:flutter/material.dart';
import 'tela_cadastro.dart';
import 'tela_registro_insulina.dart';
import 'tela_historico.dart';

void main() {
  runApp(InsuGuiaApp());
}

class InsuGuiaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsuGuia',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TelaPrincipal(),
    );
  }
}

class TelaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('InsuGuia')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TelaCadastro()));
              },
              child: Text('Cadastro de Usuário'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TelaRegistroInsulina()));
              },
              child: Text('Registrar Dose de Insulina'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TelaHistorico()));
              },
              child: Text('Histórico de Aplicações'),
            ),
          ],
        ),
      ),
    );
  }
}
