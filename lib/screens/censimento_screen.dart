import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/auto.dart';
import '../models/enums.dart';
import '../services/auto_service.dart';
import '../widgets/blue_header_card.dart';

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
  Alimentazione _alimentazione = Alimentazione.benz;

  final _autoService = AutoService();
  bool _loading = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(1950), lastDate: now);
    if (picked != null) setState(() => _dataImmatricolazione = picked);
  }

  Future<void> _salva() async {
    final targa = _targaController.text.trim().toUpperCase();
    final modello = _modelloController.text.trim();
    final marchio = _marcaController.text.trim();
    final vin = _vinController.text.trim().toUpperCase();
    final identificatoreMotore = _identificatoreMotoreController.text.trim();

    if (targa.isEmpty || modello.isEmpty || marchio.isEmpty || vin.isEmpty ||
        _dataImmatricolazione == null || identificatoreMotore.isEmpty) {
      _showError('Tutti i campi sono obbligatori');
      return;
    }
    if (vin.length != 17) {
      _showError('Il VIN deve avere esattamente 17 caratteri');
      return;
    }

    setState(() => _loading = true);
    try {
      final listaAuto = await _autoService.getAllAuto();
      if (listaAuto.any((a) => a.targa == targa)) {
        _showError('Targa già esistente nel database');
        return;
      }
      if (listaAuto.any((a) => a.vin == vin)) {
        _showError('VIN già esistente nel database');
        return;
      }

      final nuovaAuto = Auto(
        targa: targa,
        modello: modello,
        marchio: marchio,
        vin: vin,
        dataImmatricolazione: _dataImmatricolazione!,
        cilindrata: int.tryParse(_cilindrataController.text) ?? 0,
        alimentazione: _alimentazione,
        pathLibretto: 'path_placeholder',
        identificatoreMotore: identificatoreMotore,
        potenza: int.tryParse(_potenzaController.text) ?? 0,
        stato: StatoAuto.attivo,
        chilometraggio: int.tryParse(_kmController.text) ?? 0,
      );

      await _autoService.inserisciAuto(nuovaAuto);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veicolo registrato con successo!')));
      Navigator.of(context).pop();
    } catch (e) {
      _showError('Errore durante il salvataggio: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BlueHeaderCard(
              title: 'Censisci nuova auto',
              height: 250,
              actionBox: HeaderActionBox(
                icon: Icons.document_scanner,
                label: 'Scansiona',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Scansione libretto non disponibile in questa versione: compila il form manualmente.'))),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(controller: _targaController, decoration: const InputDecoration(labelText: 'Targa')),
                    const SizedBox(height: 12),
                    TextField(controller: _marcaController, decoration: const InputDecoration(labelText: 'Marca')),
                    const SizedBox(height: 12),
                    TextField(controller: _modelloController, decoration: const InputDecoration(labelText: 'Modello')),
                    const SizedBox(height: 12),
                    TextField(controller: _vinController, decoration: const InputDecoration(labelText: 'VIN (17 caratteri)')),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Data immatricolazione'),
                        child: Text(_dataImmatricolazione == null ? '' : df.format(_dataImmatricolazione!)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Alimentazione>(
                      initialValue: _alimentazione,
                      decoration: const InputDecoration(labelText: 'Alimentazione'),
                      items: Alimentazione.values.map((a) => DropdownMenuItem(value: a, child: Text(a.dbValue))).toList(),
                      onChanged: (value) => setState(() => _alimentazione = value ?? _alimentazione),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cilindrataController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Cilindrata'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _potenzaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Potenza (CV)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _identificatoreMotoreController,
                      decoration: const InputDecoration(labelText: 'Identificatore motore'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Chilometraggio attuale'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Annulla'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _loading ? null : _salva,
                            child: _loading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Salva'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
