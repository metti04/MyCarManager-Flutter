import '../models/enum.dart';
import '../models/obbligo.dart';
import 'supabase_service.dart';

class ObbligoService {
  final _client = SupabaseService.client;

  Future<List<Obbligo>> getObblighiByTarga(String targa) async {
    if (targa.isEmpty) return [];
    final data = await _client
        .from('obblighi')
        .select()
        .eq('targaAuto', targa.toUpperCase().trim())
        .order('dataScadenza', ascending: false);
    return (data as List).map((e) => Obbligo.fromJson(e)).toList();
  }

  Future<void> inserisciObbligo(Obbligo obbligo) async {
    await _client.from('obblighi').insert(obbligo.toJson());
  }

  Future<void> aggiornaObbligo(Obbligo obbligo) async {
    await _client.from('obblighi').update(obbligo.toJson()).eq('ID', obbligo.id!);
  }

  Future<void> eliminaObbligo(int id) async {
    await _client.from('obblighi').delete().eq('ID', id);
  }

  Future<void> eliminaScadenza(Obbligo obbligo) async {
    await _client.from('obblighi').delete().eq('targaAuto', obbligo.targaAuto!).eq('dataScadenza', obbligo.dataScadenza!)
    .eq('costo', obbligo.costo!).eq('nome', obbligo.nome!).eq('stato', StatoObbligo.daPagare.dbValue);
  }
}
