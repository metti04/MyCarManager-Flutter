import 'package:flutter/material.dart';
import '../../models/auto.dart';
import '../../models/lavoro.dart';
import '../../models/obbligo.dart';
import '../../models/enum.dart';
import '../../services/auto_service.dart';
import '../../services/lavoro_service.dart';
import '../../services/obbligo_service.dart';

class SchedaAutoViewModel extends ChangeNotifier {
  // Servizi database per auto, lavori e obblighi fiscali
  final _autoService = AutoService();
  final _lavoroService = LavoroService();
  final _obbligoService = ObbligoService();

  // Dati del veicolo e liste correlate
  Auto? _auto;
  Auto? get auto => _auto;

  List<Lavoro> _lavori = [];
  List<Lavoro> get lavori => _lavori;
  List<Lavoro> get lavoriEseguiti => _lavori.where((l) => l.stato == StatoLavoro.eseguito).toList();

  List<Obbligo> _obblighi = [];
  List<Obbligo> get obblighi => _obblighi;
  List<Obbligo> get obblighiPagati => _obblighi.where((o) => o.stato == StatoObbligo.pagato).toList();

  // Stato di caricamento
  bool _loading = false;
  bool get loading => _loading;

  // Tab attualmente selezionata nella schermata (Storico/Scadenze/Dettagli)
  int _currentTab = 0;
  int get currentTab => _currentTab;

  // Cambia la tab visualizzata e notifica la UI
  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  // Carica tutte le informazioni di un veicolo data la targa
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

  // Attiva o disattiva il veicolo (es. se venduto o fermo)
  Future<void> toggleStato() async {
    if (_auto == null) return;
    if (_auto!.stato == StatoAuto.attivo) {
      await _autoService.setAutoInattiva(_auto!.targa);
    } else {
      await _autoService.setAutoAttiva(_auto!.targa);
    }
    await caricaDati(_auto!.targa);
  }

  // Aggiorna il chilometraggio attuale del veicolo
  Future<void> updateKm(int newKm) async {
    if (_auto == null) return;
    await _autoService.updateChilometraggio(_auto!.targa, newKm);
    await caricaDati(_auto!.targa);
  }

  // Rimuove il veicolo dal database
  Future<void> eliminaAuto() async {
    if (_auto == null) return;
    await _autoService.eliminaAuto(_auto!.targa);
  }

  // Elimina un singolo intervento di manutenzione
  Future<void> eliminaLavoro(int id) async {
    await _lavoroService.eliminaLavoro(id);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  // Elimina un obbligo fiscale
  Future<void> eliminaObbligo(int id) async {
    await _obbligoService.eliminaObbligo(id);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  // Salva le modifiche a un lavoro o ne inserisce uno nuovo
  Future<void> aggiornaLavoro(Lavoro lavoro) async {
    await _lavoroService.aggiornaLavoro(lavoro);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  // Salva le modifiche a un obbligo o ne inserisce uno nuovo
  Future<void> aggiornaObbligo(Obbligo obbligo) async {
    await _obbligoService.aggiornaObbligo(obbligo);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  // Getters per le statistiche delle spese
  double get totLavori => _lavori.where((l) => l.stato == StatoLavoro.eseguito).fold(0, (sum, l) => sum + (l.costo ?? 0));
  double get totObblighi => _obblighi.where((o) => o.stato == StatoObbligo.pagato).fold(0, (sum, o) => sum + (o.costo ?? 0));
  double get totaleGenerale => totLavori + totObblighi;

  // Restituisce una lista unificata di lavori e obblighi ordinata per data decrescente
  List<dynamic> get itemsSpese {
    final l = _lavori.where((l) => l.stato == StatoLavoro.eseguito).toList();
    final o = _obblighi.where((o) => o.stato == StatoObbligo.pagato).toList();
    return [...l, ...o]..sort((a, b) {
      final da = a is Lavoro ? a.data : (a as Obbligo).dataPagamento ?? DateTime(1900);
      final db = b is Lavoro ? b.data : (b as Obbligo).dataPagamento ?? DateTime(1900);
      return db.compareTo(da);
    });
  }

  // Getters per il monitoraggio delle scadenze
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
