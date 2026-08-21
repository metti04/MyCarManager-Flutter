import 'dart:convert';
import 'dart:typed_data';
import '../../models/ai_data_models.dart';
import 'gemini_client.dart';

// Servizio dedicato all'analisi di documenti relativi a Bollo e Assicurazione in Flutter.
class ObbligoApiService {
  static const String _obbligoPrompt = """
    Analizza questa immagine di un bollo auto o assicurazione.
    Estrai i seguenti campi e restituiscili SOLO in formato JSON:
    {
      "targa": "targa del veicolo, se presente",
      "nome": "tipo di obbligo (es. Bollo, Assicurazione)",
      "costo": "importo totale, solo numero con punto decimale, senza simbolo euro",
      "data_scadenza": "data di scadenza, formato gg/mm/aaaa",
      "data_pagamento": "data di pagamento, formato gg/mm/aaaa"
    }
    Se un campo non è presente o leggibile, scrivi null.
    Non aggiungere altro testo: manda solo l'oggetto JSON puro.
  """;

  // Analizza l'immagine dell'obbligo e ne estrae i dati principali.
  Future<InvoiceResult?> extractObbligoData(Uint8List imageBytes) async {
    final response = await GeminiClient.generateContent(imageBytes, _obbligoPrompt);
    if (response == null) return null;
    return _parseObbligoJson(response);
  }

  // Parsing della risposta IA in un oggetto InvoiceResult.
  InvoiceResult _parseObbligoJson(String jsonStr) {
    final cleanJson = jsonStr.replaceAll("```json", "").replaceAll("```", "").trim();
    try {
      final json = jsonDecode(cleanJson);
      return InvoiceResult(
        targa: json['targa'],
        nome: json['nome'],
        costo: json['costo']?.toString(),
        dataScadenza: json['data_scadenza'],
        dataPagamento: json['data_pagamento'],
      );
    } catch (e) {
      return InvoiceResult();
    }
  }
}
