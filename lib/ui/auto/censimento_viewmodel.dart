import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/auto.dart';
import '../../models/ai_data_models.dart';
import '../../services/auto_service.dart';
import '../../services/api_services/auto_api_service.dart';

class CensimentoViewModel extends ChangeNotifier {
  final _autoService = AutoService();
  final _apiService = AutoApiService();

  bool _loading = false;
  bool get loading => _loading;

  SmartResult? _datiEstratti;
  SmartResult? get datiEstratti => _datiEstratti;

  Future<void> estraiDatiDaLibretto(Uint8List imageBytes) async {
    _loading = true;
    notifyListeners();
    try {
      _datiEstratti = await _apiService.extractCarData(imageBytes);
    } catch (e) {
      debugPrint('Errore estrazione libretto: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void resetDatiEstratti() {
    _datiEstratti = null;
    notifyListeners();
  }

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
