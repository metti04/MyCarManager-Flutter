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
      elevation: 2,
      color: AppColors.azzurroChiaro,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Immagine Auto
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: AppColors.bianco,
                child: Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.directions_car, size: 50, color: AppColors.blu),
                ),
              ),
              const SizedBox(width: 16),
              // Info Auto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      auto.nomeCompleto,
                      style: const TextStyle(
                        color: AppColors.nero,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      auto.targa,
                      style: const TextStyle(
                        color: AppColors.grigio,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auto.stato == StatoAuto.attivo ? 'Attiva' : 'Inattiva',
                      style: TextStyle(
                        color: statoColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Icona Sveglia
              Icon(Icons.alarm, size: 28, color: svegliaColor),
            ],
          ),
        ),
      ),
    );
  }
}
