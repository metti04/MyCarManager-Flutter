enum Alimentazione { benz, gasol, elettrico, elettricoBev, ibrido, gpl, metano, idrogeno, flex }

extension AlimentazioneX on Alimentazione {
  String get dbValue {
    switch (this) {
      case Alimentazione.benz: return 'BENZ';
      case Alimentazione.gasol: return 'GASOL';
      case Alimentazione.elettrico: return 'ELETTRICO';
      case Alimentazione.elettricoBev: return 'ELETTRICO_BEV';
      case Alimentazione.ibrido: return 'IBRIDO';
      case Alimentazione.gpl: return 'GPL';
      case Alimentazione.metano: return 'METANO';
      case Alimentazione.idrogeno: return 'IDROGENO';
      case Alimentazione.flex: return 'FLEX';
    }
  }

  static Alimentazione fromDb(String value) {
    return Alimentazione.values.firstWhere(
      (e) => e.dbValue.toLowerCase() == value.toLowerCase(),
      orElse: () => Alimentazione.benz,
    );
  }
}

enum TipologiaLavoro { ordinario, straordinario }

extension TipologiaLavoroX on TipologiaLavoro {
  String get dbValue => this == TipologiaLavoro.ordinario ? 'ORDINARIO' : 'STRAORDINARIO';
  static TipologiaLavoro fromDb(String value) =>
      value.toUpperCase() == 'ORDINARIO' ? TipologiaLavoro.ordinario : TipologiaLavoro.straordinario;
}

enum TipologiaGestione { possessore, nonPossessore }

extension TipologiaGestioneX on TipologiaGestione {
  String get dbValue => this == TipologiaGestione.possessore ? 'POSSESSORE' : 'NON_POSSESSORE';
  static TipologiaGestione fromDb(String value) =>
      value.toUpperCase() == 'POSSESSORE' ? TipologiaGestione.possessore : TipologiaGestione.nonPossessore;
}

enum StatoLavoro { eseguito, daEseguire }

extension StatoLavoroX on StatoLavoro {
  String get dbValue => this == StatoLavoro.eseguito ? 'ESEGUITO' : 'DA_ESEGUIRE';
  static StatoLavoro fromDb(String value) =>
      value.toUpperCase() == 'ESEGUITO' ? StatoLavoro.eseguito : StatoLavoro.daEseguire;
}

enum StatoAuto { attivo, inattivo }

extension StatoAutoX on StatoAuto {
  String get dbValue => this == StatoAuto.attivo ? 'ATTIVO' : 'INATTIVO';
  static StatoAuto fromDb(String value) =>
      value.toUpperCase() == 'ATTIVO' ? StatoAuto.attivo : StatoAuto.inattivo;
}

enum StatoObbligo { pagato, daPagare }

extension StatoObbligoX on StatoObbligo {
  String get dbValue => this == StatoObbligo.pagato ? 'PAGATO' : 'DA_PAGARE';
  static StatoObbligo fromDb(String value) =>
      value.toUpperCase() == 'PAGATO' ? StatoObbligo.pagato : StatoObbligo.daPagare;
}
