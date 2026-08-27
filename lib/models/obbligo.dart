import 'enum.dart';

class Obbligo {
  final int? id;
  final String? nome;
  final DateTime? dataPagamento;
  final double? costo;
  final DateTime? dataScadenza;
  final String? pathDocumento;
  final StatoObbligo? stato;
  final String? targaAuto;

  const Obbligo({
    this.id,
    this.nome,
    this.dataPagamento,
    this.costo,
    this.dataScadenza,
    this.pathDocumento,
    this.stato,
    this.targaAuto,
  });

  factory Obbligo.fromJson(Map<String, dynamic> json) {
    return Obbligo(
      id: json['ID'] as int?,
      nome: json['nome'] as String?,
      dataPagamento: json['dataPagamento'] != null ? DateTime.parse(json['dataPagamento']) : null,
      costo: (json['costo'] as num?)?.toDouble(),
      dataScadenza: json['dataScadenza'] != null ? DateTime.parse(json['dataScadenza']) : null,
      pathDocumento: json['pathDocumento'] as String?,
      stato: json['stato'] != null ? StatoObbligoX.fromDb(json['stato'] as String) : null,
      targaAuto: json['targaAuto'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'ID': id,
      'nome': nome,
      'dataPagamento': dataPagamento?.toIso8601String().split('T').first,
      'costo': costo,
      'dataScadenza': dataScadenza?.toIso8601String().split('T').first,
      'pathDocumento': pathDocumento,
      'stato': stato?.dbValue,
      'targaAuto': targaAuto,
    };
  }
}
