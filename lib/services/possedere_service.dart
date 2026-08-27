import '../models/possedere.dart';
import '../models/enum.dart';
import 'supabase_service.dart';

class PossedereService {
  final _client = SupabaseService.client;

  Future<List<Possedere>> getAllPossedere() async {
    final data = await _client.from('possedere').select();
    return (data as List).map((e) => Possedere.fromJson(e)).toList();
  }

  Future<List<String>> getTargheByUser(String username) async {
    final data = await _client.from('possedere').select().eq('usernameUtente', username);
    return (data as List).map((e) => e['targaAuto'] as String).toList();
  }

  Future<List<String>> getUsersByTarga(String targa) async {
    final data = await _client.from('possedere').select().eq('targaAuto', targa);
    return (data as List).map((e) => e['usernameUtente'] as String).toList();
  }

  Future<bool> isProprietario(String targa, String username) async {
    final data = await _client
        .from('possedere')
        .select()
        .eq('targaAuto', targa)
        .eq('usernameUtente', username)
        .eq('tipologia', TipologiaGestione.possessore.dbValue);
    return (data as List).isNotEmpty;
  }

  Future<String> trovaUsernameCondiviso(String targa) async {
    final data = await _client
        .from('possedere')
        .select()
        .eq('targaAuto', targa)
        .eq('tipologia', TipologiaGestione.nonPossessore.dbValue)
        .maybeSingle();
    return data == null ? '' : data['usernameUtente'] as String;
  }

  Future<void> insertPossedere(Possedere possedere) async {
    await _client.from('possedere').insert(possedere.toJson());
  }

  Future<void> eliminaCondivisione(String targa, String username) async {
    await _client.from('possedere').delete().eq('targaAuto', targa).eq('usernameUtente', username);
  }
}
