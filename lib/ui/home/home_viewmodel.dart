import 'package:flutter/material.dart';
import '../../models/auto.dart';
import '../../models/enum.dart';
import '../../services/auto_service.dart';
import '../../services/lavoro_service.dart';
import '../../services/obbligo_service.dart';
import '../../services/possedere_service.dart';
import '../../theme/app_colors.dart';

class HomeViewModel extends ChangeNotifier {
  // Dipendenze per il recupero dati aggregati
  final _autoService = AutoService();
  final _possedereService = PossedereService();
  final _lavoroService = LavoroService();
  final _obbligoService = ObbligoService();

  // Liste e conteggi per la dashboard
  List<Auto> _autos = [];
  List<Auto> get autos => _autos;

  // Mappa per il colore della sveglia di ciascuna auto (Verde, Giallo/Arancione, Rosso)
  final Map<String, Color> _autoSvegliaColor = {};

  // Restituisce il colore della sveglia per l'auto specificata
  Color getSvegliaColor(String targa) => _autoSvegliaColor[targa] ?? AppColors.verde;

  // Restituisce `true` se l'auto ha scadenze imminenti o scadute
  bool haScadenze(String targa) => getSvegliaColor(targa) != AppColors.verde;

  double _speseTotali = 0.0;
  double get speseTotali => _speseTotali;

  int _countScadute = 0;
  int get countScadute => _countScadute;

  int _countImminenti = 0;
  int get countImminenti => _countImminenti;

  int get scadenzeTotali => _countScadute + _countImminenti;

  bool _loading = false;
  bool get loading => _loading;

  // Carica tutti i dati necessari per popolare la schermata Home dell'utente
  Future<void> caricaTuttiIDati(String username) async {
    _loading = true;
    notifyListeners();

    try {
      // Recupera le auto associate all'utente
      final targhe = await _possedereService.getTargheByUser(username);
      _autos = await _autoService.getAutoByTarghe(targhe);
      
      double speseTotali = 0.0;
      int scadute = 0;
      int imminenti = 0;
      final now = DateTime.now();

      // Analizza ogni auto per calcolare spese e scadenze complessive
      for (var auto in _autos) {
        final lavori = await _lavoroService.getLavoriByTarga(auto.targa);
        final obblighi = await _obbligoService.getObblighiByTarga(auto.targa);

        int autoScadute = 0;
        int autoImminenti = 0;

        // Calcolo spese totali (tutti i lavori già eseguiti) e conteggio scadenze lavori (da eseguire)
        for (var l in lavori) {
          if (l.stato == StatoLavoro.eseguito) {
            speseTotali += (l.costo ?? 0.0);
          }
          if (l.stato == StatoLavoro.daEseguire) {
            final giorni = l.data.difference(now).inDays;
            final kmRimanenti = (l.chilometraggio ?? 0) - auto.chilometraggio;

            if (giorni < 0 || kmRimanenti < 0) {
              autoScadute++;
            } else if (giorni <= 31 || (kmRimanenti >= 0 && kmRimanenti <= 1000)) {
              autoImminenti++;
            }
          }
        }

        // Calcolo spese totali per obblighi fiscali pagati e conteggio obblighi in scadenza (da pagare)
        for (var o in obblighi) {
          if (o.stato == StatoObbligo.pagato) {
            speseTotali += (o.costo ?? 0.0);
          }
          if (o.stato == StatoObbligo.daPagare && o.dataScadenza != null) {
            final giorni = o.dataScadenza!.difference(now).inDays;
            if (giorni < 0) {
              autoScadute++;
            } else if (giorni <= 31) {
              autoImminenti++;
            }
          }
        }

        scadute += autoScadute;
        imminenti += autoImminenti;

        // Imposta il colore della sveglia per l'auto
        if (autoScadute > 0) {
          _autoSvegliaColor[auto.targa] = AppColors.rosso;
        } else if (autoImminenti > 0) {
          _autoSvegliaColor[auto.targa] = AppColors.arancione;
        } else {
          _autoSvegliaColor[auto.targa] = AppColors.verde;
        }
      }
      
      _speseTotali = speseTotali;
      _countScadute = scadute;
      _countImminenti = imminenti;

    } catch (e) {
      debugPrint('Errore caricamento dati home: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
