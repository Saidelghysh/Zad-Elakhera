import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// أنماط النصوص: Cairo لواجهة المستخدم، Amiri للنصوص القرآنية/الشرعية.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _cairo({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.cairo(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _amiri({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
  }) {
    return GoogleFonts.amiri(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  // Brand / splash
  static TextStyle appTitle = _cairo(
    size: 32,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );

  static TextStyle appSubtitle = _cairo(
    size: 13,
    weight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.7,
  );

  // Headings
  static TextStyle h1 = _cairo(size: 22, weight: FontWeight.w700);
  static TextStyle h2 = _cairo(size: 18, weight: FontWeight.w600);
  static TextStyle h3 = _cairo(size: 15, weight: FontWeight.w600, color: AppColors.gold);

  // Body
  static TextStyle body = _cairo(size: 14, weight: FontWeight.w400, height: 1.6);
  static TextStyle bodySecondary = _cairo(
    size: 12.5,
    weight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.7,
  );
  static TextStyle caption = _cairo(size: 11, weight: FontWeight.w400, color: AppColors.textMuted);

  // Menu grid label
  static TextStyle menuLabel = _cairo(size: 11.5, weight: FontWeight.w500, color: AppColors.textPrimary);

  // Quran / dua text (Amiri, larger, more line height for tashkeel)
  static TextStyle quranAyah = _amiri(size: 22, weight: FontWeight.w400, height: 2.1);
  static TextStyle duaText = _amiri(
    size: 15.5,
    weight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 2.0,
  );

  // Numbers (prayer countdown, tasbeeh counter, dua counter)
  static TextStyle counterLarge = _cairo(size: 28, weight: FontWeight.w700, color: AppColors.gold);
  static TextStyle counterMedium = _cairo(size: 20, weight: FontWeight.w600, color: AppColors.gold);

  // Button
  static TextStyle button = _cairo(size: 14, weight: FontWeight.w600, color: AppColors.gold);
}
