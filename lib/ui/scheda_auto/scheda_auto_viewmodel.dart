import 'package:flutter/material.dart';
import '../../models/auto.dart';
import '../../models/lavoro.dart';
import '../../models/obbligo.dart';
import '../../models/enum.dart';
import '../../services/auto_service.dart';
import '../../services/lavoro_service.dart';
import '../../services/obbligo_service.dart';

/// ViewModel per la gestione completa dei dati e delle funzionalità della scheda veicolo.
///
/// Si occupa del caricamento dei dettagli dell'auto, dei lavori e degli obblighi associati,
/// calcolando le spese totali e monitorando le scadenze.
class SchedaAutoViewModel extends ChangeNotifier {
  /// Servizio per la gestione delle informazioni dell'auto nel database.
  final _autoService = AutoService();

  /// Servizio per le operazioni di I/O sui lavori di manutenzione.
  final _lavoroService = LavoroService();

  /// Servizio per la gestione degli obblighi fiscali (bollo, assicurazione, ecc.).
  final _obbligoService = ObbligoService();

  /// L'auto di cui visualizzare la scheda dettagliata.
  Auto? _auto;

  /// Restituisce l'oggetto [Auto] attualmente caricato.
  Auto? get auto => _auto;

  /// Lista completa dei lavori associati all'auto.
  List<Lavoro> _lavori = [];

  /// Restituisce tutti i lavori registrati per l'auto.
  List<Lavoro> get lavori => _lavori;

  /// Restituisce la sottolista dei soli lavori già eseguiti.
  List<Lavoro> get lavoriEseguiti => _lavori.where((l) => l.stato == StatoLavoro.eseguito).toList();

  /// Lista completa degli obblighi associati all'auto.
  List<Obbligo> _obblighi = [];

  /// Restituisce tutti gli obblighi associati all'auto.
  List<Obbligo> get obblighi => _obblighi;

  /// Restituisce la sottolista dei soli obblighi già pagati.
  List<Obbligo> get obblighiPagati => _obblighi.where((o) => o.stato == StatoObbligo.pagato).toList();

  /// Stato di caricamento dei dati del veicolo.
  bool _loading = false;

  /// Restituisce `true` se il caricamento dei dati è in corso.
  bool get loading => _loading;

  /// Indice del tab attualmente attivo nella schermata del dettaglio veicolo.
  int _currentTab = 0;

  /// Restituisce l'indice del tab correntemente attivo.
  int get currentTab => _currentTab;

