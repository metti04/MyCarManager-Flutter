import 'package:flutter/material.dart';
import 'services/session_manager.dart';
import 'services/supabase_service.dart';
import 'ui/main/main_screen.dart';
import 'ui/auth/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
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
