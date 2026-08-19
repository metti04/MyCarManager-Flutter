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
      transform: Matrix4.translationValues(0, -40, 0),
      decoration: const BoxDecoration(
        color: AppColors.blu,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisAlignment: actionBox == null ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          SizedBox(height: actionBox == null ? 40 : 60),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.bianco,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          if (actionBox != null) ...[
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: actionBox!,
            ),
          ],
        ],
      ),
    );
  }
}
