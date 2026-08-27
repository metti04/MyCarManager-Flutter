import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/utente.dart';
import '../../theme/app_colors.dart';
import 'registrazione_viewmodel.dart';
import '../main/main_screen.dart';

class RegistrazioneScreen extends StatefulWidget {
  const RegistrazioneScreen({super.key});

  @override
  State<RegistrazioneScreen> createState() => _RegistrazioneScreenState();
}

class _RegistrazioneScreenState extends State<RegistrazioneScreen> {
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  DateTime? _dataNascita;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return ChangeNotifierProvider(
      create: (_) => RegistrazioneViewModel(),
      child: Consumer<RegistrazioneViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.blu,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header con Logo
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Image.asset(
                        'assets/images/iconaloginregistrazione.png',
                        width: 150,
                        height: 120,
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
                            _buildRoundedTextField(controller: _nomeController, label: 'Nome'),
                            const SizedBox(height: 12),
                            _buildRoundedTextField(controller: _cognomeController, label: 'Cognome'),
                            const SizedBox(height: 12),
                            _buildRoundedTextField(controller: _usernameController, label: 'Username'),
                            const SizedBox(height: 12),
                            _buildRoundedTextField(
                              controller: _emailController,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            _buildRoundedTextField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) setState(() => _dataNascita = picked);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Data di nascita',
                                  labelStyle: const TextStyle(color: AppColors.blu),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: const BorderSide(color: AppColors.blu),
                                  ),
                                ),
                                child: Text(
                                  _dataNascita == null ? '' : df.format(_dataNascita!),
                                  style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: viewModel.loading
                                  ? null
                                  : () async {
                                      final u = Utente(
                                        username: _usernameController.text,
                                        password: _passwordController.text,
                                        email: _emailController.text,
                                        nome: _nomeController.text,
                                        cognome: _cognomeController.text,
                                        dataDiNascita: _dataNascita ?? DateTime.now(),
                                      );
                                      final success = await viewModel.registra(u);
                                      if (success && context.mounted) {
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(builder: (_) => MainScreen(username: u.username)),
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
                                  : const Text('Registrati', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Hai già un account? Accedi',
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
