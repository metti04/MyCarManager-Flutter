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

class ScadenzeScreen extends StatefulWidget {
  final String username;

  const ScadenzeScreen({super.key, required this.username});

  @override
  State<ScadenzeScreen> createState() => _ScadenzeScreenState();
}

class _ScadenzeScreenState extends State<ScadenzeScreen> {
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
      lavori.addAll(await _lavoroService.getScadenzeByTarga(auto.targa));
      obblighi.addAll(await _obbligoService.getScadenzeByTarga(auto.targa));
    }

    setState(() {
      _lavori = lavori;
      _obblighi = obblighi;
      _nomeAutoPerTarga = nomi;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BlueHeaderCard(title: 'Scadenze'),
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
                              valoreAlto: df.format(l.data),
                              valoreAltoColor: AppColors.rosso,
                              mostraSveglia: true,
                              svegliaColor: l.data.difference(now).inDays <= 31 ? AppColors.rosso : AppColors.verde,
                            ),
                          for (final o in _obblighi)
                            InfoRowCard(
                              icona: Icons.assignment_turned_in,
                              titolo: o.nome ?? 'Obbligo',
                              sottotitolo: _nomeAutoPerTarga[o.targaAuto] ?? (o.targaAuto ?? ''),
                              valoreAlto: o.dataScadenza != null ? df.format(o.dataScadenza!) : '-',
                              valoreAltoColor: AppColors.rosso,
                              mostraSveglia: true,
                              svegliaColor: (o.dataScadenza != null && o.dataScadenza!.difference(now).inDays <= 31)
                                  ? AppColors.rosso
                                  : AppColors.verde,
                            ),
                          if (_lavori.isEmpty && _obblighi.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: Text('Nessuna scadenza in programma.')),
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
