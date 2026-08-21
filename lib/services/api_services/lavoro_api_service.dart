import 'dart:convert';
import 'dart:typed_data';
import '../../models/ai_data_models.dart';
import 'gemini_client.dart';

// Servizio per l'estrazione di dati da fatture e ricevute di lavori meccanici.
class LavoroApiService {
  static const String _invoicePrompt = """
    Analizza questa immagine di una fattura o ricevuta fiscale di lavori meccanici.
    Estrai i seguenti campi e restituiscili SOLO in formato JSON:
    {
      "targa": "targa del veicolo, se presente",
      "nome": "nome/descrizione breve dell'operazione (es. Tagliando, Cambio Gomme, Revisione)",
      "costo": "importo totale, solo numero con punto decimale, senza simbolo euro",
      "data_pagamento": "data di esecuzione o pagamento, formato gg/mm/aaaa",
      "chilometraggio": "chilometraggio del veicolo segnato in fattura, solo numeri",
      "descrizione": "elenco sintetico dei lavori svolti o note aggiuntive"
    }
    Se un campo non è presente o leggibile, scrivi null.
    Non aggiungere altro testo: manda solo l'oggetto JSON puro.
  """;

  // Esegue l'estrazione dei dati della fattura dall'immagine fornita.
  Future<InvoiceResult?> extractWorkData(Uint8List imageBytes) async {
    final response = await GeminiClient.generateContent(imageBytes, _invoicePrompt);
    if (response == null) return null;
    return _parseInvoiceJson(response);
  }

  // Parsing del JSON per popolare il modello InvoiceResult dedicato ai lavori.
  InvoiceResult _parseInvoiceJson(String jsonStr) {
    final cleanJson = jsonStr.replaceAll("```json", "").replaceAll("```", "").trim();
    try {
      final json = jsonDecode(cleanJson);
      return InvoiceResult(
        targa: json['targa'],
        nome: json['nome'],
        costo: json['costo']?.toString(),
        dataPagamento: json['data_pagamento'],
        chilometraggio: json['chilometraggio']?.toString(),
        descrizione: json['descrizione'],
      );
    } catch (e) {
      return InvoiceResult();
    }
  }
}
