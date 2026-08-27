import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../models/lavoro.dart';
import '../../models/obbligo.dart';
import '../../theme/app_colors.dart';
import '../scheda_auto/scheda_auto_viewmodel.dart';

class ScadenzeAutoFragment extends StatelessWidget {
  final SchedaAutoViewModel viewModel;
  final Function(Lavoro)? onLavoroClick;
  final Function(Obbligo)? onObbligoClick;

  const ScadenzeAutoFragment({
    super.key, 
    required this.viewModel,
    this.onLavoroClick,
    this.onObbligoClick,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final items = viewModel.itemsScadenze;
    final df = DateFormat('dd/MM/yyyy');
    final currentKm = viewModel.auto?.chilometraggio ?? 0;

    return Column(
      children: [
        // Card Riassunto Scadenze
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          color: AppColors.bianco,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _statCol('In regola', '${viewModel.countRegolari}', AppColors.grigioMedio, AppColors.verde),
                ),
                Container(width: 2, height: 50, color: AppColors.grigino),
                Expanded(
                  child: _statCol('Imminenti', '${viewModel.countImminenti}', AppColors.grigioMedio, AppColors.arancione),
                ),
                Container(width: 2, height: 50, color: AppColors.grigino),
                Expanded(
                  child: _statCol('Scadute', '${viewModel.countScadute}', AppColors.grigioMedio, AppColors.rosso),
                ),
              ],
            ),
          ),
        ),
        
        // Lista Scadenze
        Expanded(
          child: items.isEmpty 
            ? const Center(child: Text('Nessuna scadenza prevista.'))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final nome = item is Lavoro ? item.nome : (item as Obbligo).nome ?? 'Obbligo';
                  final targa = item is Lavoro ? item.targaAuto : (item as Obbligo).targaAuto ?? '-';
                  final data = item is Lavoro ? item.data : (item as Obbligo).dataScadenza;
                  
                  int? kmRimanenti;
                  if (item is Lavoro) {
                    kmRimanenti = (item.chilometraggio ?? 0) - currentKm;
                  }

                  final giorni = data?.difference(now).inDays ?? 999;
                  final isScaduta = giorni < 0 || (kmRimanenti != null && kmRimanenti < 0);
                  final isImminente = !isScaduta && (giorni <= 31 || (kmRimanenti != null && kmRimanenti <= 1000));

                  final statusColor = isScaduta 
                      ? AppColors.rosso 
                      : (isImminente ? AppColors.arancione : AppColors.verde);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 2,
                    color: AppColors.bianco,
                    child: InkWell(
                      onTap: () {
                        if (item is Lavoro) {
                          onLavoroClick?.call(item);
                        } else if (item is Obbligo) {
                          onObbligoClick?.call(item);
                        }
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Icona principale
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.bluChiaro,
                              child: SvgPicture.asset(
                                item is Lavoro ? 'assets/images/ic_lavoro.svg' : 'assets/images/ic_obbligo.svg',
                                colorFilter: const ColorFilter.mode(AppColors.blu, BlendMode.srcIn),
                                width: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Titolo e Nome Auto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nome, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.nero)
                                  ),
                                  // Text(
                                  //   viewModel.auto?.nomeCompleto ?? targa,
                                  //   style: const TextStyle(color: AppColors.grigio, fontSize: 14)
                                  // ),
                                ],
                              ),
                            ),
                            
                            // Data e Stato temporale
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (data != null)
                                  Text(
                                    df.format(data),
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                Text(
                                  isScaduta 
                                    ? "Scaduta" 
                                    : (giorni <= 0 
                                        ? "Oggi" 
                                        : (kmRimanenti != null ? "Tra $kmRimanenti Km" : "Tra $giorni giorni")),
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            
                            // Icona sveglia
                            SvgPicture.asset(
                              'assets/images/ic_sveglia.svg',
                              colorFilter: ColorFilter.mode(statusColor, BlendMode.srcIn),
                              width: 32,
                              height: 32,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _statCol(String label, String value, Color labelColor, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label, 
          style: TextStyle(fontWeight: FontWeight.bold, color: labelColor, fontSize: 13, decoration: TextDecoration.none)
        ),
        Text(
          value, 
          style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 24, decoration: TextDecoration.none)
        ),
      ],
    );
  }
}
