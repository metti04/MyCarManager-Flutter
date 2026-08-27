import 'package:flutter/material.dart';
import '../../models/obbligo.dart';
import '../../models/enum.dart';
import '../../services/obbligo_service.dart';

class ObbligoViewModel extends ChangeNotifier {
  final _obbligoService = ObbligoService();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

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
