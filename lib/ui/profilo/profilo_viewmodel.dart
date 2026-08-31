import 'package:flutter/material.dart';
import '../../models/utente.dart';
import '../../services/utente_service.dart';
import '../../services/session_manager.dart';
import '../../services/supabase_service.dart';

class ProfiloViewModel extends ChangeNotifier {
  final _utenteService = UtenteService();
  final _sessionManager = SessionManager();

  Utente? _utente;
  Utente? get utente => _utente;

  bool _loading = false;
  bool get loading => _loading;

  Future<void> caricaDati() async {
    // 1. Carichiamo subito dalla sessione locale per velocità
    _utente = await _sessionManager.getUser();
    if (_utente != null) {
      notifyListeners();
    }

    // 2. Facciamo comunque un check sul DB per aggiornare eventuali modifiche
    final username = _utente?.username ?? await _sessionManager.getUsername();
    if (username == null) return;

    _loading = true;
    notifyListeners();

    try {
      final freshUser = await _utenteService.getUtente(username);
      if (freshUser != null) {
        _utente = freshUser;
        // Aggiorniamo la cache
        await _sessionManager.saveUser(freshUser);
      }
    } catch (e) {
      debugPrint('Errore caricamento profilo: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> eliminaAccount() async {
    final username = _utente?.username ?? await _sessionManager.getUsername();
    if (username != null) {
      _loading = true;
      notifyListeners();

      try {
        await _utenteService.eliminaUtente(username);
      } catch (e) {
        debugPrint('Errore eliminazione account: $e');
      }
    }

    await logout();
    _loading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {}
    await _sessionManager.clearSession();
  }
}
