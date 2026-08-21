import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lavoro.dart';
import '../../models/obbligo.dart';
import '../../theme/app_colors.dart';
import '../scheda_auto/scheda_auto_viewmodel.dart';

class SpeseAutoFragment extends StatelessWidget {
  final SchedaAutoViewModel viewModel;
  const SpeseAutoFragment({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final items = viewModel.itemsSpese;
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
                  child: Column(
                    children: [
                      const Text('TOTALE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.grigioMedio, decoration: TextDecoration.none)),
                      Text('${viewModel.totaleGenerale.toStringAsFixed(2)}€', style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold, fontSize: 26, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
                Container(width: 1, height: 50, color: AppColors.grigino),
                Expanded(
                  child: Column(
                    children: [
                      _smallSpesaRow(Icons.build, '${viewModel.totLavori.toStringAsFixed(2)}€', 'Lavori'),
                      const SizedBox(height: 8),
                      _smallSpesaRow(Icons.assignment, '${viewModel.totObblighi.toStringAsFixed(2)}€', 'Obblighi'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final nome = item is Lavoro ? item.nome : (item as Obbligo).nome ?? 'Obbligo';
              final costo = item is Lavoro ? item.costo : (item as Obbligo).costo;
              final data = item is Lavoro ? item.data : (item as Obbligo).dataPagamento;
              final icon = item is Lavoro ? Icons.build : Icons.assignment;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: AppColors.bianco,
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.bluChiaro, child: Icon(icon, color: AppColors.blu, size: 20)),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data != null ? df.format(data) : '-'),
                  trailing: Text('${costo?.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blu, fontSize: 16)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _smallSpesaRow(IconData icon, String value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.blu),
        const SizedBox(width: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, decoration: TextDecoration.none, color: AppColors.nero)),
      ],
    );
  }
}
