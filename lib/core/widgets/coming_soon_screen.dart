import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'arch_crescent_logo.dart';
import 'gold_divider.dart';

/// شاشة عنصر نائب (Placeholder) للوحدات التي تحتاج مصدر بيانات خارجي كبير
/// (نص القرآن الكامل، ملفات صوتية، كتب تفسير...). البنية والثيم جاهزة؛
/// يبقى فقط توصيل مصدر البيانات (API أو ملفات محلية) كما هو موضح في README.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String note;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text(title, style: AppTextStyles.h2)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ArchCrescentLogo(size: 90),
              const SizedBox(height: 16),
              Icon(icon, color: AppColors.gold, size: 28),
              const SizedBox(height: 12),
              Text(title, style: AppTextStyles.h1),
              const SizedBox(height: 10),
              const GoldDivider(width: 80),
              const SizedBox(height: 14),
              Text(note, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }
}
