import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lavoro.dart';
import '../../models/enums.dart';
import '../../theme/app_colors.dart';
import '../../widgets/expandable_action_card.dart';
import '../scheda_auto/scheda_auto_viewmodel.dart';

class LavoriAutoFragment extends StatelessWidget {
  final SchedaAutoViewModel viewModel;
  final Function(Lavoro) onEdit;
  const LavoriAutoFragment({super.key, required this.viewModel, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final lavori = viewModel.lavori;
    if (lavori.isEmpty) return const Center(child: Text('Nessun lavoro registrato.'));
    
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: lavori.length,
      itemBuilder: (context, index) {
        final l = lavori[index];
        return ExpandableActionCard(
          icona: Icons.build,
          titolo: l.nome,
          valore: '${l.costo?.toStringAsFixed(2)}€',
          righeChiaveValore: [
            DetailRow('Data', DateFormat('dd/MM/yyyy').format(l.data)),
            if (l.chilometraggio != null) DetailRow('Km', '${l.chilometraggio} Km'),
            DetailRow('Stato', l.stato == StatoLavoro.eseguito ? 'Eseguito' : 'Da eseguire'),
          ],
          descrizioneLibera: 'Lavoro ${l.tipologia == TipologiaLavoro.ordinario ? "Ordinario" : "Non ordinario"}\n${l.descrizione ?? ""}',
          onEdit: () => onEdit(l),
          onDelete: () => _confermaEliminaLavoro(context, viewModel, l),
        );
      },
    );
  }

  void _confermaEliminaLavoro(BuildContext context, SchedaAutoViewModel viewModel, Lavoro l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina lavoro'),
        content: Text('Eliminare "${l.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () async {
              await viewModel.eliminaLavoro(l.id!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Elimina', style: TextStyle(color: AppColors.rosso)),
          ),
        ],
      ),
    );
  }
}
