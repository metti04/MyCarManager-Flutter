# Migrazione Logica Gemini e Miglioramenti Architetturali in Flutter

L'obiettivo è allineare il progetto Flutter con le recenti modifiche apportate al progetto Kotlin, introducendo una gestione modulare dell'IA (Gemini) e migliorando la validazione dei dati per evitare errori di vincolo di integrità (Foreign Key).

## Modifiche Proposte

### 1. Dipendenze
- **[MODIFY] [pubspec.yaml](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/pubspec.yaml)**: Aggiunta di `http` per le chiamate API e `image_picker` per l'acquisizione di foto.

### 2. Modelli Dati
- **[NEW] [ai_data_models.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/models/ai_data_models.dart)**: Porting dei modelli `SmartResult` e `InvoiceResult` da Kotlin a Dart.

### 3. Servizi API (IA)
- **[NEW] [gemini_client.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/services/api_services/gemini_client.dart)**: Client centralizzato per la comunicazione con Google Gemini.
- **[NEW] [auto_api_service.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/services/api_services/auto_api_service.dart)**: Estrazione dati libretto.
- **[NEW] [lavoro_api_service.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/services/api_services/lavoro_api_service.dart)**: Estrazione dati fatture lavori.
- **[NEW] [obbligo_api_service.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/services/api_services/obbligo_api_service.dart)**: Estrazione dati bollo/assicurazione.

### 4. UI e ViewModel
- **[MODIFY] [censimento_screen.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/ui/auto/censimento_screen.dart)**: Aggiunta della funzionalità di scansione nell'header.
- **[MODIFY] [scheda_auto_screen.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/ui/scheda_auto/scheda_auto_screen.dart)**: Aggiunta dei box di scansione nei dialoghi "Aggiungi Lavoro" e "Aggiungi Obbligo".
- **[MODIFY] [login_viewmodel.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/ui/auth/login_viewmodel.dart)**: Aggiunta commenti e allineamento logica login Google.

### 5. Validazione (Fix Foreign Key)
- Implementazione della protezione del campo "Targa" durante l'auto-compilazione per evitare l'errore riscontrato in Kotlin (violazione Foreign Key).

## Piano di Verifica

### Manuale
1. Verificare che la scansione del libretto in "Censimento" popoli correttamente i campi.
2. Verificare che nei dialoghi di aggiunta lavoro/obbligo sia presente l'opzione "Scansiona".
3. Verificare che la targa non venga sovrascritta se già impostata e disabilitata.
