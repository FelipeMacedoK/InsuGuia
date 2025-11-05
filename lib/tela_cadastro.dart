import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/paciente.dart';
import 'services/firestore_service.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  String nome = '';
  String sexo = 'Masculino';
  int idade = 0;
  double peso = 0;
  double altura = 0;
  double creatinina = 0;
  String local = '';
  String diagnostico = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Paciente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (v) => nome = v,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Sexo'),
                initialValue: sexo,
                items: ['Masculino', 'Feminino']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => sexo = v!),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
                onChanged: (v) => idade = int.tryParse(v) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => peso = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Altura (cm)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => altura = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Creatinina (mg/dL)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => creatinina = double.tryParse(v) ?? 0,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Local de internação'),
                onChanged: (v) => local = v,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text('Salvar Cadastro'),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              final userId = FirebaseAuth.instance.currentUser?.uid;
                              if (userId == null) {
                                throw Exception('Usuário não autenticado');
                              }

                              final novoPaciente = Paciente(
                                id: '', // Será gerado pelo Firestore
                                nome: nome,
                                idade: idade,
                                peso: peso,
                                altura: altura,
                                diagnostico: 'Creatinina: $creatinina mg/dL\nLocal: $local\nSexo: $sexo',
                                dataCadastro: DateTime.now(),
                                userId: userId,
                              );

                              await _firestoreService.addPaciente(novoPaciente);
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Paciente cadastrado com sucesso!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              // Tratar erros do Firebase especificamente
                              String mensagem = 'Erro ao cadastrar paciente.';
                              if (e is FirebaseException) {
                                debugPrint('FirebaseException addPaciente: ${e.code} - ${e.message}');
                                if (e.code == 'permission-denied') {
                                  mensagem = 'Sem permissão para cadastrar. Verifique regras do Firestore.';
                                } else {
                                  // Não expor a mensagem do SDK (em inglês) ao usuário; logar para debugging
                                  mensagem = 'Erro no serviço ao cadastrar paciente.';
                                  debugPrint('FirebaseException addPaciente (detail): ${e.code} - ${e.message}');
                                }
                              } else {
                                debugPrint('Exception addPaciente: $e');
                                mensagem = 'Erro ao cadastrar paciente: $e';
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(mensagem),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
