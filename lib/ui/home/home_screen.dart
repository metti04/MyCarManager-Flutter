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
                          title: '',
                          height: 220,
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
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30, // Posizionato per sovrapporsi
                          left: 24,
                          right: 24,
                          child: _buildStatsCard(viewModel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 45), // Spazio per la card che sporge
                    const Padding(
                      padding: EdgeInsets.only(left: 24, top: 10, bottom: 5),
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
                                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                                  itemCount: viewModel.autos.length,
                                  itemBuilder: (context, index) {
                                    final auto = viewModel.autos[index];
                                    return AutoCard(
                                      auto: auto,
                                      scadenzaImminente: false, // Potrebbe essere calcolato
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
              label: const Text('Aggiungi Veicolo', style: TextStyle(color: AppColors.bianco, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(HomeViewModel viewModel) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      color: AppColors.bianco,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Sezione Spese
            Expanded(
              child: InkWell(
                onTap: () {
                   // Naviga a spese se necessario
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.euro, color: AppColors.blu, size: 28),
                    const Text('Spese', style: TextStyle(fontSize: 14, color: AppColors.nero)),
                    Text(
                      '${viewModel.speseDelMese.toStringAsFixed(2)}€',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blu),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.grigino),
            // Sezione Scadenze
            Expanded(
              child: InkWell(
                onTap: () {
                   // Naviga a scadenze se necessario
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alarm, color: AppColors.verde, size: 28),
                    const Text('Scadenze', style: TextStyle(fontSize: 14, color: AppColors.nero)),
                    Text(
                      '${viewModel.scadenzeImminenti}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.verde),
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
