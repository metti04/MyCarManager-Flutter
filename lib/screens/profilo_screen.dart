import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/utente.dart';
import '../services/session_manager.dart';
import '../services/utente_service.dart';
import '../services/supabase_service.dart';
import '../widgets/blue_header_card.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'modifica_dati_screen.dart';

class ProfiloScreen extends StatefulWidget {
  final String username;

  const ProfiloScreen({super.key, required this.username});

  @override
  State<ProfiloScreen> createState() => _ProfiloScreenState();
}

class _ProfiloScreenState extends State<ProfiloScreen> {
  final _utenteService = UtenteService();
  final _sessionManager = SessionManager();
  Utente? _utente;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    setState(() => _loading = true);
    final utente = await _utenteService.getUtente(widget.username);
    setState(() {
      _utente = utente;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {}
    await _sessionManager.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final u = _utente;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BlueHeaderCard(title: u != null ? '${u.nome} ${u.cognome}' : widget.username),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : u == null
                      ? const Center(child: Text('Utente non trovato'))
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _ProfiloRow(label: 'Username', value: u.username),
                            _ProfiloRow(label: 'Nome', value: u.nome),
                            _ProfiloRow(label: 'Cognome', value: u.cognome),
                            _ProfiloRow(label: 'Email', value: u.email),
                            _ProfiloRow(label: 'Data di nascita', value: df.format(u.dataDiNascita)),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () async {
                                await Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (_) => ModificaDatiScreen(username: widget.username)));
                                _carica();
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Modifica dati'),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _logout,
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.rosso),
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfiloRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfiloRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
