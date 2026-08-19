import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/utente.dart';
import '../services/utente_service.dart';
import '../widgets/blue_header_card.dart';

class ModificaDatiScreen extends StatefulWidget {
  final String username;

  const ModificaDatiScreen({super.key, required this.username});

  @override
  State<ModificaDatiScreen> createState() => _ModificaDatiScreenState();
}

class _ModificaDatiScreenState extends State<ModificaDatiScreen> {
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  DateTime? _dataNascita;

  final _utenteService = UtenteService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    final u = await _utenteService.getUtente(widget.username);
    if (u != null) {
      _nomeController.text = u.nome;
      _cognomeController.text = u.cognome;
      _emailController.text = u.email;
      _passwordController.text = u.password;
      _usernameController.text = u.username;
      _dataNascita = u.dataDiNascita;
    }
    setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascita ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dataNascita = picked);
  }

  Future<void> _salva() async {
    final nome = _nomeController.text.trim();
    final cognome = _cognomeController.text.trim();
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();

    if (nome.isEmpty || cognome.isEmpty || email.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nome, cognome, email e username sono obbligatori')));
      return;
    }

    setState(() => _loading = true);
    try {
      final utenteAggiornato = Utente(
        username: username,
        password: _passwordController.text,
        email: email,
        nome: nome,
        cognome: cognome,
        dataDiNascita: _dataNascita ?? DateTime.now(),
      );
      await _utenteService.aggiornaUtente(utenteAggiornato);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dati aggiornati con successo!')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore durante il salvataggio: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BlueHeaderCard(title: 'Modifica dati'),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome')),
                          const SizedBox(height: 12),
                          TextField(controller: _cognomeController, decoration: const InputDecoration(labelText: 'Cognome')),
                          const SizedBox(height: 12),
                          TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
                          const SizedBox(height: 12),
                          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
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
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: FilledButton(onPressed: _salva, child: const Text('Salva'))),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
