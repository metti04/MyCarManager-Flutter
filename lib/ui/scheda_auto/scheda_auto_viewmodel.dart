import 'package:flutter/material.dart';
import '../../models/auto.dart';
import '../../models/lavoro.dart';
import '../../models/obbligo.dart';
import '../../models/enums.dart';
import '../../services/auto_service.dart';
import '../../services/lavoro_service.dart';
import '../../services/obbligo_service.dart';

class SchedaAutoViewModel extends ChangeNotifier {
  final _autoService = AutoService();
  final _lavoroService = LavoroService();
  final _obbligoService = ObbligoService();

  Auto? _auto;
  Auto? get auto => _auto;

  List<Lavoro> _lavori = [];
  List<Lavoro> get lavori => _lavori;

  List<Obbligo> _obblighi = [];
  List<Obbligo> get obblighi => _obblighi;

  bool _loading = false;
  bool get loading => _loading;

  int _currentTab = 0;
  int get currentTab => _currentTab;

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

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

  Future<void> toggleStato() async {
    if (_auto == null) return;
    if (_auto!.stato == StatoAuto.attivo) {
      await _autoService.setAutoInattiva(_auto!.targa);
    } else {
      await _autoService.setAutoAttiva(_auto!.targa);
    }
    await caricaDati(_auto!.targa);
  }

  Future<void> updateKm(int newKm) async {
    if (_auto == null) return;
    await _autoService.updateChilometraggio(_auto!.targa, newKm);
    await caricaDati(_auto!.targa);
  }

  Future<void> eliminaAuto() async {
    if (_auto == null) return;
    await _autoService.eliminaAuto(_auto!.targa);
  }

  Future<void> eliminaLavoro(int id) async {
    await _lavoroService.eliminaLavoro(id);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  Future<void> eliminaObbligo(int id) async {
    await _obbligoService.eliminaObbligo(id);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  Future<void> aggiornaLavoro(Lavoro lavoro) async {
    await _lavoroService.aggiornaLavoro(lavoro);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  Future<void> aggiornaObbligo(Obbligo obbligo) async {
    await _obbligoService.aggiornaObbligo(obbligo);
    if (_auto != null) await caricaDati(_auto!.targa);
  }

  // Spese getters
  double get totLavori => _lavori.where((l) => l.stato == StatoLavoro.eseguito).fold(0, (sum, l) => sum + (l.costo ?? 0));
  double get totObblighi => _obblighi.where((o) => o.stato == StatoObbligo.pagato).fold(0, (sum, o) => sum + (o.costo ?? 0));
  double get totaleGenerale => totLavori + totObblighi;

  List<dynamic> get itemsSpese {
    final l = _lavori.where((l) => l.stato == StatoLavoro.eseguito).toList();
    final o = _obblighi.where((o) => o.stato == StatoObbligo.pagato).toList();
    return [...l, ...o]..sort((a, b) {
      final da = a is Lavoro ? a.data : (a as Obbligo).dataPagamento ?? DateTime(1900);
      final db = b is Lavoro ? b.data : (b as Obbligo).dataPagamento ?? DateTime(1900);
      return db.compareTo(da);
    });
  }

  // Scadenze getters
  int get countScadute {
    final now = DateTime.now();
    int count = 0;
    for (var l in _lavori.where((l) => l.stato == StatoLavoro.daEseguire)) {
      if (l.data.isBefore(now)) count++;
    }
    for (var o in _obblighi.where((o) => o.stato == StatoObbligo.daPagare)) {
      if (o.dataScadenza != null && o.dataScadenza!.isBefore(now)) count++;
    }
    return count;
  }

  int get countImminenti {
    final now = DateTime.now();
    int count = 0;
    for (var l in _lavori.where((l) => l.stato == StatoLavoro.daEseguire)) {
      if (!l.data.isBefore(now) && l.data.difference(now).inDays <= 31) count++;
    }
    for (var o in _obblighi.where((o) => o.stato == StatoObbligo.daPagare)) {
      if (o.dataScadenza != null && !o.dataScadenza!.isBefore(now) && o.dataScadenza!.difference(now).inDays <= 31) count++;
    }
    return count;
  }

  List<dynamic> get itemsScadenze {
    final l = _lavori.where((l) => l.stato == StatoLavoro.daEseguire).toList();
    final o = _obblighi.where((o) => o.stato == StatoObbligo.daPagare).toList();
    return [...l, ...o];
  }
}
