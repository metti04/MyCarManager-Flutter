import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/utente.dart';
import '../../theme/app_colors.dart';
import '../../widgets/blue_header_card.dart';
import 'modifica_dati_viewmodel.dart';

class ModificaDatiScreen extends StatefulWidget {
  final String username;

  const ModificaDatiScreen({super.key, required this.username});

  @override
  State<ModificaDatiScreen> createState() => _ModificaDatiScreenState();
}

class _ModificaDatiScreenState extends State<ModificaDatiScreen> {
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  DateTime? _dataNascita;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModificaDatiViewModel()..caricaDati(widget.username),
      child: Consumer<ModificaDatiViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.utente != null && _nomeController.text.isEmpty) {
            final u = viewModel.utente!;
            _nomeController.text = u.nome;
            _cognomeController.text = u.cognome;
            _emailController.text = u.email;
            _passwordController.text = u.password;
            _usernameController.text = u.username;
            _dataNascita = u.dataDiNascita;
          }

          final df = DateFormat('dd/MM/yyyy');
          return Scaffold(
            backgroundColor: AppColors.bianco,
            body: SafeArea(
              child: Column(
                children: [
                  const BlueHeaderCard(title: 'I TUOI DATI', height: 180),
                  Expanded(
                    child: viewModel.loading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.bluChiaro2,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _buildWhiteField(_nomeController, 'Nome'),
                                  _buildWhiteField(_cognomeController, 'Cognome'),
                                  _buildWhiteField(_emailController, 'Email'),
                                  _buildWhiteField(_passwordController, 'Password', obscure: true),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _dataNascita ?? DateTime(2000),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) setState(() => _dataNascita = picked);
                                    },
                                    child: _buildWhiteFieldStatic(
                                        _dataNascita == null ? '' : df.format(_dataNascita!), 'Data di nascita'),
                                  ),
                                  _buildWhiteField(_usernameController, 'Username'),
                                  const SizedBox(height: 30),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.bluPastello,
                                            minimumSize: const Size.fromHeight(60),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          ),
                                          child: const Text('Annulla'),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: () async {
                                            final success = await viewModel.salva(Utente(
                                              username: _usernameController.text,
                                              password: _passwordController.text,
                                              email: _emailController.text,
                                              nome: _nomeController.text,
                                              cognome: _cognomeController.text,
                                              dataDiNascita: _dataNascita ?? DateTime.now(),
                                            ));
                                            if (success && context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvato!')));
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.bluScuro,
                                            minimumSize: const Size.fromHeight(60),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          ),
                                          child: const Text('Salva'),
                                        ),
                                      ),
                                    ],
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

  Widget _buildWhiteField(TextEditingController controller, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.bianco,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.nero),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.nero),
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteFieldStatic(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.bianco,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.nero),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.nero),
          ),
        ),
        child: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
