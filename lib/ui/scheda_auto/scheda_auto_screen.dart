import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../models/enum.dart';
import '../../models/lavoro.dart';
import '../../models/obbligo.dart';
import '../../theme/app_colors.dart';
import 'scheda_auto_viewmodel.dart';
import 'dettagli_auto_fragment.dart';
import '../spese/spese_auto_fragment.dart';
import '../scadenze/scadenze_auto_fragment.dart';
import '../lavori/lavori_auto_fragment.dart';
import '../obblighi/obblighi_auto_fragment.dart';
import '../lavori/lavoro_screen.dart';
import '../obblighi/obbligo_screen.dart';

class SchedaAutoScreen extends StatelessWidget {
  final String targa;
  final String username;

  const SchedaAutoScreen({super.key, required this.targa, required this.username});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SchedaAutoViewModel()..caricaDati(targa),
      child: Consumer<SchedaAutoViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.loading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final auto = viewModel.auto;
          if (auto == null) {
            return const Scaffold(body: Center(child: Text('Veicolo non trovato')));
          }

          return Scaffold(
            backgroundColor: AppColors.bluChiaro2,
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // TOP HEADER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/ic_freccia_indietro.svg',
                                colorFilter: const ColorFilter.mode(AppColors.nero, BlendMode.srcIn),
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Text(
                                auto.nomeCompleto,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.nero,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/ic_elimina.svg',
                                colorFilter: const ColorFilter.mode(AppColors.rosso, BlendMode.srcIn),
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () => _confermaEliminaAuto(context, viewModel),
                            ),
                          ],
                        ),
                      ),

                      // CAR IMAGE CARD
                      Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          color: AppColors.bianco,
                          child: Container(
                            width: 60,
                            height: 60,
                            padding: const EdgeInsets.all(20),
                            child: SvgPicture.asset(
                              'assets/images/ic_auto.svg',
                              colorFilter: const ColorFilter.mode(AppColors.blu, BlendMode.srcIn),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      // ATTIVA SWITCH
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              auto.stato == StatoAuto.attivo ? 'Attiva' : 'Inattiva',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: auto.stato == StatoAuto.attivo ? AppColors.verde : AppColors.rosso,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: auto.stato == StatoAuto.attivo,
                              onChanged: (val) => viewModel.toggleStato(),
                              activeTrackColor: AppColors.bluPastello,
                              activeThumbColor: AppColors.blu,
                            ),
                          ],
                        ),
                      ),

                      // ICON BAR (Navigation)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.bianco.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _menuIcon(viewModel, 0, 'assets/images/ic_info.svg', 'Dettagli'),
                            _menuIcon(viewModel, 1, 'assets/images/ic_spese.svg', 'Spese'),
                            _menuIcon(viewModel, 2, 'assets/images/ic_scadenze.svg', 'Scadenze'),
                            _menuIcon(viewModel, 3, 'assets/images/ic_lavoro.svg', 'Lavori'),
                            _menuIcon(viewModel, 4, 'assets/images/ic_obbligo.svg', 'Obblighi'),
                          ],
                        ),
                      ),

                      // CONTENT FRAGMENT
                      Expanded(
                        child: _buildFragment(context, viewModel),
                      ),
                    ],
                  ),
                  
                  // FLOATING ACTION BUTTON
                  if (viewModel.currentTab == 3 || viewModel.currentTab == 4)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton(
                        onPressed: () => _aggiungiNuovo(context, viewModel),
                        backgroundColor: AppColors.blu,
                        child: const Icon(Icons.add, color: AppColors.bianco),
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

  void _confermaEliminaAuto(BuildContext context, SchedaAutoViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina veicolo'),
        content: const Text('Sei sicuro di voler eliminare definitivamente questo veicolo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () async {
              await viewModel.eliminaAuto();
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text('Elimina', style: TextStyle(color: AppColors.rosso)),
          ),
        ],
      ),
    );
  }

  void _aggiungiNuovo(BuildContext context, SchedaAutoViewModel viewModel) async {
    final bool? success = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => viewModel.currentTab == 3
            ? LavoroScreen(targa: targa)
            : ObbligoScreen(targa: targa),
      ),
    );
    if (success == true) {
      viewModel.caricaDati(targa);
    }
  }

  void _modificaLavoro(BuildContext context, SchedaAutoViewModel viewModel, Lavoro l) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LavoroScreen(lavoroDaModificare: l)),
    );
    if (result == true) {
      viewModel.caricaDati(l.targaAuto);
    }
  }

  void _modificaObbligo(BuildContext context, SchedaAutoViewModel viewModel, Obbligo o) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ObbligoScreen(obbligoDaModificare: o)),
    );
    if (result == true) {
      if (o.targaAuto != null) viewModel.caricaDati(o.targaAuto!);
    }
  }

  Widget _menuIcon(SchedaAutoViewModel viewModel, int index, String assetPath, String label) {
    final isSelected = viewModel.currentTab == index;
    final color = isSelected ? AppColors.blu : AppColors.nero;
    return InkWell(
      onTap: () => viewModel.setTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            assetPath,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            width: 28,
            height: 28,
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFragment(BuildContext context, SchedaAutoViewModel viewModel) {
    switch (viewModel.currentTab) {
      case 0: return DettagliAutoFragment(auto: viewModel.auto!, viewModel: viewModel);
      case 1: return SpeseAutoFragment(viewModel: viewModel);
      case 2: return ScadenzeAutoFragment(viewModel: viewModel);
      case 3: return LavoriAutoFragment(viewModel: viewModel, onEdit: (l) => _modificaLavoro(context, viewModel, l));
      case 4: return ObblighiAutoFragment(viewModel: viewModel, onEdit: (o) => _modificaObbligo(context, viewModel, o));
      default: return const SizedBox();
    }
  }
}
