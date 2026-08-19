import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/obbligo.dart';
import '../services/obbligo_service.dart';
import '../widgets/blue_header_card.dart';
import '../widgets/expandable_action_card.dart';

class ObblighiScreen extends StatefulWidget {
  final String targa;

  const ObblighiScreen({super.key, required this.targa});

  @override
  State<ObblighiScreen> createState() => _ObblighiScreenState();
}

class _ObblighiScreenState extends State<ObblighiScreen> {
  final _obbligoService = ObbligoService();
  List<Obbligo> _obblighi = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    setState(() => _loading = true);
    final obblighi = await _obbligoService.getObblighiByTarga(widget.targa);
    setState(() {
      _obblighi = obblighi;
      _loading = false;
    });
  }

  Future<void> _elimina(Obbligo o) async {
    if (o.id == null) return;
    await _obbligoService.eliminaObbligo(o.id!);
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
            BlueHeaderCard(title: 'Obblighi ${widget.targa}'),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _carica,
                      child: ListView(
                        children: [
                          for (final o in _obblighi)
                            ExpandableActionCard(
                              icona: Icons.assignment_turned_in,
                              titolo: o.nome ?? 'Obbligo',
                              valore: currency.format(o.costo ?? 0),
                              righeChiaveValore: [
                                DetailRow('Data pagamento', o.dataPagamento != null ? df.format(o.dataPagamento!) : '-'),
                                DetailRow('Scadenza', o.dataScadenza != null ? df.format(o.dataScadenza!) : '-'),
                              ],
                              onDelete: () => _elimina(o),
                              onEdit: () {},
                            ),
                          if (_obblighi.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: Text('Nessun obbligo registrato per questa auto.')),
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
