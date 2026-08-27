import 'package:flutter/material.dart';
import '../../models/lavoro.dart';
import '../../models/enum.dart';
import '../../services/lavoro_service.dart';

class LavoroViewModel extends ChangeNotifier {
  final _lavoroService = LavoroService();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  // Salva il lavoro nel database e gestisce la creazione automatica della scadenza successiva se ordinario.
  Future<bool> salvaLavoro({
    required String targa,
    required String nome,
    required String costo,
    required DateTime data,
    required String chilometraggio,
    required String descrizione,
    required bool isOrdinario,
    String? intervalloKm,
    String? intervalloMesi,
    int? idEsistente,
    bool isModifica = false,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final lavoro = Lavoro(
        id: idEsistente,
        nome: nome,
        tipologia: isOrdinario ? TipologiaLavoro.ordinario : TipologiaLavoro.straordinario,
        chilometraggio: int.tryParse(chilometraggio) ?? 0,
        data: data,
        descrizione: descrizione,
        stato: StatoLavoro.eseguito,
        costo: double.tryParse(costo.replaceAll(',', '.')) ?? 0.0,
        intervalloKm: isOrdinario ? int.tryParse(intervalloKm ?? '') : null,
        intervalloTempo: isOrdinario ? int.tryParse(intervalloMesi ?? '') : null,
        targaAuto: targa.toUpperCase().trim(),
      );

      // Logica per l'inserimento di un nuovo lavoro ordinario: crea anche la scadenza futura.
      if (!isModifica && isOrdinario && intervalloKm != null && intervalloMesi != null) {
        final kmFuturi = (int.tryParse(chilometraggio) ?? 0) + (int.tryParse(intervalloKm) ?? 0);
        final dataFutura = DateTime(data.year, data.month + (int.tryParse(intervalloMesi) ?? 0), data.day);

        final scadenza = Lavoro(
          nome: nome,
          tipologia: TipologiaLavoro.ordinario,
          chilometraggio: kmFuturi,
          data: dataFutura,
          descrizione: descrizione,
          stato: StatoLavoro.daEseguire,
          costo: 0.0,
          intervalloKm: int.tryParse(intervalloKm),
          intervalloTempo: int.tryParse(intervalloMesi),
          targaAuto: targa.toUpperCase().trim(),
        );

        await _lavoroService.inserisciLavoro(scadenza);
      }

      if (idEsistente == null) {
        await _lavoroService.inserisciLavoro(lavoro);
      } else {
        await _lavoroService.aggiornaLavoro(lavoro);
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
