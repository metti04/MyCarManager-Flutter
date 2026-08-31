import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/auto.dart';
import '../models/enum.dart';
import '../theme/app_colors.dart';

class AutoCard extends StatelessWidget {
  // L'oggetto auto da visualizzare.
  final Auto auto;

  // Colore dell'icona sveglia in Verde se in regola
  // Giallo/Arancione se imminente e  Rosso se scaduta
  final Color svegliaColor;


  final VoidCallback? onTap;

  const AutoCard({
    super.key,
    required this.auto,
    this.svegliaColor = AppColors.verde,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statoColor = auto.stato == StatoAuto.attivo ? AppColors.verde : AppColors.rosso;

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
                  child: SvgPicture.asset(
                    'assets/images/ic_auto.svg',
                    colorFilter: const ColorFilter.mode(AppColors.blu, BlendMode.srcIn),
                  ),
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
              // Icona Sveglia              // Icona Sveglia
              SvgPicture.asset(
                'assets/images/ic_sveglia.svg',
                colorFilter: ColorFilter.mode(svegliaColor, BlendMode.srcIn),
                width: 28,
                height: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
