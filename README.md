# MyCarManager (Flutter)

Riscrittura in Flutter dell'app Android **MyCarManager** (Kotlin/XML + Supabase).

## Struttura del progetto

```
lib/
  main.dart
  theme/app_colors.dart, app_theme.dart
  models/enums.dart, auto.dart, lavoro.dart, obbligo.dart, possedere.dart, utente.dart
  services/supabase_service.dart, session_manager.dart,
           auto_service.dart, lavoro_service.dart, obbligo_service.dart,
           possedere_service.dart, utente_service.dart
  widgets/blue_header_card.dart, auto_card.dart, info_row_card.dart,
          expandable_action_card.dart, utente_list_tile.dart
  screens/login_screen.dart, registrazione_screen.dart,
          home_screen.dart, censimento_screen.dart,
          scadenze_screen.dart, spese_screen.dart,
          lavori_screen.dart, obblighi_screen.dart,
          scheda_auto_screen.dart, profilo_screen.dart, modifica_dati_screen.dart
```

## Mapping con il progetto Kotlin originale

| Kotlin/XML originale | Equivalente Flutter |
|---|---|
| `SupabaseInstance.kt` | `services/supabase_service.dart` |
| `AutoDbServices.kt`, `LavoroDbServices.kt`, `ObbligoDbServices.kt`, `PossedereDbServices.kt`, `UtenteDbServices.kt` | `services/*_service.dart` |
| `Auto.kt`, `Lavoro.kt`, `Obbligo.kt`, `Possedere.kt`, `Utente.kt`, `Enum.kt` | `models/*.dart` |
| `SessionManager.kt` | `services/session_manager.dart` |
| `LoginActivity(+ViewModel).kt` | `screens/login_screen.dart` |
| `RegistrazioneActivity(+ViewModel).kt` | `screens/registrazione_screen.dart` |
| `HomeFragment(+ViewModel).kt`, `AutoAdapter.kt` | `screens/home_screen.dart` |
| `CensimentoAutoFragment(+ViewModel).kt` | `screens/censimento_screen.dart` |
| `ScadenzeAutoCensiteFragment.kt` | `screens/scadenze_screen.dart` |
| `SpeseAutoCensiteFragment.kt` | `screens/spese_screen.dart` |
| `LavoriAutoFragment.kt` | `screens/lavori_screen.dart` |
| `ObblighiAutoFragment.kt` | `screens/obblighi_screen.dart` |
| `ProfiloUtenteFragment(+ViewModel).kt` | `screens/profilo_screen.dart` |
| `ModificaDatiUtenteFragment(+ViewModel).kt` | `screens/modifica_dati_screen.dart` |
| `item_headerblu.xml`, `item_scansione.xml` | `widgets/blue_header_card.dart` |
| `item_auto.xml` | `widgets/auto_card.dart` |
| `item_scadenza.xml`, `item_obbligo.xml` (flat), `item_spesa.xml` | `widgets/info_row_card.dart` |
| `item_lavoro.xml`, `item_obbligo.xml` (espandibile) | `widgets/expandable_action_card.dart` |
| `item_utente.xml` | `widgets/utente_list_tile.dart` |

## Note di migrazione

- L'OCR del libretto (ML Kit) e il login con Google (Credential Manager) non
  sono portati in questa prima versione: il form di censimento e login restano
  compilabili manualmente.
- L'autenticazione applicativa (tabella `utenti`) replica la logica originale
  (verifica email/password lato client, non Supabase Auth).

## Avvio

```bash
flutter pub get
flutter run
```
