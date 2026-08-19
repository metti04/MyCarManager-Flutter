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
            appBar: AppBar(
              title: const Text('Registrazione'),
              backgroundColor: Colors.transparent,
            ),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Icon(Icons.person_add, size: 80, color: AppColors.bianco),
                  ),
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
                            TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome')),
                            const SizedBox(height: 12),
                            TextField(controller: _cognomeController, decoration: const InputDecoration(labelText: 'Cognome')),
                            const SizedBox(height: 12),
                            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Password'),
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
                                decoration: const InputDecoration(labelText: 'Data di nascita'),
                                child: Text(_dataNascita == null ? '' : df.format(_dataNascita!)),
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
                              child: viewModel.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bianco),
                                    )
                                  : const Text('Registrati'),
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
