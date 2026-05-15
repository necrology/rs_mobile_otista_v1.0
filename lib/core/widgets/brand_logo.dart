import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    required this.size,
    this.borderRadius = 14,
    this.backgroundColor = AppColors.primaryRed,
    super.key,
  });

  final double size;
  final double borderRadius;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primaryRed.withValues(alpha: 0.18),
            blurRadius: size * 0.18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        AppAssets.appLogo,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
