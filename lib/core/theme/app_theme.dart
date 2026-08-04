import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.royalBlack,
      fontFamily: 'Cairo',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.goldDeep,
        surface: AppColors.navyCard,
        error: AppColors.danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.royalBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: const IconThemeData(color: AppColors.gold),
      ),
      textTheme: TextTheme(
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySecondary,
        titleLarge: AppTextStyles.h1,
        titleMedium: AppTextStyles.h2,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.deepNavy,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceBorder,
        thickness: 0.5,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyCardAlt,
          foregroundColor: AppColors.gold,
          elevation: 0,
          side: const BorderSide(color: AppColors.gold, width: 0.7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: AppTextStyles.button,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.gold),
      splashColor: AppColors.gold.withOpacity(0.08),
      highlightColor: Colors.transparent,
    );
  }
}
