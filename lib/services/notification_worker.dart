import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'auto_service.dart';
import 'lavoro_service.dart';
import 'obbligo_service.dart';
import 'possedere_service.dart';
import 'supabase_service.dart';
import '../models/enum.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Inizializza Supabase e servizi in background
      await SupabaseService.init();
      final notificationService = NotificationService();
      await notificationService.init();

      // Recupera il nome utente memorizzato nelle preferenze condivise
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');

      if (username == null || username.isEmpty) return Future.value(true);

      final possedereService = PossedereService();
      final autoService = AutoService();
      final lavoroService = LavoroService();
      final obbligoService = ObbligoService();

      // Ottiene le targhe associate all'utente corrente
      final targhe = await possedereService.getTargheByUser(username);
      final now = DateTime.now();

      for (var targa in targhe) {
        final auto = await autoService.getAuto(targa);
        if (auto == null || auto.stato != StatoAuto.attivo) continue;

        // Controllo gli obblighi
        final obblighi = await obbligoService.getObblighiByTarga(targa);
        final scadenzeObblighi = obblighi.where((o) => o.stato == StatoObbligo.daPagare);
        
        for (var obbligo in scadenzeObblighi) {
          final scadenza = obbligo.dataScadenza;
          if (scadenza == null) continue;

          final giorniRimanenti = scadenza.difference(now).inDays;

          // Se l'obbligo scade nei prossimi 31 giorni o è già scaduto
          if (giorniRimanenti <= 31) {
            String title;
            String message;

            if (giorniRimanenti < 0) {
              title = "Scaduto: ${obbligo.nome ?? "Obbligo"}";
              message = "L'obbligo per ${auto.targa} è scaduto da ${-giorniRimanenti} giorni.";
            } else if (giorniRimanenti == 0) {
              title = "Scade oggi: ${obbligo.nome ?? "Obbligo"}";
              message = "L'obbligo per ${auto.targa} scade oggi!";
            } else {
              title = "Obbligo Imminente: ${obbligo.nome ?? "Obbligo"}";
              message = "L'obbligo per ${auto.targa} scade tra $giorniRimanenti giorni.";
            }

            await notificationService.showNotification(
              id: obbligo.id ?? (now.millisecond + 100),
              title: title,
              message: message,
            );
          }
        }

        // Controllo lavori
        final lavori = await lavoroService.getLavoriByTarga(targa);
        final scadenzeLavori = lavori.where((l) => l.stato == StatoLavoro.daEseguire);

        for (var lavoro in scadenzeLavori) {
          final dataLavoro = lavoro.data;
          final giorniRimanenti = dataLavoro.difference(now).inDays;
          final kmTarget = lavoro.chilometraggio;
          final kmRimanenti = kmTarget != null ? kmTarget - auto.chilometraggio : null;

          final isDateImminent = giorniRimanenti <= 31;
          final isKmImminent = kmRimanenti != null && kmRimanenti <= 1000;

          // Invia una notifica se la scadenza temporale o chilometrica è vicina
          if (isDateImminent || isKmImminent) {
            String title = "Lavoro Imminente: ${lavoro.nome}";
            List<String> messages = [];

            if (isDateImminent) {
              if (giorniRimanenti < 0) messages.add("Scaduto da ${-giorniRimanenti} giorni");
              else if (giorniRimanenti == 0) messages.add("Scade oggi!");
              else messages.add("Mancano $giorniRimanenti giorni");
            }

            if (isKmImminent) {
              if (kmRimanenti! < 0) messages.add("Soglia superata di ${-kmRimanenti} km");
              else messages.add("Mancano $kmRimanenti km");
            }

            if (isDateImminent && isKmImminent && (giorniRimanenti < 0 || kmRimanenti! < 0)) {
              title = "Lavoro SCADUTO: ${lavoro.nome}";
            }

            await notificationService.showNotification(
              id: lavoro.id ?? (now.millisecond + 200),
              title: title,
              message: "Per l'auto ${auto.targa}: ${messages.join(" e ")}",
            );
          }
        }
      }
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}
