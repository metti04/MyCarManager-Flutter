import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import 'login_viewmodel.dart';
import '../main/main_screen.dart';
import 'registrazione_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.blu,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car, size: 100, color: AppColors.bianco),
                          SizedBox(height: 10),
                          Text(
                            'MyCarManager',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bianco,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.bianco,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Password'),
                            ),
                            const SizedBox(height: 24),
                            if (viewModel.error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  viewModel.error!,
                                  style: const TextStyle(color: AppColors.rosso, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            FilledButton(
                              onPressed: viewModel.loading
                                  ? null
                                  : () async {
                                      final username = await viewModel.login(
                                        _emailController.text,
                                        _passwordController.text,
                                      );
                                      if (username != null && context.mounted) {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (_) => MainScreen(username: username)),
                                          (route) => false,
                                        );
                                      }
                                    },
                              child: viewModel.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bianco),
                                    )
                                  : const Text('Accedi'),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'OPPURE',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.bluIntenso, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: viewModel.loading
                                  ? null
                                  : () async {
                                      final username = await viewModel.loginWithGoogle();
                                      if (username != null && context.mounted) {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (_) => MainScreen(username: username)),
                                          (route) => false,
                                        );
                                      }
                                    },
                              icon: const Icon(Icons.login),
                              label: const Text('Google Sign In'),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegistrazioneScreen()),
                              ),
                              child: const Text(
                                'Registrati',
                                style: TextStyle(color: AppColors.bluIntenso, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
