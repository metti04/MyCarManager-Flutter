import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/utente.dart';
import '../services/session_manager.dart';
import '../services/utente_service.dart';
import 'home_screen.dart';

class RegistrazioneScreen extends StatefulWidget {
  const RegistrazioneScreen({super.key});

  @override
  State<RegistrazioneScreen> createState() => _RegistrazioneScreenState();
}

class _RegistrazioneScreenState extends State<RegistrazioneScreen> {
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  DateTime? _dataNascita;

  final _utenteService = UtenteService();
  final _sessionManager = SessionManager();
  bool _loading = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dataNascita = picked);
  }

  Future<void> _register() async {
    final nome = _nomeController.text.trim();
    final cognome = _cognomeController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    final username = _usernameController.text.trim();

    if (nome.isEmpty || cognome.isEmpty || email.isEmpty || pass.isEmpty ||
        _dataNascita == null || username.isEmpty) {
      _showError('Tutti i campi sono obbligatori');
      return;
    }
    final emailValido = email.contains('@') && email.contains('.') && !email.contains(' ');
    if (!emailValido) {
      _showError('Email non valida');
      return;
    }
    if (pass.length < 6) {
      _showError('La password deve avere almeno 6 caratteri');
      return;
    }

    setState(() => _loading = true);
    try {
      final utenti = await _utenteService.getUtenti();
      if (utenti.any((u) => u.username == username)) {
        _showError('Username già esistente');
        return;
      }
      if (await _utenteService.getUtenteByEmail(email) != null) {
        _showError('Email già esistente');
        return;
      }

      final nuovoUtente = Utente(
        username: username,
        password: pass,
        email: email,
        nome: nome,
        cognome: cognome,
        dataDiNascita: _dataNascita!,
      );
      await _utenteService.inserisciUtente(nuovoUtente);
      await _sessionManager.saveSession(username);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen(username: username)),
        (route) => false,
      );
    } catch (e) {
      _showError('Errore durante la registrazione: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(title: const Text('Registrazione')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 12),
              TextField(controller: _cognomeController, decoration: const InputDecoration(labelText: 'Cognome')),
              const SizedBox(height: 12),
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data di nascita'),
                  child: Text(_dataNascita == null ? '' : df.format(_dataNascita!)),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Registrati'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
