import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/obbligo.dart';
import '../../models/enum.dart';
import '../../theme/app_colors.dart';
import '../../widgets/expandable_action_card.dart';
import '../scheda_auto/scheda_auto_viewmodel.dart';

class ObblighiAutoFragment extends StatelessWidget {
  final SchedaAutoViewModel viewModel;
  final Function(Obbligo) onEdit;
  const ObblighiAutoFragment({super.key, required this.viewModel, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final obblighi = viewModel.obblighiPagati;
    if (obblighi.isEmpty) return const Center(child: Text('Nessun obbligo pagato registrato.'));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: obblighi.length,
      itemBuilder: (context, index) {
        final o = obblighi[index];
        final df = DateFormat('dd/MM/yyyy');
        return ExpandableActionCard(
          iconaAsset: 'assets/images/ic_obbligo.svg',
          titolo: o.nome ?? 'Obbligo',
          valore: '${o.costo?.toStringAsFixed(2)}€',
          righeChiaveValore: [
            if (o.dataPagamento != null) DetailRow('Pagato il', df.format(o.dataPagamento!)),
            if (o.dataScadenza != null) DetailRow('Scadenza', df.format(o.dataScadenza!)),
          ],
          onEdit: () => onEdit(o),
          onDelete: () => _confermaEliminaObbligo(context, viewModel, o),
        );
      },
    );
  }

  void _confermaEliminaObbligo(BuildContext context, SchedaAutoViewModel viewModel, Obbligo o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina obbligo'),
        content: Text('Eliminare "${o.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () async {
              await viewModel.eliminaObbligo(o.id!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Elimina', style: TextStyle(color: AppColors.rosso)),
          ),
        ],
      ),
    );
  }
}
