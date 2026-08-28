import 'package:flutter/material.dart';
import 'package:my_car_manager/services/possedere_service.dart';
import '../../models/auto.dart';
import '../../models/enum.dart';
import '../../models/possedere.dart';
import '../../services/auto_service.dart';

class CensimentoViewModel extends ChangeNotifier {
  final _autoService = AutoService();
  final _possedereService = PossedereService();

  bool _loading = false;
  bool get loading => _loading;

  Future<bool> salvaAuto(Auto auto, String username) async {
    _loading = true;
    notifyListeners();
    try {
      final esistenti = await _autoService.getAllAuto();
      if (esistenti.any((a) => a.targa.toUpperCase() == auto.targa.toUpperCase())) return false;
      
      await _autoService.inserisciAuto(auto);
      Possedere possedere = Possedere(targaAuto: auto.targa.toUpperCase(), usernameUtente: username, tipologia: TipologiaGestione.possessore);
      await _possedereService.insertPossedere(possedere);
      return true;
    } catch (e) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
