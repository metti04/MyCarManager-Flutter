import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/blue_header_card.dart';
import '../../widgets/auto_card.dart';
import 'home_viewmodel.dart';
import '../auto/censimento_screen.dart';
import '../scheda_auto/scheda_auto_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel()..caricaTuttiIDati(widget.username),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.bianco,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => viewModel.caricaTuttiIDati(widget.username),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const BlueHeaderCard(
                          title: '', // Lasciamo vuoto il titolo nel widget base
                          height: 200,
                        ),
                        Positioned(
                          top: 40,
                          left: 0,
                          right: 0,
                          child: Text(
                            'Benvenuto ${widget.username}!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.bianco,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          left: 24,
                          right: 24,
                          child: _buildStatsCard(viewModel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50), // Spazio per la card che sporge
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      child: Text(
                        'I tuoi veicoli',
                        style: TextStyle(
                          color: AppColors.nero,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: viewModel.loading
                          ? const Center(child: CircularProgressIndicator())
                          : viewModel.autos.isEmpty
                              ? const Center(child: Text('Nessun veicolo censito.'))
                              : ListView.builder(
                                  padding: const EdgeInsets.only(top: 8),
                                  itemCount: viewModel.autos.length,
                                  itemBuilder: (context, index) {
                                    final auto = viewModel.autos[index];
                                    return AutoCard(
                                      auto: auto,
                                      scadenzaImminente: false,
                                      onTap: () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => SchedaAutoScreen(targa: auto.targa, username: widget.username),
                                          ),
                                        );
                                        viewModel.caricaTuttiIDati(widget.username);
                                      },
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CensimentoScreen()));
                viewModel.caricaTuttiIDati(widget.username);
              },
              backgroundColor: AppColors.blu,
              icon: const Icon(Icons.add, color: AppColors.bianco),
              label: const Text('Aggiungi Veicolo', style: TextStyle(color: AppColors.bianco)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(HomeViewModel viewModel) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: AppColors.bianco,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on_outlined, color: AppColors.blu, size: 32),
                  const Text('Spese del mese', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.nero)),
                  Text(
                    '${viewModel.speseDelMese.toStringAsFixed(2)}€',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blu),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 50, color: AppColors.grigino),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.alarm_on_outlined, color: AppColors.arancione, size: 32),
                  const Text('Scadenze Imminenti', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.nero)),
                  Text(
                    '${viewModel.scadenzeImminenti}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.arancione),
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
