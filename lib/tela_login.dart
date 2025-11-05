import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela_signup.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _senhaController.text,
        );
        // StreamBuilder em main.dart detecta a mudança de estado e redireciona
      } on FirebaseAuthException catch (e) {
        // Mapear códigos conhecidos para mensagens amigáveis em português
        String mensagem;
        switch (e.code) {
          case 'user-not-found':
            mensagem = 'Usuário não encontrado. Verifique o email.';
            break;
          case 'wrong-password':
            mensagem = 'Senha incorreta. Tente novamente.';
            break;
          case 'invalid-email':
            mensagem = 'Formato de email inválido.';
            break;
          case 'user-disabled':
            mensagem = 'Conta desativada. Contate o administrador.';
            break;
          case 'too-many-requests':
            mensagem = 'Muitas tentativas. Aguarde alguns instantes.';
            break;
          case 'operation-not-allowed':
            mensagem = 'Método de autenticação não permitido.';
            break;
          case 'invalid-credential':
            mensagem = 'Credencial inválida. Verifique e tente novamente.';
            break;
          default:
            // Não expor mensagem do SDK (normalmente em inglês) ao usuário;
            // mostrar mensagem genérica e logar o detalhe para depuração.
            mensagem = 'Erro ao fazer login. Verifique suas credenciais e tente novamente.';
            debugPrint('FirebaseAuthException (unmapped) during signIn: ${e.code} - ${e.message}');
        }
        debugPrint('FirebaseAuthException during signIn: ${e.code} - ${e.message}');
        setState(() => _errorMessage = mensagem);
      } on FirebaseException catch (e) {
        // Erros mais genéricos do SDK
        debugPrint('FirebaseException during signIn: ${e.code} - ${e.message}');
        setState(() => _errorMessage = 'Erro ao conectar com o serviço de autenticação.');
      } catch (e, st) {
        debugPrint('Unexpected error during signIn: $e\n$st');
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
        title: const Text('Login - InsuGuia'),
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
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaSignup()),
                  );
                },
                child: const Text('Não tem uma conta? Cadastre-se'),
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
    super.dispose();
  }
}