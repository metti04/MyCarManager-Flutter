import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

// Client centralizzato per la comunicazione con l'API Google Gemini in Flutter.
class GeminiClient {
  static const String _apiKey = "INSERISCI_QUI_LA_TUA_CHIAVE"; // TODO: Spostare in configurazione sicura
  static const String _model = "gemini-1.5-flash";
  static const String _endpoint = "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent";

  // Invia un'immagine (come bytes) e un prompt a Gemini e restituisce la risposta testuale.
  static Future<String?> generateContent(Uint8List imageBytes, String prompt) async {
    if (_apiKey.isEmpty) return null;

    try {
      final base64Image = base64Encode(imageBytes);

      final url = Uri.parse("$_endpoint?key=$_apiKey");
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {"inline_data": {"mime_type": "image/jpeg", "data": base64Image}},
              {"text": prompt}
            ]
          }
        ]
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      return null;
    }
  }
}
