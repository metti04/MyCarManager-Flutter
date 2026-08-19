import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class InfoRowCard extends StatelessWidget {
  final IconData icona;
  final String titolo;
  final String sottotitolo;
  final String valoreAlto;
  final Color valoreAltoColor;
  final String? valoreBasso;
  final Color valoreBassoColor;
  final bool mostraSveglia;
  final Color svegliaColor;
  final VoidCallback? onTap;

  const InfoRowCard({
    super.key,
    required this.icona,
    required this.titolo,
    required this.sottotitolo,
    required this.valoreAlto,
    this.valoreAltoColor = AppColors.rosso,
    this.valoreBasso,
    this.valoreBassoColor = AppColors.nero,
    this.mostraSveglia = false,
    this.svegliaColor = AppColors.rosso,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.bianco,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.bluChiaro, shape: BoxShape.circle),
                child: Icon(icona, size: 28, color: AppColors.blu),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titolo, style: const TextStyle(color: AppColors.nero, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(sottotitolo, style: const TextStyle(color: AppColors.nero, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(valoreAlto, style: TextStyle(color: valoreAltoColor, fontSize: 14, fontWeight: FontWeight.bold)),
                  if (valoreBasso != null)
                    Text(valoreBasso!, style: TextStyle(color: valoreBassoColor, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              if (mostraSveglia) ...[const SizedBox(width: 8), Icon(Icons.alarm, size: 28, color: svegliaColor)],
            ],
          ),
        ),
      ),
    );
  }
}
