import 'package:flutter/material.dart';
import '../../services/utente_service.dart';
import '../../services/session_manager.dart';

class LoginViewModel extends ChangeNotifier {
  // Servizi per la gestione degli utenti e della sessione locale
  final _utenteService = UtenteService();
  final _sessionManager = SessionManager();

  bool _loading = false;
  bool get loading => _loading;

  // Gestione dei messaggi di errore
  String? _error;
  String? get error => _error;

  // Esegue il login tramite email e password
  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _error = 'Tutti i campi sono obbligatori';
      notifyListeners();
      return null;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Verifica le credenziali nel database Supabase
      final utente = await _utenteService.getUtenteByEmail(email.trim());
      if (utente != null && utente.password == password) {
        // Salva l'intero oggetto utente nella sessione
        await _sessionManager.saveUser(utente);
        _loading = false;
        notifyListeners();
        return utente.username;
      } else {
        _error = 'Email o Password errati';
        _loading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Accesso fallito: $e';
      _loading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
