import 'package:flutter/material.dart';
import 'app_colors.dart';

/// أنماط النصوص — تستخدم خط النظام الافتراضي (بدون اعتماد على الإنترنت
/// أو ملفات خط خارجية)، وهو يدعم العربية بشكل ممتاز تلقائيًا على أندرويد.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Brand / splash
  static TextStyle appTitle = _base(
    size: 32,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );

  static TextStyle appSubtitle = _base(
    size: 13,
    weight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.7,
  );

  // Headings
  static TextStyle h1 = _base(size: 22, weight: FontWeight.w700);
  static TextStyle h2 = _base(size: 18, weight: FontWeight.w600);
  static TextStyle h3 = _base(size: 15, weight: FontWeight.w600, color: AppColors.gold);

  // Body
  static TextStyle body = _base(size: 14, weight: FontWeight.w400, height: 1.6);
  static TextStyle bodySecondary = _base(
    size: 12.5,
    weight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.7,
  );
  static TextStyle caption = _base(size: 11, weight: FontWeight.w400, color: AppColors.textMuted);

  // Menu grid label
  static TextStyle menuLabel = _base(size: 11.5, weight: FontWeight.w500, color: AppColors.textPrimary);

  // Quran / dua text (larger, more line height for tashkeel)
  static TextStyle quranAyah = _base(size: 22, weight: FontWeight.w400, height: 2.1);
  static TextStyle duaText = _base(
    size: 15.5,
    weight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 2.0,
  );

  // Numbers (prayer countdown, tasbeeh counter, dua counter)
  static TextStyle counterLarge = _base(size: 28, weight: FontWeight.w700, color: AppColors.gold);
  static TextStyle counterMedium = _base(size: 20, weight: FontWeight.w600, color: AppColors.gold);

  // Button
  static TextStyle button = _base(size: 14, weight: FontWeight.w600, color: AppColors.gold);
}
