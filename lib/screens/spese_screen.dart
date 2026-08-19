import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lavoro.dart';
import '../models/obbligo.dart';
import '../services/auto_service.dart';
import '../services/lavoro_service.dart';
import '../services/obbligo_service.dart';
import '../services/possedere_service.dart';
import '../theme/app_colors.dart';
import '../widgets/blue_header_card.dart';
import '../widgets/info_row_card.dart';

class SpeseScreen extends StatefulWidget {
  final String username;

  const SpeseScreen({super.key, required this.username});

  @override
  State<SpeseScreen> createState() => _SpeseScreenState();
}

class _SpeseScreenState extends State<SpeseScreen> {
  final _autoService = AutoService();
  final _possedereService = PossedereService();
  final _lavoroService = LavoroService();
  final _obbligoService = ObbligoService();

  List<Lavoro> _lavori = [];
  List<Obbligo> _obblighi = [];
  Map<String, String> _nomeAutoPerTarga = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    setState(() => _loading = true);
    final targhe = await _possedereService.getTargheByUser(widget.username);
    final autos = await _autoService.getAutoByTarghe(targhe);
    final nomi = {for (final a in autos) a.targa: a.nomeCompleto};

    final lavori = <Lavoro>[];
    final obblighi = <Obbligo>[];
    for (final auto in autos) {
      lavori.addAll(await _lavoroService.getSpeseByTarga(auto.targa));
      obblighi.addAll(await _obbligoService.getSpeseByTarga(auto.targa));
    }

    setState(() {
      _lavori = lavori;
      _obblighi = obblighi;
      _nomeAutoPerTarga = nomi;
      _loading = false;
    });
  }

  double get _totale {
    final totLavori = _lavori.fold<double>(0, (sum, l) => sum + (l.costo ?? 0));
    final totObblighi = _obblighi.fold<double>(0, (sum, o) => sum + (o.costo ?? 0));
    return totLavori + totObblighi;
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final currency = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BlueHeaderCard(title: 'Spese'),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Totale: ${currency.format(_totale)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blu)),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _carica,
                      child: ListView(
                        children: [
                          for (final l in _lavori)
                            InfoRowCard(
                              icona: Icons.build,
                              titolo: l.nome,
                              sottotitolo: _nomeAutoPerTarga[l.targaAuto] ?? l.targaAuto,
                              valoreAlto: currency.format(l.costo ?? 0),
                              valoreAltoColor: AppColors.blu,
                              valoreBasso: df.format(l.data),
                              mostraSveglia: false,
                            ),
                          for (final o in _obblighi)
                            InfoRowCard(
                              icona: Icons.assignment_turned_in,
                              titolo: o.nome ?? 'Obbligo',
                              sottotitolo: _nomeAutoPerTarga[o.targaAuto] ?? (o.targaAuto ?? ''),
                              valoreAlto: currency.format(o.costo ?? 0),
                              valoreAltoColor: AppColors.blu,
                              valoreBasso: o.dataPagamento != null ? df.format(o.dataPagamento!) : '-',
                              mostraSveglia: false,
                            ),
                          if (_lavori.isEmpty && _obblighi.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: Text('Nessuna spesa registrata.')),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
