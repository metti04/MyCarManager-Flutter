import 'package:flutter/material.dart';
import '../../services/utente_service.dart';
import '../../services/session_manager.dart';
import '../../models/utente.dart';

class LoginViewModel extends ChangeNotifier {
  final _utenteService = UtenteService();
  final _sessionManager = SessionManager();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

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
      final utente = await _utenteService.getUtenteByEmail(email.trim());
      if (utente != null && utente.password == password) {
        await _sessionManager.saveSession(utente.username);
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

  Future<String?> loginWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulazione Google Login (in Kotlin usava CredentialManager)
      // In un'app reale qui servirebbe il pacchetto google_sign_in
      await Future.delayed(const Duration(seconds: 1));
      
      const simulatedEmail = "google.user@example.com";
      const simulatedName = "Google";
      const simulatedSurname = "User";
      
      var utente = await _utenteService.getUtenteByEmail(simulatedEmail);
      
      if (utente == null) {
        final baseUsername = simulatedEmail.split("@")[0];
        String finalUsername = baseUsername;
        int counter = 1;
        while (await _utenteService.getUtente(finalUsername) != null) {
          finalUsername = "$baseUsername$counter";
          counter++;
        }

        utente = Utente(
          username: finalUsername,
          password: "changePassword", // Placeholder come in Kotlin
          email: simulatedEmail,
          nome: simulatedName,
          cognome: simulatedSurname,
          dataDiNascita: DateTime(1900, 1, 1),
        );
        await _utenteService.inserisciUtente(utente);
      }

      await _sessionManager.saveSession(utente.username);
      _loading = false;
      notifyListeners();
      return utente.username;
    } catch (e) {
      _error = 'Errore Google Login: $e';
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
