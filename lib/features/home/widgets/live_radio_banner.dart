import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';

class LiveRadioBanner extends StatelessWidget {
  const LiveRadioBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glow: true,
      borderColor: AppColors.gold.withOpacity(0.75),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/library/live-radio'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withOpacity(0.10),
                  border: Border.all(color: AppColors.gold.withOpacity(0.65)),
                ),
                child: const Icon(Icons.podcasts_rounded, color: AppColors.gold, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('البث المباشر', style: AppTextStyles.h3.copyWith(color: AppColors.gold)),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gold.withOpacity(0.45)),
                          ),
                          child: Text('LIVE', style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontSize: 9)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text('إذاعة القرآن الكريم من القاهرة', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill_rounded, color: AppColors.gold, size: 34),
            ],
          ),
        ),
      ),
    );
  }
}
