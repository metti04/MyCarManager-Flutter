import 'enum.dart';

class Lavoro {
  final int? id;
  final String nome;
  final TipologiaLavoro tipologia;
  final int? chilometraggio;
  final DateTime data;
  final String? descrizione;
  final StatoLavoro stato;
  final double? costo;
  final String? pathDocumento;
  final int? intervalloTempo;
  final int? intervalloKm;
  final String targaAuto;

  const Lavoro({
    this.id,
    required this.nome,
    required this.tipologia,
    this.chilometraggio,
    required this.data,
    this.descrizione,
    required this.stato,
    this.costo,
    this.pathDocumento,
    this.intervalloTempo,
    this.intervalloKm,
    required this.targaAuto,
  });

  factory Lavoro.fromJson(Map<String, dynamic> json) {
    return Lavoro(
      id: json['ID'] as int?,
      nome: json['nome'] as String,
      tipologia: TipologiaLavoroX.fromDb(json['tipologia'] as String),
      chilometraggio: json['chilometraggio'] as int?,
      data: DateTime.parse(json['data'] as String),
      descrizione: json['descrizione'] as String?,
      stato: StatoLavoroX.fromDb(json['stato'] as String),
      costo: (json['costo'] as num?)?.toDouble(),
      pathDocumento: json['pathDocumento'] as String?,
      intervalloTempo: json['intervalloTempo'] as int?,
      intervalloKm: json['intervalloKm'] as int?,
      targaAuto: json['targaAuto'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'ID': id,
      'nome': nome,
      'tipologia': tipologia.dbValue,
      'chilometraggio': chilometraggio,
      'data': data.toIso8601String().split('T').first,
      'descrizione': descrizione,
      'stato': stato.dbValue,
      'costo': costo,
      'pathDocumento': pathDocumento,
      'intervalloTempo': intervalloTempo,
      'intervalloKm': intervalloKm,
      'targaAuto': targaAuto,
    };
  }
}
