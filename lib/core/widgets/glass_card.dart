import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// بطاقة فاخرة بتأثير زجاجي (Glassmorphism) وحدود ذهبية خفيفة مع توهج ناعم.
/// تُستخدم في كل بطاقات الواجهة الرئيسية (بطاقة الترحيب، بطاقة الصلاة، إلخ).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color borderColor;
  final bool glow;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.borderColor = AppColors.surfaceBorder,
    this.glow = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (backgroundColor ?? AppColors.navyCard).withOpacity(0.72),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: child,
        ),
      ),
    );

    if (!glow) return card;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: card,
    );
  }
}
