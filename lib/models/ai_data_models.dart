// Tipi di dati che il sistema è in grado di identificare nel libretto di circolazione.
enum DataType {
  plate,
  date,
  brand,
  model,
  vin,
  displacement,
  power,
  fuel,
  engine
}

// Singolo elemento di dato estratto dall'IA.
class ExtractedItem {
  final DataType type;
  final String value;

  ExtractedItem(this.type, this.value);
}

// Risultato dell'estrazione dei dati dal libretto.
class SmartResult {
  final String fullText;
  final List<ExtractedItem> extractedData;

  SmartResult(this.fullText, this.extractedData);
}

// Risultato dell'estrazione di una fattura o ricevuta (Lavori/Obblighi).
class InvoiceResult {
  final String? targa;
  final String? nome;
  final String? costo;
  final String? dataScadenza;
  final String? dataPagamento;
  final String? chilometraggio;
  final String? descrizione;

  InvoiceResult({
    this.targa,
    this.nome,
    this.costo,
    this.dataScadenza,
    this.dataPagamento,
    this.chilometraggio,
    this.descrizione,
  });
}
