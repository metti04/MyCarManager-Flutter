import 'package:flutter/material.dart';
import '../../models/auto.dart';
import '../../services/auto_service.dart';

class CensimentoViewModel extends ChangeNotifier {
  final _autoService = AutoService();

  bool _loading = false;
  bool get loading => _loading;

  Future<bool> salvaAuto(Auto auto) async {
    _loading = true;
    notifyListeners();
    try {
      final esistenti = await _autoService.getAllAuto();
      if (esistenti.any((a) => a.targa.toUpperCase() == auto.targa.toUpperCase())) return false;
      
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
