import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/auto.dart';
import '../../theme/app_colors.dart';
import 'scheda_auto_viewmodel.dart';

class DettagliAutoFragment extends StatefulWidget {
  final Auto auto;
  final SchedaAutoViewModel viewModel;
  const DettagliAutoFragment({super.key, required this.auto, required this.viewModel});

  @override
  State<DettagliAutoFragment> createState() => _DettagliAutoFragmentState();
}

class _DettagliAutoFragmentState extends State<DettagliAutoFragment> {
  final _kmController = TextEditingController();
  bool _editingKm = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: AppColors.bianco,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dati Veicolo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.blu)),
                  const Divider(color: AppColors.bluChiaro),
                  const SizedBox(height: 10),
                  _infoRow('Marca', widget.auto.marchio),
                  _infoRow('Modello', widget.auto.modello),
                  _infoRow('Targa', widget.auto.targa),
                  _infoRow('VIN', widget.auto.vin),
                  _infoRow('Motore', widget.auto.identificatoreMotore),
                  const SizedBox(height: 15),
// Sezione chilometraggio con possibilità di modifica in-place
                  Row(
                    children: [
                      const Text('KM attuali: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.nero)),
                      Expanded(
                        child: !_editingKm
                            ? Text('${widget.auto.chilometraggio}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blu))
                            : TextField(
                                controller: _kmController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blu),
                              ),
                      ),
                      const SizedBox(width: 8),
                      // Pulsante per abilitare/salvare la modifica del chilometraggio
                      IconButton(
                        icon: _editingKm
                            ? const Icon(Icons.check_circle, color: AppColors.blu)
                            : SvgPicture.asset(
                                'assets/images/ic_modifica.svg',
                                colorFilter: const ColorFilter.mode(AppColors.blu, BlendMode.srcIn),
                                width: 24,
                                height: 24,
                              ),
                        onPressed: () async {
                          if (!_editingKm) {
                            _kmController.text = widget.auto.chilometraggio.toString();
                            setState(() => _editingKm = true);
                          } else {
                            final newKm = int.tryParse(_kmController.text);
                            if (newKm != null) await widget.viewModel.updateKm(newKm);
                            setState(() => _editingKm = false);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.grigioMedio, fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold, fontSize: 16))),
        ],
      ),
    );
  }
}
