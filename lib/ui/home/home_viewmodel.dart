import 'package:flutter/material.dart';
import '../../models/auto.dart';
import '../../models/enums.dart';
import '../../models/lavoro.dart';
import '../../models/obbligo.dart';
import '../../services/auto_service.dart';
import '../../services/lavoro_service.dart';
import '../../services/obbligo_service.dart';
import '../../services/possedere_service.dart';

class HomeViewModel extends ChangeNotifier {
  // Dipendenze per il recupero dati aggregati
  final _autoService = AutoService();
  final _possedereService = PossedereService();
  final _lavoroService = LavoroService();
  final _obbligoService = ObbligoService();

  // Liste e conteggi per la dashboard
  List<Auto> _autos = [];
  List<Auto> get autos => _autos;

  double _speseDelMese = 0.0;
  double get speseDelMese => _speseDelMese;

  int _scadenzeImminenti = 0;
  int get scadenzeImminenti => _scadenzeImminenti;

  bool _loading = false;
  bool get loading => _loading;

  // Carica tutti i dati necessari per popolare la schermata Home dell'utente
  Future<void> caricaTuttiIDati(String username) async {
    _loading = true;
    notifyListeners();

    try {
      // 1. Recupera le auto associate all'utente
      final targhe = await _possedereService.getTargheByUser(username);
      _autos = await _autoService.getAutoByTarghe(targhe);
      
      double spese = 0.0;
      int scadenze = 0;
      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      // 2. Analizza ogni auto per calcolare spese e scadenze
      for (var auto in _autos) {
        final lavori = await _lavoroService.getLavoriByTarga(auto.targa);
        final obblighi = await _obbligoService.getObblighiByTarga(auto.targa);

        // Calcolo spese del mese corrente (lavori già eseguiti)
        for (var l in lavori) {
          if (l.stato == StatoLavoro.eseguito && l.data.month == currentMonth && l.data.year == currentYear) {
            spese += (l.costo ?? 0.0);
          }
          // Conteggio scadenze previste nei prossimi 31 giorni
          if (l.stato == StatoLavoro.daEseguire && l.data.difference(now).inDays <= 31 && l.data.isAfter(now)) {
            scadenze++;
          }
        }

        // Calcolo spese del mese per obblighi fiscali (bolli, ecc.)
        for (var o in obblighi) {
          if (o.stato == StatoObbligo.pagato && o.dataPagamento != null && o.dataPagamento!.month == currentMonth && o.dataPagamento!.year == currentYear) {
            spese += (o.costo ?? 0.0);
          }
          // Conteggio obblighi in scadenza
          if (o.stato == StatoObbligo.daPagare && o.dataScadenza != null && o.dataScadenza!.difference(now).inDays <= 31 && o.dataScadenza!.isAfter(now)) {
            scadenze++;
          }
        }
      }
      
      _speseDelMese = spese;
      _scadenzeImminenti = scadenze;

    } catch (e) {
      debugPrint('Errore caricamento dati home: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
