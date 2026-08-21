import 'package:flutter/material.dart';
import '../../models/utente.dart';
import '../../services/utente_service.dart';
import '../../services/session_manager.dart';

class RegistrazioneViewModel extends ChangeNotifier {
  // Servizi per utenti e sessione
  final _utenteService = UtenteService();
  final _sessionManager = SessionManager();

  // Stato di caricamento
  bool _loading = false;
  bool get loading => _loading;

  // Registra un nuovo utente e salva la sessione se l'operazione ha successo
  Future<bool> registra(Utente utente) async {
    _loading = true;
    notifyListeners();
    try {
      final esistenti = await _utenteService.getUtenti();
      // Verifica unicità dello username
      if (esistenti.any((u) => u.username == utente.username)) return false;
      
      // Salvataggio sul cloud e login automatico locale
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
