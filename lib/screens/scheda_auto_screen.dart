import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/auto.dart';
import '../models/enums.dart';
import '../services/auto_service.dart';
import '../theme/app_colors.dart';
import '../widgets/blue_header_card.dart';
import 'lavori_screen.dart';
import 'obblighi_screen.dart';

class SchedaAutoScreen extends StatefulWidget {
  final String targa;
  final String username;

  const SchedaAutoScreen({super.key, required this.targa, required this.username});

  @override
  State<SchedaAutoScreen> createState() => _SchedaAutoScreenState();
}

class _SchedaAutoScreenState extends State<SchedaAutoScreen> {
  final _autoService = AutoService();
  Auto? _auto;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    setState(() => _loading = true);
    final auto = await _autoService.getAuto(widget.targa);
    setState(() {
      _auto = auto;
      _loading = false;
    });
  }

  Future<void> _toggleStato() async {
    final auto = _auto;
    if (auto == null) return;
    if (auto.stato == StatoAuto.attivo) {
      await _autoService.setAutoInattiva(auto.targa);
    } else {
      await _autoService.setAutoAttiva(auto.targa);
    }
    _carica();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final auto = _auto;
    if (auto == null) {
      return const Scaffold(body: Center(child: Text('Veicolo non trovato')));
    }

    final df = DateFormat('dd/MM/yyyy');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BlueHeaderCard(title: auto.nomeCompleto, height: 200),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DettaglioRow(label: 'Targa', value: auto.targa),
                    _DettaglioRow(label: 'VIN', value: auto.vin),
                    _DettaglioRow(label: 'Alimentazione', value: auto.alimentazione.dbValue),
                    _DettaglioRow(label: 'Cilindrata', value: '${auto.cilindrata} cc'),
                    _DettaglioRow(label: 'Potenza', value: '${auto.potenza} CV'),
                    _DettaglioRow(label: 'Chilometraggio', value: '${auto.chilometraggio} km'),
                    _DettaglioRow(label: 'Immatricolazione', value: df.format(auto.dataImmatricolazione)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _toggleStato,
                      icon: Icon(auto.stato == StatoAuto.attivo ? Icons.pause_circle : Icons.play_circle,
                          color: auto.stato == StatoAuto.attivo ? AppColors.rosso : AppColors.verde),
                      label: Text(auto.stato == StatoAuto.attivo ? 'Segna come inattiva' : 'Segna come attiva'),
                    ),
                  ],
                ),
              ),
              const TabBar(
                labelColor: AppColors.blu,
                tabs: [Tab(text: 'Lavori'), Tab(text: 'Obblighi')],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    LavoriScreen(targa: auto.targa),
                    ObblighiScreen(targa: auto.targa),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DettaglioRow extends StatelessWidget {
  final String label;
  final String value;

  const _DettaglioRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
