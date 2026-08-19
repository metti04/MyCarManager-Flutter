import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/enums.dart';
import '../models/lavoro.dart';
import '../services/lavoro_service.dart';
import '../widgets/blue_header_card.dart';
import '../widgets/expandable_action_card.dart';

class LavoriScreen extends StatefulWidget {
  final String targa;

  const LavoriScreen({super.key, required this.targa});

  @override
  State<LavoriScreen> createState() => _LavoriScreenState();
}

class _LavoriScreenState extends State<LavoriScreen> {
  final _lavoroService = LavoroService();
  List<Lavoro> _lavori = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    setState(() => _loading = true);
    final lavori = await _lavoroService.getLavoriByTarga(widget.targa);
    setState(() {
      _lavori = lavori;
      _loading = false;
    });
  }

  Future<void> _elimina(Lavoro l) async {
    if (l.id == null) return;
    await _lavoroService.eliminaLavoro(l.id!);
    _carica();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    final currency = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BlueHeaderCard(title: 'Lavori ${widget.targa}'),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _carica,
                      child: ListView(
                        children: [
                          for (final l in _lavori)
                            ExpandableActionCard(
                              icona: Icons.build,
                              titolo: l.nome,
                              valore: currency.format(l.costo ?? 0),
                              righeChiaveValore: [
                                if (l.chilometraggio != null) DetailRow('Km', '${l.chilometraggio} Km'),
                                DetailRow('Data', df.format(l.data)),
                                DetailRow('Stato', l.stato == StatoLavoro.eseguito ? 'Eseguito' : 'Da eseguire'),
                              ],
                              descrizioneLibera:
                                  '${l.tipologia == TipologiaLavoro.ordinario ? "Lavoro ordinario" : "Lavoro straordinario"}\n${l.descrizione ?? ""}',
                              onDelete: () => _elimina(l),
                              onEdit: () {},
                            ),
                          if (_lavori.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: Text('Nessun lavoro registrato per questa auto.')),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}
