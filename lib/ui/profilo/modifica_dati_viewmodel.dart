import 'package:flutter/material.dart';
import '../../models/utente.dart';
import '../../services/utente_service.dart';
import '../../services/session_manager.dart';

class ModificaDatiViewModel extends ChangeNotifier {
  final _utenteService = UtenteService();
  final _sessionManager = SessionManager();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Utente? _utente;
  Utente? get utente => _utente;

  Future<void> caricaDati(String username) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _utente = await _utenteService.getUtente(username);
    } catch (e) {
      _error = "Errore nel caricamento dati: $e";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> salva(Utente nuovoUtente) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final vecchioUsername = _utente?.username;

      // Se l'username è cambiato, controlliamo che non sia già preso
      if (vecchioUsername != null && vecchioUsername != nuovoUtente.username) {
        final esistente = await _utenteService.getUtente(nuovoUtente.username);
        if (esistente != null) {
          _error = "Lo username '${nuovoUtente.username}' è già in uso";
          _loading = false;
          notifyListeners();
          return false;
        }
      }

      await _utenteService.aggiornaUtente(nuovoUtente, vecchioUsername: vecchioUsername);
      
      // Aggiorniamo la sessione locale
      await _sessionManager.saveUser(nuovoUtente);
      
      return true;
    } catch (e) {
      _error = "Errore durante il salvataggio: $e";
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
