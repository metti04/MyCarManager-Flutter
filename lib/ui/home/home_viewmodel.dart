import 'package:flutter/material.dart';
import '../../models/auto.dart';
import '../../models/enum.dart';
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

  // Mappa per sapere se un'auto ha scadenze imminenti o scadute
  final Map<String, bool> _autoConScadenze = {};
  bool haScadenze(String targa) => _autoConScadenze[targa] ?? false;

  double _speseTotali = 0.0;
  double get speseTotali => _speseTotali;

  int _countScadute = 0;
  int get countScadute => _countScadute;

  int _countImminenti = 0;
  int get countImminenti => _countImminenti;

  int _countRegolari = 0;
  int get countRegolari => _countRegolari;

  int get scadenzeTotali => _countScadute + _countImminenti + _countRegolari;

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
      
      double speseTotali = 0.0;
      int scadute = 0;
      int imminenti = 0;
      int regolari = 0;
      final now = DateTime.now();

      // 2. Analizza ogni auto per calcolare spese e scadenze complessive
      for (var auto in _autos) {
        final lavori = await _lavoroService.getLavoriByTarga(auto.targa);
        final obblighi = await _obbligoService.getObblighiByTarga(auto.targa);

        bool carHasDeadlines = false;

        // Calcolo spese totali (tutti i lavori già eseguiti)
        for (var l in lavori) {
          if (l.stato == StatoLavoro.eseguito) {
            speseTotali += (l.costo ?? 0.0);
          }
          // Conteggio scadenze (lavori da eseguire)
          if (l.stato == StatoLavoro.daEseguire) {
            final giorni = l.data.difference(now).inDays;
            final kmRimanenti = (l.chilometraggio ?? 0) - auto.chilometraggio;

            if (giorni < 0 || kmRimanenti < 0) {
              scadute++;
              carHasDeadlines = true;
            } else if (giorni <= 31 || kmRimanenti <= 1000) {
              imminenti++;
              carHasDeadlines = true;
            }
            else {
              regolari++;
            }
          }
        }

        // Calcolo spese totali per obblighi fiscali pagati
        for (var o in obblighi) {
          if (o.stato == StatoObbligo.pagato) {
            speseTotali += (o.costo ?? 0.0);
          }
          // Conteggio obblighi in scadenza (da pagare)
          if (o.stato == StatoObbligo.daPagare && o.dataScadenza != null) {
            final giorni = o.dataScadenza!.difference(now).inDays;
            if (giorni < 0) {
              scadute++;
              carHasDeadlines = true;
            } else if (giorni <= 31) {
              imminenti++;
              carHasDeadlines = true;
            }
            else {
              regolari++;
            }
          }
        }
        _autoConScadenze[auto.targa] = carHasDeadlines;
      }
      
      _speseTotali = speseTotali;
      _countScadute = scadute;
      _countImminenti = imminenti;
      _countRegolari = regolari;

    } catch (e) {
      debugPrint('Errore caricamento dati home: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
