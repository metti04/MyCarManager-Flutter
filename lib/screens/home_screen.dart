import 'package:flutter/material.dart';
import '../models/auto.dart';
import '../models/lavoro.dart';
import '../models/obbligo.dart';
import '../services/auto_service.dart';
import '../services/lavoro_service.dart';
import '../services/obbligo_service.dart';
import '../services/possedere_service.dart';
import '../theme/app_colors.dart';
import '../widgets/blue_header_card.dart';
import '../widgets/auto_card.dart';
import 'censimento_screen.dart';
import 'scadenze_screen.dart';
import 'spese_screen.dart';
import 'profilo_screen.dart';
import 'scheda_auto_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _autoService = AutoService();
  final _possedereService = PossedereService();
  final _lavoroService = LavoroService();
  final _obbligoService = ObbligoService();

  List<Auto> _autos = [];
  List<Lavoro> _lavoriScadenze = [];
  List<Obbligo> _obblighiScadenze = [];
  List<Lavoro> _lavoriSpese = [];
  List<Obbligo> _obblighiSpese = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _caricaTuttiIDati();
  }

  Future<void> _caricaTuttiIDati() async {
    setState(() => _loading = true);
    try {
      final targhe = await _possedereService.getTargheByUser(widget.username);
      final autos = await _autoService.getAutoByTarghe(targhe);

      final lavoriScadenze = <Lavoro>[];
      final obblighiScadenze = <Obbligo>[];
      final lavoriSpese = <Lavoro>[];
      final obblighiSpese = <Obbligo>[];

      for (final auto in autos) {
        lavoriScadenze.addAll(await _lavoroService.getScadenzeByTarga(auto.targa));
        obblighiScadenze.addAll(await _obbligoService.getScadenzeByTarga(auto.targa));
        lavoriSpese.addAll(await _lavoroService.getSpeseByTarga(auto.targa));
        obblighiSpese.addAll(await _obbligoService.getSpeseByTarga(auto.targa));
      }

      setState(() {
        _autos = autos;
        _lavoriScadenze = lavoriScadenze;
        _obblighiScadenze = obblighiScadenze;
        _lavoriSpese = lavoriSpese;
        _obblighiSpese = obblighiSpese;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _hasScadenzaImminenteOScaduta(String targa) {
    final now = DateTime.now();
    for (final l in _lavoriScadenze.where((l) => l.targaAuto == targa)) {
      final giorni = l.data.difference(now).inDays;
      if (giorni <= 31) return true;
    }
    for (final o in _obblighiScadenze.where((o) => o.targaAuto == targa)) {
      if (o.dataScadenza == null) continue;
      final giorni = o.dataScadenza!.difference(now).inDays;
      if (giorni <= 31) return true;
    }
    return false;
  }

  int get _totaleScadenze => _lavoriScadenze.length + _obblighiScadenze.length;

  double get _totaleSpese {
    final totLavori = _lavoriSpese.fold<double>(0, (sum, l) => sum + (l.costo ?? 0));
    final totObblighi = _obblighiSpese.fold<double>(0, (sum, o) => sum + (o.costo ?? 0));
    return totLavori + totObblighi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _caricaTuttiIDati,
          child: Column(
            children: [
              BlueHeaderCard(title: 'Benvenuto ${widget.username}!'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _HomeStatBox(
                        icon: Icons.event_repeat,
                        label: 'Scadenze',
                        value: '$_totaleScadenze',
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => ScadenzeScreen(username: widget.username))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HomeStatBox(
                        icon: Icons.euro,
                        label: 'Spese',
                        value: '${_totaleSpese.toStringAsFixed(2)} €',
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => SpeseScreen(username: widget.username))),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _autos.isEmpty
                        ? const Center(child: Text('Nessun veicolo censito. Tocca + per aggiungerne uno.'))
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8),
                            itemCount: _autos.length,
                            itemBuilder: (context, index) {
                              final auto = _autos[index];
                              return AutoCard(
                                auto: auto,
                                scadenzaImminente: _hasScadenzaImminenteOScaduta(auto.targa),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SchedaAutoScreen(targa: auto.targa, username: widget.username),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => ProfiloScreen(username: widget.username)));
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profilo'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CensimentoScreen()));
          _caricaTuttiIDati();
        },
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi veicolo'),
      ),
    );
  }
}

class _HomeStatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _HomeStatBox({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.blu),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
