import '../models/obbligo.dart';
import '../models/enums.dart';
import 'supabase_service.dart';

class ObbligoService {
  final _client = SupabaseService.client;

  Future<List<Obbligo>> getObblighiByTarga(String targa) async {
    if (targa.isEmpty) return [];
    final data = await _client
        .from('obblighi')
        .select()
        .eq('targaAuto', targa.toUpperCase().trim())
        .order('targaAuto', ascending: false);
    return (data as List).map((e) => Obbligo.fromJson(e)).toList();
  }

  Future<List<Obbligo>> getSpeseByTarga(String targa) async {
    if (targa.isEmpty) return [];
    final data = await _client
        .from('obblighi')
        .select()
        .eq('targaAuto', targa.toUpperCase().trim())
        .eq('stato', StatoObbligo.pagato.dbValue)
        .order('targaAuto', ascending: false);
    return (data as List).map((e) => Obbligo.fromJson(e)).toList();
  }

  Future<List<Obbligo>> getScadenzeByTarga(String targa) async {
    if (targa.isEmpty) return [];
    final data = await _client
        .from('obblighi')
        .select()
        .eq('targaAuto', targa.toUpperCase().trim())
        .eq('stato', StatoObbligo.daPagare.dbValue)
        .order('targaAuto', ascending: false);
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
}
