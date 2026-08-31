import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class DetailRow {
  final String label;

  final String value;

  const DetailRow(this.label, this.value);
}

class ExpandableActionCard extends StatefulWidget {
  final String? iconaAsset;

  final IconData? icona;

  final String titolo;

  final String valore;

  final List<DetailRow> righeChiaveValore;

  final String? descrizioneLibera;

  final VoidCallback? onDelete;

  final VoidCallback? onEdit;

  const ExpandableActionCard({
    super.key,
    this.iconaAsset,
    this.icona,
    required this.titolo,
    required this.valore,
    this.righeChiaveValore = const [],
    this.descrizioneLibera,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<ExpandableActionCard> createState() => _ExpandableActionCardState();
}

class _ExpandableActionCardState extends State<ExpandableActionCard> {
  // Stato interno che traccia se la scheda è aperta ed espansa
  bool _espanso = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _espanso = !_espanso),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intestazione principale della scheda (Icona, Titolo, Valore principale)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.bluChiaro, shape: BoxShape.circle),
                    child: widget.iconaAsset != null 
                      ? SvgPicture.asset(
                          widget.iconaAsset!,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(AppColors.blu, BlendMode.srcIn),
                        )
                      : Icon(widget.icona, size: 24, color: AppColors.blu),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.titolo,
                      style: const TextStyle(color: AppColors.nero, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    widget.valore,
                    style: const TextStyle(color: AppColors.blu, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // Contenuto animato e dettagliato visualizzato solo se espanso
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Elenco delle righe chiave-valore dei dettagli
                      for (final riga in widget.righeChiaveValore)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(riga.label,
                                  style: const TextStyle(color: AppColors.nero, fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(riga.value,
                                  style: const TextStyle(color: AppColors.nero, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      // Descrizione testuale libera se presente
                      if (widget.descrizioneLibera != null) ...[
                        const SizedBox(height: 6),
                        Text(widget.descrizioneLibera!, style: const TextStyle(color: AppColors.nero, fontSize: 13)),
                      ],
                      const SizedBox(height: 10),
                      // Pulsanti di azione per eliminazione e modifica dell'elemento
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/ic_elimina.svg',
                              colorFilter: const ColorFilter.mode(AppColors.rosso, BlendMode.srcIn),
                              width: 24,
                              height: 24,
                            ),
                            onPressed: widget.onDelete,
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/images/ic_modifica.svg',
                              colorFilter: const ColorFilter.mode(AppColors.blu, BlendMode.srcIn),
                              width: 24,
                              height: 24,
                            ),
                            onPressed: widget.onEdit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                crossFadeState: _espanso ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
