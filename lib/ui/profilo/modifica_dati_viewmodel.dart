import 'package:flutter/material.dart';
import '../../models/utente.dart';
import '../../services/utente_service.dart';

class ModificaDatiViewModel extends ChangeNotifier {
  final _utenteService = UtenteService();

  bool _loading = false;
  bool get loading => _loading;

  Utente? _utente;
  Utente? get utente => _utente;

  Future<void> caricaDati(String username) async {
    _loading = true;
    notifyListeners();
    _utente = await _utenteService.getUtente(username);
    _loading = false;
    notifyListeners();
  }

  Future<bool> salva(Utente utente) async {
    _loading = true;
    notifyListeners();
    try {
      await _utenteService.aggiornaUtente(utente);
      return true;
    } catch (e) {
      debugPrint('Errore salvataggio dati: $e');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
