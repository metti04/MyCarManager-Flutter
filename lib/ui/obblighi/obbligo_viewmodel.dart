import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/obbligo.dart';
import '../../models/enums.dart';
import '../../models/ai_data_models.dart';
import '../../services/obbligo_service.dart';
import '../../services/api_services/obbligo_api_service.dart';

class ObbligoViewModel extends ChangeNotifier {
  final _obbligoService = ObbligoService();
  final _apiService = ObbligoApiService();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  InvoiceResult? _datiestratti;
  InvoiceResult? get datiestratti => _datiestratti;

  // Analizza l'immagine di un bollo o assicurazione per estrarne i dati.
  Future<void> estraiDatiDaDocumento(Uint8List imageBytes) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.extractObbligoData(imageBytes);
      _datiestratti = result;
    } catch (e) {
      _error = "Errore durante l'estrazione: $e";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Pulisce i dati estratti dopo che sono stati applicati ai campi.
  void resetDatiEstratti() {
    _datiestratti = null;
    notifyListeners();
  }

  // Salva un obbligo fiscale nel database.
  Future<bool> salvaObbligo({
    required String targa,
    required String nome,
    required String costo,
    required DateTime dataScadenza,
    DateTime? dataPagamento,
    int? idEsistente,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final obbligo = Obbligo(
        id: idEsistente,
        nome: nome,
        targaAuto: targa.toUpperCase().trim(),
        costo: double.tryParse(costo.replaceAll(',', '.')) ?? 0.0,
        dataScadenza: dataScadenza,
        dataPagamento: dataPagamento,
        stato: dataPagamento != null ? StatoObbligo.pagato : StatoObbligo.daPagare,
      );

      if (idEsistente == null) {
        await _obbligoService.inserisciObbligo(obbligo);
      } else {
        await _obbligoService.aggiornaObbligo(obbligo);
      }

      return true;
    } catch (e) {
      _error = "Errore durante il salvataggio: $e";
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
