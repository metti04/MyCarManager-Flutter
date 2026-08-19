import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import '../services/utente_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'registrazione_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _utenteService = UtenteService();
  final _sessionManager = SessionManager();
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      _showError('Tutti i campi sono obbligatori');
      return;
    }

    setState(() => _loading = true);
    try {
      final utente = await _utenteService.getUtenteByEmail(email);
      if (utente != null && utente.password == pass) {
        await _sessionManager.saveSession(utente.username);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen(username: utente.username)),
          (route) => false,
        );
      } else {
        _showError('Email o Password errati');
      }
    } catch (e) {
      _showError('Accesso fallito: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('MyCarManager',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.blu)),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Accedi'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const RegistrazioneScreen())),
                  child: const Text('Non hai un account? Registrati'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
