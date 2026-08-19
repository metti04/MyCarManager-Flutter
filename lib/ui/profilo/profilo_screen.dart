import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/blue_header_card.dart';
import 'profilo_viewmodel.dart';
import '../auth/login_screen.dart';
import 'modifica_dati_screen.dart';

class ProfiloScreen extends StatelessWidget {
  final String username;

  const ProfiloScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfiloViewModel()..caricaDati(username),
      child: Consumer<ProfiloViewModel>(
        builder: (context, viewModel, _) {
          final df = DateFormat('dd/MM/yyyy');
          final u = viewModel.utente;

          return Scaffold(
            backgroundColor: AppColors.bianco,
            body: SafeArea(
              child: Column(
                children: [
                  BlueHeaderCard(
                    title: u != null ? u.username : username,
                    height: 180,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await viewModel.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.rosso,
                          side: const BorderSide(color: AppColors.rosso, width: 2),
                          minimumSize: const Size(100, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        icon: const Text('Esci', style: TextStyle(fontWeight: FontWeight.bold)),
                        label: const Icon(Icons.logout, size: 20),
                      ),
                    ),
                  ),
                  Expanded(
                    child: viewModel.loading
                        ? const Center(child: CircularProgressIndicator())
                        : u == null
                            ? const Center(child: Text('Utente non trovato'))
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.bluChiaro2,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding: const EdgeInsets.all(30),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dati',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.nero,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      _ProfiloItem(label: 'Username', value: u.username),
                                      _ProfiloItem(label: 'Nome', value: u.nome),
                                      _ProfiloItem(label: 'Cognome', value: u.cognome),
                                      _ProfiloItem(label: 'Email', value: u.email),
                                      _ProfiloItem(label: 'Data di nascita', value: df.format(u.dataDiNascita)),
                                      const SizedBox(height: 30),
                                      Center(
                                        child: FilledButton(
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => ModificaDatiScreen(username: username),
                                              ),
                                            );
                                            viewModel.caricaDati(username);
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.bluPastello,
                                            minimumSize: const Size(180, 50),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                          ),
                                          child: const Text('Modifica'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfiloItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfiloItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 18,
          color: AppColors.bluScuro,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
