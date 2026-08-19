import '../models/lavoro.dart';
import '../models/enums.dart';
import 'supabase_service.dart';

class LavoroService {
  final _client = SupabaseService.client;

  Future<List<Lavoro>> getLavoriByTarga(String targa) async {
    if (targa.isEmpty) return [];
    final data = await _client
        .from('lavori')
        .select()
        .eq('targaAuto', targa.toUpperCase().trim())
        .order('targaAuto', ascending: false);
    return (data as List).map((e) => Lavoro.fromJson(e)).toList();
  }

  Future<List<Lavoro>> getSpeseByTarga(String targa) async {
    if (targa.isEmpty) return [];
    final data = await _client
        .from('lavori')
        .select()
        .eq('targaAuto', targa.toUpperCase().trim())
        .eq('stato', StatoLavoro.eseguito.dbValue)
        .order('targaAuto', ascending: false);
    return (data as List).map((e) => Lavoro.fromJson(e)).toList();
  }

  Future<List<Lavoro>> getScadenzeByTarga(String targa) async {
    if (targa.isEmpty) return [];
    final data = await _client
        .from('lavori')
        .select()
        .eq('targaAuto', targa.toUpperCase().trim())
        .eq('tipologia', TipologiaLavoro.ordinario.dbValue)
        .eq('stato', StatoLavoro.daEseguire.dbValue)
        .order('targaAuto', ascending: false);
    return (data as List).map((e) => Lavoro.fromJson(e)).toList();
  }

  Future<void> inserisciLavoro(Lavoro lavoro) async {
    await _client.from('lavori').insert(lavoro.toJson());
  }

  Future<void> aggiornaLavoro(Lavoro lavoro) async {
    await _client.from('lavori').update(lavoro.toJson()).eq('ID', lavoro.id!);
  }

  Future<void> eliminaLavoro(int id) async {
    await _client.from('lavori').delete().eq('ID', id);
  }
}
