import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primaryTeal = Color(0xFF41AB9F);
  static const Color deepTeal = Color(0xFF1A4540);
  static const Color primaryRed = Color(0xFFB32025);
  static const Color primaryGreen = Color(0xFF0C8B4A);
  static const Color primaryBlue = Color(0xFF3B62A8);
  static const Color primaryGold = Color(0xFFF5AA22);

  static const Color scaffoldBackground = Color(0xFFF4F5EF);
  static const Color cardBackground = Colors.white;
  static const Color surfaceSoft = Color(0xFFE8F4F1);
  static const Color surfaceMuted = Color(0xFFF2EFE8);
  static const Color surfaceHighlight = Color(0xFFC6E4DF);
  static const Color borderSoft = Color(0xFFE3E0D7);

  static const Color textPrimary = Color(0xFF173D39);
  static const Color textSecondary = Color(0xFF5D6D68);
  static const Color success = Color(0xFF41B967);
  static const Color warning = Color(0xFFE69A19);
  static const Color danger = Color(0xFFC62828);

  static const LinearGradient brandGradient = LinearGradient(
    colors: <Color>[primaryTeal, deepTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
