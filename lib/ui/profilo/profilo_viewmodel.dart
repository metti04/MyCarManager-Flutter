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

  Future<void> caricaDati(String username) async {
    _loading = true;
    notifyListeners();

    try {
      _utente = await _utenteService.getUtente(username);
    } catch (e) {
      debugPrint('Errore caricamento profilo: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {}
    await _sessionManager.clearSession();
  }
}
