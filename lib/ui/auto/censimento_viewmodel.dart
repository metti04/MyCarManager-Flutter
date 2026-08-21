import 'package:flutter/material.dart';
import '../../models/auto.dart';
import '../../services/auto_service.dart';

class CensimentoViewModel extends ChangeNotifier {
  // Servizio per la gestione dei veicoli nel database
  final _autoService = AutoService();

  // Stato di caricamento per l'UI
  bool _loading = false;
  bool get loading => _loading;

  // Salva una nuova auto verificando prima che la targa non sia già presente
  Future<bool> salvaAuto(Auto auto) async {
    _loading = true;
    notifyListeners();
    try {
      final esistenti = await _autoService.getAllAuto();
      // Controllo duplicati basato sulla targa
      if (esistenti.any((a) => a.targa == auto.targa)) return false;
      
      // Inserimento nel database Supabase
      await _autoService.inserisciAuto(auto);
      return true;
    } catch (e) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
