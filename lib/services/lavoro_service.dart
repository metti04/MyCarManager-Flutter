import '../models/enum.dart';
import '../models/lavoro.dart';
import 'supabase_service.dart';

class LavoroService {
  final _client = SupabaseService.client;

  Future<List<Lavoro>> getLavoriByTarga(String targa) async {
    if (targa.isEmpty) return [];
    final data = await _client
        .from('lavori')
        .select()
        .eq('targaAuto', targa.toUpperCase().trim())
        .order('data', ascending: false);
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

  Future<void> eliminaScadenza(Lavoro lavoro) async {
    await _client.from('lavori').delete().eq('targaAuto', lavoro.targaAuto).eq('nome', lavoro.nome)
        .eq('tipologia', lavoro.tipologia.dbValue).eq('descrizione', lavoro.descrizione!).eq('intervalloTempo', lavoro.intervalloTempo!)
        .eq('intervalloKm', lavoro.intervalloKm!).eq('stato', StatoLavoro.daEseguire.dbValue);
  }
}
