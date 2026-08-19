import '../models/auto.dart';
import '../models/enums.dart';
import 'supabase_service.dart';

class AutoService {
  final _client = SupabaseService.client;

  Future<List<Auto>> getAllAuto() async {
    final data = await _client.from('auto').select();
    return (data as List).map((e) => Auto.fromJson(e)).toList();
  }

  Future<Auto?> getAuto(String targa) async {
    final data = await _client.from('auto').select().eq('targa', targa).maybeSingle();
    return data == null ? null : Auto.fromJson(data);
  }

  Future<List<Auto>> getAutoByTarghe(List<String> targhe) async {
    if (targhe.isEmpty) return [];
    final data = await _client.from('auto').select().inFilter('targa', targhe);
    return (data as List).map((e) => Auto.fromJson(e)).toList();
  }

  Future<void> inserisciAuto(Auto auto) async {
    await _client.from('auto').insert(auto.toJson());
  }

  Future<String> getMarcaModello(String targa) async {
    final auto = await getAuto(targa);
    return auto?.nomeCompleto ?? '';
  }

  Future<StatoAuto?> getStatoAuto(String targa) async {
    final auto = await getAuto(targa);
    return auto?.stato;
  }

  Future<void> updateStatoAuto(String targa, StatoAuto nuovoStato) async {
    await _client.from('auto').update({'stato': nuovoStato.dbValue}).eq('targa', targa);
  }

  Future<void> setAutoInattiva(String targa) => updateStatoAuto(targa, StatoAuto.inattivo);

  Future<void> setAutoAttiva(String targa) => updateStatoAuto(targa, StatoAuto.attivo);

  Future<void> eliminaAuto(String targa) async {
    await _client.from('auto').delete().eq('targa', targa);
  }

  Future<void> updateChilometraggio(String targa, int nuovoKm) async {
    await _client.from('auto').update({'chilometraggio': nuovoKm}).eq('targa', targa);
  }
}
