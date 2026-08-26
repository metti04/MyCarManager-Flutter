import '../models/utente.dart';
import 'supabase_service.dart';

class UtenteService {
  final _client = SupabaseService.client;

  Future<List<Utente>> getUtenti() async {
    final data = await _client.from('utenti').select();
    return (data as List).map((e) => Utente.fromJson(e)).toList();
  }

  Future<Utente?> getUtente(String username) async {
    final data = await _client
        .from('utenti')
        .select()
        .eq('username', username)
        .order('username', ascending: false)
        .maybeSingle();
    return data == null ? null : Utente.fromJson(data);
  }

  Future<Utente?> getUtenteByEmail(String email) async {
    final data = await _client.from('utenti').select().eq('email', email).maybeSingle();
    return data == null ? null : Utente.fromJson(data);
  }

  Future<void> inserisciUtente(Utente utente) async {
    await _client.from('utenti').insert(utente.toJson());
  }

  Future<void> aggiornaUtente(Utente utente, {String? vecchioUsername}) async {
    await _client.from('utenti').update(utente.toJson()).eq('email', utente.email);

    if (vecchioUsername != null && vecchioUsername != utente.username) {
      await _client
          .from('possedere')
          .update({'usernameUtente': utente.username})
          .eq('usernameUtente', vecchioUsername);
    }
  }
}
