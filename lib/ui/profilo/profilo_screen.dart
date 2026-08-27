import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      create: (_) => ProfiloViewModel()..caricaDati(),
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
                    title: u?.username ?? username,
                    height: 180,
                  ),
                  Expanded(
                    child: (viewModel.loading && u == null)
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                const SizedBox(height: 15),
                                // BOTTONE LOGOUT
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await viewModel.logout();
                                      if (context.mounted) {
                                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                                          (route) => false,
                                        );
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.rosso,
                                      backgroundColor: AppColors.bianco,
                                      side: const BorderSide(color: AppColors.rosso, width: 2),
                                      minimumSize: const Size(150, 55),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    ),
                                    label: SvgPicture.asset(
                                      'assets/images/ic_logout.svg',
                                      colorFilter: const ColorFilter.mode(AppColors.rosso, BlendMode.srcIn),
                                      width: 24,
                                      height: 24,
                                    ),
                                    icon: const Text('Esci', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                // CARD DATI UTENTE
                                Card(
                                  elevation: 0,
                                  color: AppColors.bluChiaro,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                  margin: const EdgeInsets.only(top: 15),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Dati',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.nero,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _ProfiloItem(label: 'Username', value: u?.username ?? '-'),
                                        _ProfiloItem(label: 'Nome', value: u?.nome ?? '-'),
                                        _ProfiloItem(label: 'Cognome', value: u?.cognome ?? '-'),
                                        _ProfiloItem(label: 'Email', value: u?.email ?? '-'),
                                        _ProfiloItem(label: 'Data di nascita', value: u != null ? df.format(u.dataDiNascita) : '-'),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: FilledButton(
                                                onPressed: () async {
                                                  await Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => ModificaDatiScreen(username: u?.username ?? username),
                                                    ),
                                                  );
                                                  viewModel.caricaDati();
                                                },
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: AppColors.blu,
                                                  minimumSize: const Size(0, 60),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                                ),
                                                child: const Text('Modifica', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            IconButton(
                                              icon: SvgPicture.asset(
                                                'assets/images/ic_elimina.svg',
                                                colorFilter: const ColorFilter.mode(AppColors.rosso, BlendMode.srcIn),
                                                width: 35,
                                                height: 35,
                                              ),
                                              onPressed: () => _mostraConfermaEliminazione(context, viewModel),
                                              style: IconButton.styleFrom(
                                                backgroundColor: AppColors.bianco,
                                                padding: const EdgeInsets.all(12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
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

  void _mostraConfermaEliminazione(BuildContext context, ProfiloViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Account'),
        content: const Text('Sei sicuro di voler eliminare definitivamente il tuo account? Questa operazione non è reversibile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.eliminaAccount();
              if (success && context.mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Elimina', style: TextStyle(color: AppColors.rosso)),
          ),
        ],
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
          fontSize: 20,
          color: AppColors.blu,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}