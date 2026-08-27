import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/lavoro.dart';
import '../../models/enum.dart';
import '../../theme/app_colors.dart';
import '../../widgets/blue_header_card.dart';
import 'lavoro_viewmodel.dart';

class LavoroScreen extends StatefulWidget {
  final String? targa;
  final Lavoro? lavoroDaModificare;

  const LavoroScreen({super.key, this.targa, this.lavoroDaModificare});

  @override
  State<LavoroScreen> createState() => _LavoroScreenState();
}

class _LavoroScreenState extends State<LavoroScreen> {
  final _targaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _costoController = TextEditingController();
  final _kmController = TextEditingController();
  final _descController = TextEditingController();
  final _intervalloKmController = TextEditingController();
  final _intervalloMesiController = TextEditingController();

  DateTime _dataEsecuzione = DateTime.now();
  bool _isOrdinario = true;

  @override
  void initState() {
    super.initState();
    if (widget.lavoroDaModificare != null) {
      final l = widget.lavoroDaModificare!;
      _targaController.text = l.targaAuto;
      _nomeController.text = l.nome;
      _costoController.text = l.costo?.toString() ?? "";
      _kmController.text = l.chilometraggio?.toString() ?? "";
      _descController.text = l.descrizione ?? "";
      _dataEsecuzione = l.data;
      _isOrdinario = l.tipologia == TipologiaLavoro.ordinario;
      _intervalloKmController.text = l.intervalloKm?.toString() ?? "";
      _intervalloMesiController.text = l.intervalloTempo?.toString() ?? "";
    } else if (widget.targa != null) {
      _targaController.text = widget.targa!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final isModifica = widget.lavoroDaModificare != null;

    return ChangeNotifierProvider(
      create: (_) => LavoroViewModel(),
      child: Consumer<LavoroViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.bluChiaro2,
            body: SafeArea(
              child: Column(
                children: [
                  BlueHeaderCard(
                    title: isModifica ? 'Modifica lavoro' : 'Inserisci un nuovo lavoro',
                    height: 220,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildWhiteField(_targaController, 'Targa', enabled: widget.targa == null && !isModifica),
                          _buildWhiteField(_nomeController, 'Nome Lavoro'),
                          _buildWhiteField(_costoController, 'Costo', keyboardType: TextInputType.number),
                          _buildWhiteField(_kmController, 'Chilometraggio', keyboardType: TextInputType.number),

                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dataEsecuzione,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => _dataEsecuzione = picked);
                            },
                            child: _buildWhiteFieldStatic(df.format(_dataEsecuzione), 'Data Esecuzione'),
                          ),

                          _buildWhiteField(_descController, 'Descrizione', maxLines: 3),

                          Row(
                            children: [
                              Checkbox(
                                value: _isOrdinario,
                                onChanged: (v) => setState(() => _isOrdinario = v ?? true),
                                activeColor: AppColors.blu,
                              ),
                              const Text('Lavoro Ordinario (genera scadenza)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.bluScuro)),
                            ],
                          ),

                          if (_isOrdinario) ...[
                            _buildWhiteField(_intervalloKmController, 'Intervallo Km', keyboardType: TextInputType.number),
                            _buildWhiteField(_intervalloMesiController, 'Intervallo Mesi', keyboardType: TextInputType.number),
                          ],

                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.bluPastello,
                                    minimumSize: const Size.fromHeight(60),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: const Text('Annulla', style: TextStyle(fontSize: 18)),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: FilledButton(
                                  onPressed: viewModel.loading
                                      ? null
                                      : () async {
                                          final success = await viewModel.salvaLavoro(
                                            targa: _targaController.text,
                                            nome: _nomeController.text,
                                            costo: _costoController.text,
                                            data: _dataEsecuzione,
                                            chilometraggio: _kmController.text,
                                            descrizione: _descController.text,
                                            isOrdinario: _isOrdinario,
                                            intervalloKm: _intervalloKmController.text,
                                            intervalloMesi: _intervalloMesiController.text,
                                            idEsistente: widget.lavoroDaModificare?.id,
                                            isModifica: isModifica,
                                          );
                                          if (success && context.mounted) {
                                            Navigator.of(context).pop(true);
                                          }
                                        },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.blu,
                                    minimumSize: const Size.fromHeight(60),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: viewModel.loading
                                      ? const CircularProgressIndicator(color: AppColors.bianco)
                                      : const Text('Salva', style: TextStyle(fontSize: 18)),
                                ),
                              ),
                            ],
                          ),
                          if (viewModel.error != null)
                             Padding(
                               padding: const EdgeInsets.only(top: 10),
                               child: Text(viewModel.error!, style: const TextStyle(color: AppColors.rosso)),
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

  Widget _buildWhiteField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        maxLines: maxLines,
        style: TextStyle(color: enabled ? AppColors.blu : AppColors.grigioMedio, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.blu),
          filled: true,
          fillColor: AppColors.bianco,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: AppColors.blu)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: AppColors.blu)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: AppColors.grigino)),
        ),
      ),
    );
  }

  Widget _buildWhiteFieldStatic(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.blu),
          filled: true,
          fillColor: AppColors.bianco,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: AppColors.blu)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: const BorderSide(color: AppColors.blu)),
        ),
        child: Text(value, style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
