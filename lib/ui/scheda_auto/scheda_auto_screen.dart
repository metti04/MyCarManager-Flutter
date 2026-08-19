import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/auto.dart';
import '../../models/enums.dart';
import '../../models/lavoro.dart';
import '../../models/obbligo.dart';
import '../../theme/app_colors.dart';
import '../../widgets/expandable_action_card.dart';
import 'scheda_auto_viewmodel.dart';

class SchedaAutoScreen extends StatelessWidget {
  final String targa;
  final String username;

  const SchedaAutoScreen({super.key, required this.targa, required this.username});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SchedaAutoViewModel()..caricaDati(targa),
      child: Consumer<SchedaAutoViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.loading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final auto = viewModel.auto;
          if (auto == null) {
            return const Scaffold(body: Center(child: Text('Veicolo non trovato')));
          }

          return Container(
            color: AppColors.bluChiaro2,
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // TOP HEADER
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: AppColors.nero),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  auto.nomeCompleto,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.nero,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.rosso),
                              onPressed: () => _confermaEliminaAuto(context, viewModel),
                            ),
                          ],
                        ),
                      ),

                      // CAR IMAGE CARD
                      Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Container(
                            width: 120,
                            height: 120,
                            padding: const EdgeInsets.all(10),
                            child: const Icon(Icons.directions_car, size: 80, color: AppColors.blu),
                          ),
                        ),
                      ),

                      // ATTIVA SWITCH
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: Text(
                                auto.stato == StatoAuto.attivo ? 'Attiva' : 'Inattiva',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: auto.stato == StatoAuto.attivo ? AppColors.verde : AppColors.rosso,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: auto.stato == StatoAuto.attivo,
                              onChanged: (val) => viewModel.toggleStato(),
                              activeColor: AppColors.blu,
                            ),
                          ],
                        ),
                      ),

                      // ICON BAR
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _menuIcon(viewModel, 0, Icons.info_outline, 'Dettagli'),
                              _menuIcon(viewModel, 1, Icons.euro, 'Spese'),
                              _menuIcon(viewModel, 2, Icons.event_repeat, 'Scadenze'),
                              _menuIcon(viewModel, 3, Icons.build, 'Lavori'),
                              _menuIcon(viewModel, 4, Icons.assignment, 'Obblighi'),
                            ],
                          ),
                        ),
                      ),

                      // CONTENT
                      Expanded(
                        child: _buildFragment(viewModel),
                      ),
                    ],
                  ),
                  
                  // FLOATING ACTION BUTTON
                  if (viewModel.currentTab == 3 || viewModel.currentTab == 4)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        onPressed: () {
                          if (viewModel.currentTab == 3) {
                            _aggiungiLavoro(context, viewModel, auto.targa);
                          } else {
                            _aggiungiObbligo(context, viewModel, auto.targa);
                          }
                        },
                        backgroundColor: AppColors.blu,
                        child: const Icon(Icons.add, color: AppColors.bianco),
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

  void _confermaEliminaAuto(BuildContext context, SchedaAutoViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina veicolo'),
        content: const Text('Sei sicuro di voler eliminare definitivamente questo veicolo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () async {
              await viewModel.eliminaAuto();
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text('Elimina', style: TextStyle(color: AppColors.rosso)),
          ),
        ],
      ),
    );
  }

  void _aggiungiLavoro(BuildContext context, SchedaAutoViewModel viewModel, String targa) {
    final nomeController = TextEditingController();
    final costoController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo lavoro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome lavoro')),
            TextField(controller: costoController, decoration: const InputDecoration(labelText: 'Costo'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty) {
                final nuovo = Lavoro(
                  targaAuto: targa,
                  nome: nomeController.text,
                  costo: double.tryParse(costoController.text) ?? 0.0,
                  data: DateTime.now(),
                  stato: StatoLavoro.eseguito,
                  tipologia: TipologiaLavoro.ordinario,
                  descrizione: '',
                );
                await viewModel.aggiornaLavoro(nuovo); // Usiamo aggiorna che inserisce se non c'è ID
                Navigator.pop(ctx);
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  void _aggiungiObbligo(BuildContext context, SchedaAutoViewModel viewModel, String targa) {
    final nomeController = TextEditingController();
    final costoController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo obbligo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome obbligo')),
            TextField(controller: costoController, decoration: const InputDecoration(labelText: 'Costo'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () async {
              if (nomeController.text.isNotEmpty) {
                final nuovo = Obbligo(
                  targaAuto: targa,
                  nome: nomeController.text,
                  costo: double.tryParse(costoController.text) ?? 0.0,
                  dataPagamento: DateTime.now(),
                  stato: StatoObbligo.pagato,
                );
                await viewModel.aggiornaObbligo(nuovo);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  Widget _menuIcon(SchedaAutoViewModel viewModel, int index, IconData icon, String label) {
    final isSelected = viewModel.currentTab == index;
    final color = isSelected ? AppColors.blu : AppColors.nero;
    return InkWell(
      onTap: () => viewModel.setTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFragment(SchedaAutoViewModel viewModel) {
    switch (viewModel.currentTab) {
      case 0: return _DettagliFragment(auto: viewModel.auto!, viewModel: viewModel);
      case 1: return _SpeseFragment(viewModel: viewModel);
      case 2: return _ScadenzeFragment(viewModel: viewModel);
      case 3: return _LavoriFragment(viewModel: viewModel);
      case 4: return _ObblighiFragment(viewModel: viewModel);
      default: return const SizedBox();
    }
  }
}

class _DettagliFragment extends StatefulWidget {
  final Auto auto;
  final SchedaAutoViewModel viewModel;
  const _DettagliFragment({required this.auto, required this.viewModel});

  @override
  State<_DettagliFragment> createState() => _DettagliFragmentState();
}

class _DettagliFragmentState extends State<_DettagliFragment> {
  final _kmController = TextEditingController();
  bool _editingKm = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dettagli', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _infoRow('Marca', widget.auto.marchio),
                  _infoRow('Modello', widget.auto.modello),
                  _infoRow('Targa', widget.auto.targa),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Text('KM attuali: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: !_editingKm
                            ? Text('${widget.auto.chilometraggio}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blu))
                            : TextField(
                                controller: _kmController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blu),
                              ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          if (!_editingKm) {
                            _kmController.text = widget.auto.chilometraggio.toString();
                            setState(() => _editingKm = true);
                          } else {
                            final newKm = int.tryParse(_kmController.text);
                            if (newKm != null) await widget.viewModel.updateKm(newKm);
                            setState(() => _editingKm = false);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.blu,
                          minimumSize: const Size(80, 35),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(_editingKm ? 'Salva' : 'Aggiorna', style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Documentazione', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _docSlot(),
                      _docSlot(),
                      _docSlot(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.grigioMedio, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _docSlot() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: AppColors.bluChiaro, borderRadius: BorderRadius.circular(15)),
    );
  }
}

class _SpeseFragment extends StatelessWidget {
  final SchedaAutoViewModel viewModel;
  const _SpeseFragment({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final items = viewModel.itemsSpese;
    final df = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('TOTALE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, decoration: TextDecoration.none, color: AppColors.nero)),
                      Text('${viewModel.totaleGenerale.toStringAsFixed(2)}€', style: const TextStyle(color: AppColors.blu, fontWeight: FontWeight.bold, fontSize: 24, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.grigino),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.build, size: 16, color: AppColors.blu),
                          const SizedBox(width: 5),
                          Text('${viewModel.totLavori.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.none, color: AppColors.nero)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.assignment, size: 16, color: AppColors.blu),
                          const SizedBox(width: 5),
                          Text('${viewModel.totObblighi.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.none, color: AppColors.nero)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final nome = item is Lavoro ? item.nome : (item as Obbligo).nome ?? 'Obbligo';
              final costo = item is Lavoro ? item.costo : (item as Obbligo).costo;
              final data = item is Lavoro ? item.data : (item as Obbligo).dataPagamento;
              final icon = item is Lavoro ? Icons.build : Icons.assignment;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.bluChiaro, child: Icon(icon, color: AppColors.blu, size: 20)),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data != null ? df.format(data) : '-'),
                  trailing: Text('${costo?.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blu)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ScadenzeFragment extends StatelessWidget {
  final SchedaAutoViewModel viewModel;
  const _ScadenzeFragment({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final items = viewModel.itemsScadenze;
    final df = DateFormat('dd/MM/yyyy');

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Scadute', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grigioMedio, decoration: TextDecoration.none, fontSize: 16)),
                      Text('${viewModel.countScadute}', style: const TextStyle(color: AppColors.rosso, fontWeight: FontWeight.bold, fontSize: 24, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.grigino),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Imminenti', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.grigioMedio, decoration: TextDecoration.none, fontSize: 16)),
                      Text('${viewModel.countImminenti}', style: const TextStyle(color: AppColors.arancione, fontWeight: FontWeight.bold, fontSize: 24, decoration: TextDecoration.none)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final nome = item is Lavoro ? item.nome : (item as Obbligo).nome ?? 'Obbligo';
              final data = item is Lavoro ? item.data : (item as Obbligo).dataScadenza;
              final icon = item is Lavoro ? Icons.build : Icons.assignment;
              final isScaduta = data != null && data.isBefore(now);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppColors.bluChiaro, child: Icon(icon, color: AppColors.blu, size: 20)),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(data != null ? df.format(data) : '-', style: TextStyle(color: isScaduta ? AppColors.rosso : AppColors.nero)),
                      const SizedBox(width: 5),
                      Icon(Icons.alarm, color: isScaduta ? AppColors.rosso : AppColors.verde, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LavoriFragment extends StatelessWidget {
  final SchedaAutoViewModel viewModel;
  const _LavoriFragment({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final lavori = viewModel.lavori;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: lavori.length,
      itemBuilder: (context, index) {
        final l = lavori[index];
        return ExpandableActionCard(
          icona: Icons.build,
          titolo: l.nome,
          valore: '${l.costo?.toStringAsFixed(2)}€',
          righeChiaveValore: [
            DetailRow('Data', DateFormat('dd/MM/yyyy').format(l.data)),
            if (l.chilometraggio != null) DetailRow('Km', '${l.chilometraggio} Km'),
            DetailRow('Stato', l.stato == StatoLavoro.eseguito ? 'Eseguito' : 'Da eseguire'),
          ],
          descrizioneLibera: 'Lavoro ${l.tipologia == TipologiaLavoro.ordinario ? "Ordinario" : "Non ordinario"}\n${l.descrizione ?? ""}',
          onEdit: () => _modificaLavoro(context, viewModel, l),
          onDelete: () => _confermaEliminaLavoro(context, viewModel, l),
        );
      },
    );
  }

  void _confermaEliminaLavoro(BuildContext context, SchedaAutoViewModel viewModel, Lavoro l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina lavoro'),
        content: Text('Eliminare "${l.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              viewModel.eliminaLavoro(l.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Elimina', style: TextStyle(color: AppColors.rosso)),
          ),
        ],
      ),
    );
  }

  void _modificaLavoro(BuildContext context, SchedaAutoViewModel viewModel, Lavoro l) {
    final nomeController = TextEditingController(text: l.nome);
    final costoController = TextEditingController(text: l.costo?.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifica lavoro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: costoController, decoration: const InputDecoration(labelText: 'Costo'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              final updated = Lavoro(
                id: l.id,
                targaAuto: l.targaAuto,
                nome: nomeController.text,
                costo: double.tryParse(costoController.text) ?? l.costo,
                data: l.data,
                stato: l.stato,
                tipologia: l.tipologia,
                descrizione: l.descrizione,
                chilometraggio: l.chilometraggio,
              );
              viewModel.aggiornaLavoro(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}

class _ObblighiFragment extends StatelessWidget {
  final SchedaAutoViewModel viewModel;
  const _ObblighiFragment({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final obblighi = viewModel.obblighi;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: obblighi.length,
      itemBuilder: (context, index) {
        final o = obblighi[index];
        final df = DateFormat('dd/MM/yyyy');
        return ExpandableActionCard(
          icona: Icons.assignment,
          titolo: o.nome ?? 'Obbligo',
          valore: '${o.costo?.toStringAsFixed(2)}€',
          righeChiaveValore: [
            if (o.dataPagamento != null) DetailRow('Pagato il', df.format(o.dataPagamento!)),
            if (o.dataScadenza != null) DetailRow('Scadenza', df.format(o.dataScadenza!)),
            DetailRow('Stato', o.stato == StatoObbligo.pagato ? 'Pagato' : 'Da pagare'),
          ],
          onEdit: () => _modificaObbligo(context, viewModel, o),
          onDelete: () => _confermaEliminaObbligo(context, viewModel, o),
        );
      },
    );
  }

  void _confermaEliminaObbligo(BuildContext context, SchedaAutoViewModel viewModel, Obbligo o) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina obbligo'),
        content: Text('Eliminare "${o.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              viewModel.eliminaObbligo(o.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Elimina', style: TextStyle(color: AppColors.rosso)),
          ),
        ],
      ),
    );
  }

  void _modificaObbligo(BuildContext context, SchedaAutoViewModel viewModel, Obbligo o) {
    final nomeController = TextEditingController(text: o.nome);
    final costoController = TextEditingController(text: o.costo?.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifica obbligo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: costoController, decoration: const InputDecoration(labelText: 'Costo'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              final updated = Obbligo(
                id: o.id,
                targaAuto: o.targaAuto,
                nome: nomeController.text,
                costo: double.tryParse(costoController.text) ?? o.costo,
                dataPagamento: o.dataPagamento,
                dataScadenza: o.dataScadenza,
                stato: o.stato,
              );
              viewModel.aggiornaObbligo(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}
