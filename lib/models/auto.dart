import 'enum.dart';

class Auto {
  final String targa;
  final String modello;
  final String marchio;
  final String vin;
  final DateTime dataImmatricolazione;
  final int cilindrata;
  final Alimentazione alimentazione;
  final String pathLibretto;
  final String identificatoreMotore;
  final int potenza;
  final StatoAuto stato;
  final int chilometraggio;

  const Auto({
    required this.targa,
    required this.modello,
    required this.marchio,
    required this.vin,
    required this.dataImmatricolazione,
    required this.cilindrata,
    required this.alimentazione,
    required this.pathLibretto,
    required this.identificatoreMotore,
    required this.potenza,
    required this.stato,
    required this.chilometraggio,
  });

  String get nomeCompleto => '$marchio $modello'.trim();

  factory Auto.fromJson(Map<String, dynamic> json) {
    return Auto(
      targa: json['targa'] as String,
      modello: json['modello'] as String,
      marchio: json['marchio'] as String,
      vin: json['vin'] as String,
      dataImmatricolazione: DateTime.parse(json['dataImmatricolazione'] as String),
      cilindrata: json['cilindrata'] as int,
      alimentazione: AlimentazioneX.fromDb(json['alimentazione'] as String),
      pathLibretto: json['pathLibretto'] as String? ?? '',
      identificatoreMotore: json['identificatoreMotore'] as String,
      potenza: json['potenza'] as int,
      stato: StatoAutoX.fromDb(json['stato'] as String),
      chilometraggio: json['chilometraggio'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targa': targa,
      'modello': modello,
      'marchio': marchio,
      'vin': vin,
      'dataImmatricolazione': dataImmatricolazione.toIso8601String().split('T').first,
      'cilindrata': cilindrata,
      'alimentazione': alimentazione.dbValue,
      'pathLibretto': pathLibretto,
      'identificatoreMotore': identificatoreMotore,
      'potenza': potenza,
      'stato': stato.dbValue,
      'chilometraggio': chilometraggio,
    };
  }
}
