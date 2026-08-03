import 'package:flutter/material.dart';

/// اللغة اللونية الفاخرة للتطبيق: أسود ملكي + كحلي عميق + ذهبي فاخر.
class AppColors {
  AppColors._();

  // Base royal darks
  static const Color royalBlack = Color(0xFF04060D);
  static const Color deepNavy = Color(0xFF0A1024);
  static const Color navyCard = Color(0xFF0D1330);
  static const Color navyCardAlt = Color(0xFF111834);
  static const Color surfaceBorder = Color(0xFF262F52);
  static const Color surfaceBorderStrong = Color(0xFF33406B);

  // Gold luxury ramp
  static const Color gold = Color(0xFFE8C874);
  static const Color goldDeep = Color(0xFFC9A84C);
  static const Color goldBright = Color(0xFFF3D98A);
  static const Color goldMuted = Color(0xFF8A7233);

  // Text
  static const Color textPrimary = Color(0xFFEFF1FA);
  static const Color textSecondary = Color(0xFF9AA3C2);
  static const Color textMuted = Color(0xFF6B7495);

  // Status
  static const Color success = Color(0xFF63A66B);
  static const Color danger = Color(0xFFC1544F);

  // Gradients used sparingly for hero surfaces / splash glow
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF141B3C), Color(0xFF0A1024)],
  );

  static const RadialGradient goldGlow = RadialGradient(
    colors: [Color(0x33E8C874), Color(0x00E8C874)],
    radius: 0.8,
  );

  static const LinearGradient goldButton = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [goldDeep, gold],
  );
}
