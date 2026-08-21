import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lavoro.dart';
import '../../models/obbligo.dart';
import '../../theme/app_colors.dart';
import '../scheda_auto/scheda_auto_viewmodel.dart';

class ScadenzeAutoFragment extends StatelessWidget {
  final SchedaAutoViewModel viewModel;
  const ScadenzeAutoFragment({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final items = viewModel.itemsScadenze;
    final df = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: AppColors.bianco,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _statCol('Scadute', '${viewModel.countScadute}', AppColors.rosso),
                ),
                Container(width: 1, height: 50, color: AppColors.grigino),
                Expanded(
                  child: _statCol('Imminenti', '${viewModel.countImminenti}', AppColors.arancione),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty 
            ? const Center(child: Text('Nessuna scadenza prevista.'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final nome = item is Lavoro ? item.nome : (item as Obbligo).nome ?? 'Obbligo';
                  final data = item is Lavoro ? item.data : (item as Obbligo).dataScadenza;
                  final icon = item is Lavoro ? Icons.build : Icons.assignment;
                  final isScaduta = data != null && data.isBefore(now);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: AppColors.bianco,
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: AppColors.bluChiaro, child: Icon(icon, color: AppColors.blu, size: 20)),
                      title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(data != null ? df.format(data) : '-', 
                               style: TextStyle(color: isScaduta ? AppColors.rosso : AppColors.nero, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Icon(Icons.alarm, color: isScaduta ? AppColors.rosso : AppColors.verde, size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _statCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.grigioMedio, fontSize: 16, decoration: TextDecoration.none)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 26, decoration: TextDecoration.none)),
      ],
    );
  }
}
