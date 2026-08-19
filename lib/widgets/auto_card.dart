import 'package:flutter/material.dart';
import '../models/auto.dart';
import '../models/enums.dart';
import '../theme/app_colors.dart';

class AutoCard extends StatelessWidget {
  final Auto auto;
  final bool scadenzaImminente;
  final VoidCallback? onTap;

  const AutoCard({super.key, required this.auto, this.scadenzaImminente = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statoColor = auto.stato == StatoAuto.attivo ? AppColors.verde : AppColors.rosso;
    final svegliaColor = scadenzaImminente ? AppColors.rosso : AppColors.verde;

    return Card(
      color: AppColors.azzurroChiaro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.bianco, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.directions_car, size: 60, color: AppColors.blu),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auto.nomeCompleto,
                        style: const TextStyle(color: AppColors.nero, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(auto.targa,
                        style: const TextStyle(color: AppColors.grigio, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(auto.stato == StatoAuto.attivo ? 'Attiva' : 'Non attiva',
                        style: TextStyle(color: statoColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Icon(Icons.alarm, size: 28, color: svegliaColor),
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
