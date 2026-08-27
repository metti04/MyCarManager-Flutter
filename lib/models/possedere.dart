import 'enum.dart';

class Possedere {
  final String targaAuto;
  final String usernameUtente;
  final TipologiaGestione tipologia;

  const Possedere({required this.targaAuto, required this.usernameUtente, required this.tipologia});

  factory Possedere.fromJson(Map<String, dynamic> json) {
    return Possedere(
      targaAuto: json['targaAuto'] as String,
      usernameUtente: json['usernameUtente'] as String,
      tipologia: TipologiaGestioneX.fromDb(json['tipologia'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'targaAuto': targaAuto, 'usernameUtente': usernameUtente, 'tipologia': tipologia.dbValue};
  }
}
