import 'package:flutter/material.dart';
import '../models/utente.dart';
import '../theme/app_colors.dart';

class UtenteListTile extends StatelessWidget {
  final Utente utente;
  final bool selezionato;
  final VoidCallback? onTap;

  const UtenteListTile({super.key, required this.utente, this.selezionato = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 20, backgroundColor: AppColors.bluChiaro, child: Icon(Icons.person, color: AppColors.blu)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(utente.username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(utente.email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            IgnorePointer(
              child: Radio<bool>(value: true, groupValue: selezionato ? true : false, onChanged: null),
            ),
          ],
        ),
      ),
    );
  }
}
