import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// بانر "دعاء لوالدي" في الشاشة الرئيسية — يقود إلى صفحة الصدقة الخاصة.
class DuaBanner extends StatelessWidget {
  final VoidCallback onTap;
  const DuaBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.navyCardAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold, width: 0.8),
        ),
        child: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: AppColors.gold, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('دعاء لوالدي', style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text('اللهم اغفر له وارحمه', style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
