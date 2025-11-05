import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaSignup extends StatefulWidget {
  const TelaSignup({super.key});

  @override
  State<TelaSignup> createState() => _TelaSignupState();
}

class _TelaSignupState extends State<TelaSignup> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_senhaController.text != _confirmaSenhaController.text) {
        setState(() {
          _errorMessage = 'As senhas não coincidem';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text,
        );
        // O StreamBuilder em main.dart vai detectar a mudança e redirecionar
      } on FirebaseAuthException catch (e) {
        String mensagem;
        switch (e.code) {
          case 'weak-password':
            mensagem = 'A senha é muito fraca. Use ao menos 6 caracteres.';
            break;
          case 'email-already-in-use':
            mensagem = 'Este email já está em uso. Tente outro.';
            break;
          case 'invalid-email':
            mensagem = 'Formato de email inválido.';
            break;
          case 'operation-not-allowed':
            mensagem = 'Registro por email/senha não está habilitado.';
            break;
          case 'invalid-credential':
            mensagem = 'Credencial inválida. Verifique e tente novamente.';
            break;
          case 'too-many-requests':
            mensagem = 'Muitas tentativas. Aguarde e tente novamente.';
            break;
          default:
            mensagem = 'Erro ao criar conta. Verifique seus dados e tente novamente.';
            debugPrint('FirebaseAuthException (unmapped) during signup: ${e.code} - ${e.message}');
        }
        debugPrint('FirebaseAuthException during signup: ${e.code} - ${e.message}');
        setState(() => _errorMessage = mensagem);
      } on FirebaseException catch (e) {
        debugPrint('FirebaseException during signup: ${e.code} - ${e.message}');
        setState(() => _errorMessage = 'Erro ao conectar com o serviço de autenticação.');
      } catch (e, st) {
        debugPrint('Unexpected error during signup: $e\n$st');
        setState(() => _errorMessage = 'Ocorreu um erro inesperado.');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta - InsuGuia'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite seu email';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, digite um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite sua senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmaSenhaController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme sua senha';
                  }
                  if (value != _senhaController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Criar Conta'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Já tem uma conta? Faça login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }
}