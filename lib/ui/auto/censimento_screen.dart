import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import '../../models/auto.dart';
import '../../models/enums.dart';
import '../../models/ai_data_models.dart';
import '../../services/api_services/auto_api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/blue_header_card.dart';
import 'censimento_viewmodel.dart';

class CensimentoScreen extends StatefulWidget {
  const CensimentoScreen({super.key});

  @override
  State<CensimentoScreen> createState() => _CensimentoScreenState();
}

class _CensimentoScreenState extends State<CensimentoScreen> {
  final _autoApiService = AutoApiService();
  final _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return ChangeNotifierProvider(
      create: (_) => CensimentoViewModel(),
      child: Consumer<CensimentoViewModel>(
        builder: (context, viewModel, _) {
          // Ascolta i dati estratti dall'IA
          if (viewModel.datiEstratti != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
               _popolaCampiDaAI(viewModel.datiEstratti!);
               viewModel.resetDatiEstratti();
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Dati estratti con successo!')),
               );
            });
          }

          return Scaffold(
            backgroundColor: AppColors.bluChiaro2,
            body: SafeArea(
              child: Column(
                children: [
                  BlueHeaderCard(
                    title: 'Censisci nuova auto',
                    height: 220,
                    actionBox: InkWell(
                      onTap: () => _mostraOpzioniScansione(viewModel),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.bianco.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.bianco, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (viewModel.loading)
                               const SizedBox(
                                 width: 20,
                                 height: 20,
                                 child: CircularProgressIndicator(color: AppColors.bianco, strokeWidth: 2),
                               )
                            else
                               const Icon(Icons.document_scanner, color: AppColors.bianco),
                            const SizedBox(width: 10),
                            const Text(
                              'Scansiona Libretto',
                              style: TextStyle(color: AppColors.bianco, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                          
                          _buildWhiteField(_vinController, 'Vin (17 caratteri)'),
                          
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
                                            alimentazione: _alimentazione,
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

  void _mostraOpzioniScansione(CensimentoViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.blu),
              title: const Text('Fotocamera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                if (photo != null) viewModel.estraiDatiDaLibretto(await photo.readAsBytes());
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.blu),
              title: const Text('Galleria'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) viewModel.estraiDatiDaLibretto(await image.readAsBytes());
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.blu),
              title: const Text('Documenti (PDF)'),
              onTap: () async {
                Navigator.pop(context);
                final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (result != null && result.files.single.path != null) {
                  final bytes = await _renderPdfPage(result.files.single.path!);
                  if (bytes != null) viewModel.estraiDatiDaLibretto(bytes);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _renderPdfPage(String path) async {
    try {
      final document = await PdfDocument.openFile(path);
      final page = await document.getPage(1);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.jpeg,
      );
      await page.close();
      await document.close();
      return pageImage?.bytes;
    } catch (e) {
      debugPrint('Errore rendering PDF: $e');
      return null;
    }
  }

  void _popolaCampiDaAI(SmartResult result) {
    setState(() {
      for (var item in result.extractedData) {
        switch (item.type) {
          case DataType.plate: _targaController.text = item.value; break;
          case DataType.brand: _marcaController.text = item.value; break;
          case DataType.model: _modelloController.text = item.value; break;
          case DataType.displacement: _cilindrataController.text = item.value; break;
          case DataType.power: _potenzaController.text = item.value; break;
          case DataType.engine: _identificatoreMotoreController.text = item.value; break;
          case DataType.vin: _vinController.text = item.value; break;
          case DataType.date:
            try {
               _dataImmatricolazione = DateFormat('dd/MM/yyyy').parse(item.value);
            } catch (_) {}
            break;
          case DataType.fuel: 
            _alimentazione = Alimentazione.values.firstWhere(
              (a) => a.dbValue.toLowerCase() == item.value.toLowerCase(),
              orElse: () => _alimentazione,
            );
            break;
          default: break;
        }
      }
    });
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.blu),
          filled: true,
          fillColor: AppColors.bianco,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
        onChanged: (value) => setState(() => _alimentazione = value ?? _alimentazione),
      ),
    );
  }
}
