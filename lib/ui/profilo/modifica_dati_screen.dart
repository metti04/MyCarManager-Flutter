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
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');

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

          return Scaffold(
            backgroundColor: AppColors.bianco,
            body: SafeArea(
              child: Column(
                children: [
                  BlueHeaderCard(
                    title: viewModel.utente != null 
                        ? '${viewModel.utente!.nome} ${viewModel.utente!.cognome}'
                        : '',
                    height: 220,
                  ),
                  
                  Expanded(
                    child: Container(
                      // Rimosso il margine negativo che causava l'errore
                      margin: const EdgeInsets.only(top: 30), 
                      decoration: const BoxDecoration(
                        color: AppColors.bluChiaro,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: viewModel.loading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  _buildField(_nomeController, 'Nome'),
                                  _buildField(_cognomeController, 'Cognome'),
                                  _buildField(_emailController, 'Email'),
                                  _buildField(
                                    _passwordController, 
                                    'Password', 
                                    obscure: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: AppColors.blu,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  
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
                                    child: _buildFieldStatic(
                                        _dataNascita == null ? '' : df.format(_dataNascita!), 'Data di nascita'),
                                  ),
                                  
                                  _buildField(_usernameController, 'Username'),
                                  
                                  if (viewModel.error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        viewModel.error!,
                                        style: const TextStyle(color: AppColors.rosso, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    
                                  const SizedBox(height: 25),
                                  
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.bluPastello,
                                            minimumSize: const Size.fromHeight(55),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                          ),
                                          child: const Text('Annulla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: FilledButton(
                                          onPressed: viewModel.loading 
                                              ? null 
                                              : () async {
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
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Dati aggiornati!'))
                                                    );
                                                    Navigator.of(context).pop();
                                                  }
                                                },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.blu,
                                            minimumSize: const Size.fromHeight(55),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                          ),
                                          child: viewModel.loading
                                              ? const CircularProgressIndicator(color: AppColors.bianco)
                                              : const Text('Salva', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildField(TextEditingController controller, String label, {bool obscure = false, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.blu),
          hintStyle: const TextStyle(color: AppColors.blu),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldStatic(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.blu),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: AppColors.blu),
          ),
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 16, color: AppColors.blu, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
