import 'dart:convert';
import 'dart:typed_data';
import '../../models/ai_data_models.dart';
import 'gemini_client.dart';

// Servizio specifico per l'estrazione dati dal Libretto di Circolazione in Flutter.
class AutoApiService {
  static const String _librettoPrompt = """
    Analizza questa immagine di un Libretto di Circolazione italiano (Carta di Circolazione).
    Estrai i seguenti campi e restituiscili SOLO in formato JSON:
    {
      "targa": "campo (A)",
      "marca": "campo (D.1)",
      "modello": "campo (D.3)",
      "cilindrata": "campo (P.1)",
      "data_immatricolazione": "campo (B)",
      "potenza_kw": "campo (P.2)",
      "codice_motore": "campo (P.5)",
      "alimentazione": "campo (P.3)",
      "telaio": "campo (E)"
    }
    Se un campo non è presente o leggibile, scrivi null.
    Non aggiungere altro testo: manda solo l'oggetto JSON puro.
  """;

  // Analizza l'immagine del libretto e restituisce i dati strutturati.
  Future<SmartResult?> extractCarData(Uint8List imageBytes) async {
    final response = await GeminiClient.generateContent(imageBytes, _librettoPrompt);
    if (response == null) return null;
    return _parseLibrettoJson(response);
  }

  // Converte la stringa JSON ricevuta dall'IA in un oggetto SmartResult.
  SmartResult _parseLibrettoJson(String jsonStr) {
    final cleanJson = jsonStr.replaceAll("```json", "").replaceAll("```", "").trim();
    final items = <ExtractedItem>[];
    String fullText = "";

    try {
      final json = jsonDecode(cleanJson);

      void addIfPresent(String key, DataType type) {
        if (json[key] != null) {
          final value = json[key].toString();
          items.add(ExtractedItem(type, value));
          fullText += "$key: $value\n";
        }
      }

      addIfPresent("targa", DataType.plate);
      addIfPresent("marca", DataType.brand);
      addIfPresent("modello", DataType.model);
      addIfPresent("cilindrata", DataType.displacement);
      addIfPresent("data_immatricolazione", DataType.date);
      addIfPresent("potenza_kw", DataType.power);
      addIfPresent("codice_motore", DataType.engine);
      addIfPresent("alimentazione", DataType.fuel);
      addIfPresent("telaio", DataType.vin);

    } catch (e) {
      // Errore parsing
    }

    return SmartResult(fullText.trim(), items);
  }
}
