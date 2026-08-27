import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/auto.dart';
import '../../models/enum.dart';
import '../../theme/app_colors.dart';
import '../../widgets/blue_header_card.dart';
import 'censimento_viewmodel.dart';

class CensimentoScreen extends StatefulWidget {
  const CensimentoScreen({super.key});

  @override
  State<CensimentoScreen> createState() => _CensimentoScreenState();
}

class _CensimentoScreenState extends State<CensimentoScreen> {
  final _targaController = TextEditingController();
  final _modelloController = TextEditingController();
  final _marcaController = TextEditingController();
  final _vinController = TextEditingController();
  final _cilindrataController = TextEditingController();
  final _identificatoreMotoreController = TextEditingController();
  final _potenzaController = TextEditingController();
  final _kmController = TextEditingController();

  DateTime? _dataImmatricolazione;
  Alimentazione? _alimentazione;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return ChangeNotifierProvider(
      create: (_) => CensimentoViewModel(),
      child: Consumer<CensimentoViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.bluChiaro2,
            body: SafeArea(
              child: Column(
                children: [
                  const BlueHeaderCard(
                    title: 'Censisci nuova auto',
                    height: 220,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildWhiteField(_targaController, 'Targa'),
                          _buildWhiteField(_marcaController, 'Marca'),
                          _buildWhiteField(_modelloController, 'Modello'),
                          _buildWhiteField(_cilindrataController, 'Cilindrata', keyboardType: TextInputType.number),
                          _buildWhiteField(_kmController, 'Km attuali', keyboardType: TextInputType.number),
                          
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setState(() => _dataImmatricolazione = picked);
                            },
                            child: _buildWhiteFieldStatic(
                                _dataImmatricolazione == null ? '' : df.format(_dataImmatricolazione!), 
                                'Data Immatricolazione'),
                          ),
                          
                          _buildWhiteField(_potenzaController, 'Potenza', keyboardType: TextInputType.number),
                          _buildWhiteField(_identificatoreMotoreController, 'Codice motore'),
                          
                          _buildDropdownField(),
                          
                          _buildWhiteField(_vinController, 'Vin'),
                          
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
                                  child: const Text('Annulla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: FilledButton(
                                  onPressed: viewModel.loading
                                      ? null
                                      : () async {
                                          final success = await viewModel.salvaAuto(Auto(
                                            targa: _targaController.text,
                                            modello: _modelloController.text,
                                            marchio: _marcaController.text,
                                            vin: _vinController.text,
                                            dataImmatricolazione: _dataImmatricolazione ?? DateTime.now(),
                                            cilindrata: int.tryParse(_cilindrataController.text) ?? 0,
                                            alimentazione: _alimentazione ?? Alimentazione.benz,
                                            pathLibretto: '',
                                            identificatoreMotore: _identificatoreMotoreController.text,
                                            potenza: int.tryParse(_potenzaController.text) ?? 0,
                                            stato: StatoAuto.attivo,
                                            chilometraggio: int.tryParse(_kmController.text) ?? 0,
                                          ));
                                          if (success && context.mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.blu,
                                    minimumSize: const Size.fromHeight(60),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: viewModel.loading
                                      ? const CircularProgressIndicator(color: AppColors.bianco)
                                      : const Text('Salva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
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

  Widget _buildWhiteField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.blu),
          filled: true,
          fillColor: AppColors.bianco,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteFieldStatic(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        isEmpty: value.isEmpty,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.blu),
          filled: true,
          fillColor: AppColors.bianco,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
        ),
        child: Text(value, style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<Alimentazione>(
        value: _alimentazione,
        decoration: InputDecoration(
          labelText: 'Alimentazione',
          labelStyle: const TextStyle(color: AppColors.blu),
          filled: true,
          fillColor: AppColors.bianco,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
        ),
        iconEnabledColor: AppColors.blu,
        style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold, fontSize: 16),
        items: Alimentazione.values
            .map((a) => DropdownMenuItem(
                  value: a,
                  child: Text(a.dbValue),
                ))
            .toList(),
        onChanged: (value) => setState(() => _alimentazione = value),
      ),
    );
  }
}
