import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'services/session_manager.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'services/notification_worker.dart';
import 'ui/main/main_screen.dart';
import 'ui/auth/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializzazione Supabase
  await SupabaseService.init();

  // Inizializzazione Notifiche
  final notificationService = NotificationService();
  await notificationService.init();

  // Inizializzazione Workmanager per compiti in background
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    "1", 
    "databaseCheckTask",
    frequency: const Duration(minutes: 3),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );

  runApp(const MyCarManagerApp());
}

class MyCarManagerApp extends StatelessWidget {
  const MyCarManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyCarManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SessionManager().getUsername(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final username = snapshot.data;
        if (username != null && username.isNotEmpty) {
          return MainScreen(username: username);
        }
        return const LoginScreen();
      },
    );
  }
}