  /// Imposta il tab attivo ed aggiorna i listener.
  ///
  /// [index] L'indice del tab da visualizzare (0: Dettagli, 1: Spese, 2: Scadenze, 3: Lavori, 4: Obblighi).
  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  /// Carica asincronamente i dettagli dell'auto, i lavori e gli obblighi corrispondenti alla [targa].
  Future<void> caricaDati(String targa) async {
    _loading = true;
    notifyListeners();

    try {
      _auto = await _autoService.getAuto(targa);
      _lavori = await _lavoroService.getLavoriByTarga(targa);
      _obblighi = await _obbligoService.getObblighiByTarga(targa);
    } catch (e) {
      debugPrint('Errore caricamento scheda auto: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Inverte lo stato del veicolo (da attivo a inattivo e viceversa).
  Future<void> toggleStato() async {
    if (_auto == null) return;
    if (_auto!.stato == StatoAuto.attivo) {
      await _autoService.setAutoInattiva(_auto!.targa);
    } else {
      await _autoService.setAutoAttiva(_auto!.targa);
    }
    await caricaDati(_auto!.targa);
  }

  /// Aggiorna il chilometraggio attuale del veicolo nel database.
  ///
  /// [newKm] Il nuovo valore del chilometraggio.
  Future<void> updateKm(int newKm) async {
    if (_auto == null) return;
    await _autoService.updateChilometraggio(_auto!.targa, newKm);
    await caricaDati(_auto!.targa);
  }

  /// Elimina definitivamente l'auto dal sistema.
  Future<void> eliminaAuto() async {
    if (_auto == null) return;
    await _autoService.eliminaAuto(_auto!.targa);
  }

  /// Elimina un singolo intervento di lavoro.
  ///
  /// [id] L'identificativo del lavoro da eliminare.
  Future<void> eliminaLavoro(Lavoro lavoro) async {
    await _lavoroService.eliminaLavoro(lavoro.id!);
    if (lavoro.tipologia == TipologiaLavoro.ordinario)
      {
        await _lavoroService.eliminaScadenza(lavoro);
      }
    
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  /// Elimina un obbligo fiscale.
  ///
  /// [id] L'identificativo dell'obbligo da eliminare.
  Future<void> eliminaObbligo(Obbligo obbligo) async {
    await _obbligoService.eliminaObbligo(obbligo.id!);
    await _obbligoService.eliminaScadenza(obbligo);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  /// Salva le modifiche apportate ad un intervento di lavoro.
  ///
  /// [lavoro] L'oggetto lavoro aggiornato.
  Future<void> aggiornaLavoro(Lavoro lavoro) async {
    await _lavoroService.aggiornaLavoro(lavoro);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  /// Salva le modifiche apportate ad un obbligo.
  ///
  /// [obbligo] L'oggetto obbligo aggiornato.
  Future<void> aggiornaObbligo(Obbligo obbligo) async {
    await _obbligoService.aggiornaObbligo(obbligo);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  /// Restituisce il costo totale di tutti i lavori già eseguiti.
  double get totLavori => _lavori.where((l) => l.stato == StatoLavoro.eseguito).fold(0, (sum, l) => sum + (l.costo ?? 0));

  /// Restituisce la spesa totale per tutti gli obblighi fiscali pagati.
  double get totObblighi => _obblighi.where((o) => o.stato == StatoObbligo.pagato).fold(0, (sum, o) => sum + (o.costo ?? 0));

  /// Restituisce il totale complessivo delle spese (lavori eseguiti + obblighi pagati).
  double get totaleGenerale => totLavori + totObblighi;

  /// Restituisce la lista unificata delle spese sostenute (lavori ed obblighi) ordinata in ordine decrescente di data.
  List<dynamic> get itemsSpese {
    final l = _lavori.where((l) => l.stato == StatoLavoro.eseguito).toList();
    final o = _obblighi.where((o) => o.stato == StatoObbligo.pagato).toList();
    return [...l, ...o]..sort((a, b) {
      final da = a is Lavoro ? a.data : (a as Obbligo).dataPagamento ?? DateTime(1900);
      final db = b is Lavoro ? b.data : (b as Obbligo).dataPagamento ?? DateTime(1900);
      return db.compareTo(da);
    });
  }

  /// Restituisce il numero di scadenze (lavori da eseguire e obblighi da pagare) già trascorse.
  int get countScadute {
    final now = DateTime.now();
    int count = 0;
    for (var l in _lavori.where((l) => l.stato == StatoLavoro.daEseguire)) {
      final giorni = l.data.difference(now).inDays;
      final kmRimanenti = (l.chilometraggio ?? 0) - (_auto?.chilometraggio ?? 0);
      if (giorni < 0 || kmRimanenti < 0) count++;
    }
    for (var o in _obblighi.where((o) => o.stato == StatoObbligo.daPagare)) {
      if (o.dataScadenza != null) {
        final giorni = o.dataScadenza!.difference(now).inDays;
        if (giorni < 0) count++;
      }
    }
    return count;
  }

  /// Restituisce il numero di scadenze imminenti (entro 31 giorni o entro 1000 km).
  int get countImminenti {
    final now = DateTime.now();
    int count = 0;
    for (var l in _lavori.where((l) => l.stato == StatoLavoro.daEseguire)) {
      final giorni = l.data.difference(now).inDays;
      final kmRimanenti = (l.chilometraggio ?? 0) - (_auto?.chilometraggio ?? 0);
      final isScaduta = giorni < 0 || kmRimanenti < 0;
      if (!isScaduta && (giorni <= 31 || (kmRimanenti >= 0 && kmRimanenti <= 1000))) {
        count++;
      }
    }
    for (var o in _obblighi.where((o) => o.stato == StatoObbligo.daPagare)) {
      if (o.dataScadenza != null) {
        final giorni = o.dataScadenza!.difference(now).inDays;
        if (giorni >= 0 && giorni <= 31) count++;
      }
    }
    return count;
  }

  /// Restituisce il numero di scadenze regolari (future oltre i 31 giorni o 1000 km).
  int get countRegolari {
    final now = DateTime.now();
    int count = 0;
    for (var l in _lavori.where((l) => l.stato == StatoLavoro.daEseguire)) {
      final giorni = l.data.difference(now).inDays;
      final kmRimanenti = (l.chilometraggio ?? 0) - (_auto?.chilometraggio ?? 0);
      final isScaduta = giorni < 0 || kmRimanenti < 0;
      final isImminente = !isScaduta && (giorni <= 31 || (kmRimanenti >= 0 && kmRimanenti <= 1000));
      if (!isScaduta && !isImminente) count++;
    }
    for (var o in _obblighi.where((o) => o.stato == StatoObbligo.daPagare)) {
      if (o.dataScadenza != null) {
        final giorni = o.dataScadenza!.difference(now).inDays;
        if (giorni > 31) count++;
      }
    }
    return count;
  }

  // Restituisce la lista degli elementi da eseguire o pagare
  List<dynamic> get itemsScadenze {
    final l = _lavori.where((l) => l.stato == StatoLavoro.daEseguire).toList();
    final o = _obblighi.where((o) => o.stato == StatoObbligo.daPagare).toList();
    return [...l, ...o]..sort((a, b) {
      final da = a is Lavoro ? a.data : (a as Obbligo).dataScadenza ?? DateTime(2100);
      final db = b is Lavoro ? b.data : (b as Obbligo).dataScadenza ?? DateTime(2100);
      return da.compareTo(db);
    });
  }
}
