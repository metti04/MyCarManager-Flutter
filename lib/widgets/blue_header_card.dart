import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BlueHeaderCard extends StatelessWidget {
  final String title;
  final double height;
  final Widget? actionBox;

  const BlueHeaderCard({super.key, required this.title, this.height = 220, this.actionBox});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      margin: const EdgeInsets.only(top: -40),
      decoration: BoxDecoration(color: AppColors.blu, borderRadius: BorderRadius.circular(40)),
      child: Column(
        mainAxisAlignment: actionBox == null ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (actionBox != null) const SizedBox(height: 50),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.bianco,
              fontSize: actionBox == null ? 34 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (actionBox != null) ...[const SizedBox(height: 12), actionBox!],
        ],
      ),
    );
  }
}

class HeaderActionBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const HeaderActionBox({super.key, required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bianco,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: AppColors.nero),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: AppColors.nero, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
