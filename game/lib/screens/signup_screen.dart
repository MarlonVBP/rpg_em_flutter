import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teste/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  void _signup() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final bool success = await authProvider.signup(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada com sucesso! Por favor, faça o login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível criar a conta.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'images/background_login_signup.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildSquishyTextFormField(
                      controller: _emailController,
                      hintText: 'Email do aventureiro',
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira seu email.';
                        }
                        if (!_isValidEmail(value.trim())) {
                          return 'Por favor, insira um email válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSquishyTextFormField(
                      controller: _passwordController,
                      hintText: 'Senha secreta (mín. 6)',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, crie uma senha.';
                        }
                        if (value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSquishyTextFormField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirme a senha',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, confirme sua senha.';
                        }
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    _buildSquishyButton(
                      onPressed: _isLoading ? () {} : _signup,
                      label: _isLoading ? 'Criando...' : 'Cadastrar',
                      color: Colors.yellow.shade700,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Já tem uma conta?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Entre aqui!',
                            style: TextStyle(
                              color: Colors.yellow.shade700,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquishyTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: Colors.deepPurple.shade600),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          border: InputBorder.none,
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.deepPurple.shade800,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquishyButton({
    required VoidCallback onPressed,
    required String label,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.yellow.shade800, width: 2),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      child: Text(label),
    );
  }
}
