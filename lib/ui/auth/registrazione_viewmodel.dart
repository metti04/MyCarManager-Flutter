import 'package:flutter/material.dart';
import '../../models/utente.dart';
import '../../services/utente_service.dart';
import '../../services/session_manager.dart';

class RegistrazioneViewModel extends ChangeNotifier {
  final _utenteService = UtenteService();
  final _sessionManager = SessionManager();

  bool _loading = false;
  bool get loading => _loading;

  Future<bool> registra(Utente utente) async {
    _loading = true;
    notifyListeners();
    try {
      final esistenti = await _utenteService.getUtenti();
      if (esistenti.any((u) => u.username == utente.username)) return false;
      await _utenteService.inserisciUtente(utente);
      await _sessionManager.saveSession(utente.username);
      return true;
    } catch (e) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
