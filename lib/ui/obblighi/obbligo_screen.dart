import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/obbligo.dart';
import '../../theme/app_colors.dart';
import '../../widgets/blue_header_card.dart';
import 'obbligo_viewmodel.dart';

class ObbligoScreen extends StatefulWidget {
  final String? targa;
  final Obbligo? obbligoDaModificare;

  const ObbligoScreen({super.key, this.targa, this.obbligoDaModificare});

  @override
  State<ObbligoScreen> createState() => _ObbligoScreenState();
}

class _ObbligoScreenState extends State<ObbligoScreen> {
  final _targaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _costoController = TextEditingController();

  DateTime _dataScadenza = DateTime.now().add(const Duration(days: 365));
  DateTime? _dataPagamento;

  @override
  void initState() {
    super.initState();
    if (widget.obbligoDaModificare != null) {
      final o = widget.obbligoDaModificare!;
      _targaController.text = o.targaAuto ?? "";
      _nomeController.text = o.nome ?? "";
      _costoController.text = o.costo?.toString() ?? "";
      _dataScadenza = o.dataScadenza ?? DateTime.now();
      _dataPagamento = o.dataPagamento;
    } else if (widget.targa != null) {
      _targaController.text = widget.targa!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final isModifica = widget.obbligoDaModificare != null;

    return ChangeNotifierProvider(
      create: (_) => ObbligoViewModel(),
      child: Consumer<ObbligoViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.bluChiaro2,
            body: SafeArea(
              child: Column(
                children: [
                  BlueHeaderCard(
                    title: isModifica ? 'Modifica Obbligo' : 'Nuovo Obbligo',
                    height: 220,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildWhiteField(_targaController, 'Targa', enabled: widget.targa == null && !isModifica),
                          _buildWhiteField(_nomeController, 'Nome Obbligo (es. Bollo)'),
                          _buildWhiteField(_costoController, 'Costo', keyboardType: TextInputType.number),

                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dataScadenza,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => _dataScadenza = picked);
                            },
                            child: _buildWhiteFieldStatic(df.format(_dataScadenza), 'Data Scadenza'),
                          ),

                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dataPagamento ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => _dataPagamento = picked);
                            },
                            child: _buildWhiteFieldStatic(df.format(_dataPagamento ?? DateTime.now()), 'Data Pagamento'),
                          ),

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
                                          final success = await viewModel.salvaObbligo(
                                            targa: _targaController.text,
                                            nome: _nomeController.text,
                                            costo: _costoController.text,
                                            dataScadenza: _dataScadenza,
                                            dataPagamento: _dataPagamento,
                                            idEsistente: widget.obbligoDaModificare?.id,
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

  Widget _buildWhiteField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
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
