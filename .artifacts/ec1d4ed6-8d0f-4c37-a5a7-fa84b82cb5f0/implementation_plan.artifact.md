# Traduzione e Sistemazione Progetto MyCarManager (da Kotlin a Flutter)

Questo piano descrive i passaggi per allineare il progetto Flutter all'originale in Kotlin, correggendo le discrepanze nei servizi, migliorando la navigazione e rifinendo l'interfaccia utente.

## User Review Required

> [!IMPORTANT]
> Verrà introdotto un `MainScreen` che ospiterà la `BottomNavigationBar` in modo persistente, simile alla `MainActivity` in Kotlin. Questo cambierà leggermente il flusso di navigazione attuale che apre le schermate come pagine separate.

## Proposed Changes

### 1. Servizi (Services)

Aggiunta di metodi mancanti e allineamento della logica con la versione Kotlin.

#### [MODIFY] [auto_service.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/services/auto_service.dart)
- Aggiunta di `getAutoAttiveByTarghe(List<String> targhe)`.
- Aggiunta di `getSingolaAuto(String targa)` con ordinamento decrescente.

### 2. Navigazione e Struttura UI

Creazione di una struttura a schede (Tabs) persistente.

#### [NEW] [main_screen.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/screens/main_screen.dart)
- Schermata principale che contiene `BottomNavigationBar`.
- Gestisce il passaggio tra `HomeScreen`, `SpeseScreen`, `ScadenzeScreen` e `ProfiloScreen`.

#### [MODIFY] [main.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/main.dart)
- Aggiornamento della `_AuthGate` per reindirizzare a `MainScreen` invece di `HomeScreen`.

### 3. Raffinamento Schermate (Screens)

#### [MODIFY] [home_screen.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/screens/home_screen.dart)
- Rimozione della `bottomNavigationBar` (ora gestita da `MainScreen`).
- Implementazione della logica dei colori per il box "Scadenze" (Rosso se scadute, Arancio se imminenti, Verde altrimenti).
- Utilizzo di `getAutoAttiveByTarghe` per il calcolo di spese e scadenze.

#### [MODIFY] [spese_screen.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/screens/spese_screen.dart)
- Adattamento per essere visualizzata come tab del `MainScreen`.
- Rimozione del `Scaffold` o aggiustamento degli insets se necessario.

#### [MODIFY] [scadenze_screen.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/screens/scadenze_screen.dart)
- Adattamento per essere visualizzata come tab del `MainScreen`.

#### [MODIFY] [profilo_screen.dart](file:///C:/Users/metti04/Documents/UNIVERSITA/mycarmanger/MyCarManagerKotlin/MyCarManager-Flutter/lib/screens/profilo_screen.dart)
- Rimozione del `Scaffold` o adattamento per la navigazione tab.

## Verification Plan

### Automated Tests
- Non sono presenti test automatizzati al momento. La verifica sarà manuale.

### Manual Verification
- Avvio dell'app e verifica del corretto login.
- Verifica della persistenza della Bottom Navigation tra le 4 sezioni principali.
- Verifica che il box "Scadenze" nella Home cambi colore correttamente in base alle scadenze presenti.
- Verifica che le spese e scadenze vengano caricate solo per le auto attive (come in Kotlin).
