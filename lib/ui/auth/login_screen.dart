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
                  // Header con Logo
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Image.asset(
                        'assets/images/iconaloginregistrazione.png',
                        width: 256,
                        height: 216,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Contenitore Bianco Arrotondato
                  Expanded(
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
                            _buildRoundedTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            _buildRoundedTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: true,
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
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.blu,
                                minimumSize: const Size.fromHeight(60),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              child: viewModel.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bianco),
                                    )
                                  : const Text('Accedi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.blu,
                                minimumSize: const Size.fromHeight(60),
                                side: const BorderSide(color: AppColors.blu, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              icon: const Icon(Icons.login),
                              label: const Text('Google Sign In', style: TextStyle(fontSize: 18)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegistrazioneScreen()),
                              ),
                              child: const Text(
                                'Registrati',
                                style: TextStyle(color: AppColors.bluIntenso, fontWeight: FontWeight.bold, fontSize: 16),
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

  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.blu),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.blu),
        hintStyle: const TextStyle(color: AppColors.blu),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.blu),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.blu, width: 2),
        ),
      ),
    );
  }
}
