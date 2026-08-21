import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:my_car_manager/theme/app_colors.dart';
import 'package:my_car_manager/widgets/blue_header_card.dart';
import 'package:my_car_manager/models/utente.dart';
import 'package:my_car_manager/ui/profilo/modifica_dati_viewmodel.dart';

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
    final df = DateFormat('dd/MM/yyyy');

    return ChangeNotifierProvider(
      create: (_) => ModificaDatiViewModel()..caricaDati(widget.username),
      child: Consumer<ModificaDatiViewModel>(
        builder: (context, viewModel, _) {
          // Popolamento iniziale dei campi
          if (viewModel.utente != null && _nomeController.text.isEmpty) {
            final u = viewModel.utente!;
            _nomeController.text = u.nome;
            _cognomeController.text = u.cognome;
            _emailController.text = u.email;
            _passwordController.text = u.password;
            _usernameController.text = u.username;
            _dataNascita = u.dataDiNascita;
          }

          return Scaffold(
            backgroundColor: AppColors.bianco,
            body: SafeArea(
              child: Column(
                children: [
                  BlueHeaderCard(
                    title: viewModel.utente != null 
                        ? '${viewModel.utente!.nome} ${viewModel.utente!.cognome}'
                        : 'Modifica Dati',
                    height: 180,
                  ),
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
                                            final updatedUtente = Utente(
                                              username: _usernameController.text,
                                              password: _passwordController.text,
                                              email: _emailController.text,
                                              nome: _nomeController.text,
                                              cognome: _cognomeController.text,
                                              dataDiNascita: _dataNascita ?? DateTime.now(),
                                            );
                                            final success = await viewModel.salva(updatedUtente);
                                            if (success && context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dati aggiornati!')));
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.bluScuro,
                                            minimumSize: const Size.fromHeight(60),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          ),
                                          child: viewModel.loading
                                              ? const CircularProgressIndicator(color: AppColors.bianco)
                                              : const Text('Salva'),
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
        style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.blu),
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
          labelStyle: const TextStyle(color: AppColors.blu),
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
        child: Text(value, style: const TextStyle(fontSize: 16, color: AppColors.blu, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
