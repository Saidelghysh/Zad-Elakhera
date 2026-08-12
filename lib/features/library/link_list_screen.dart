import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../recitations/hafla_link_model.dart';

/// شاشة عامة قابلة لإعادة الاستخدام لعرض قائمة "حفلات/ابتهالات/أمسيات" —
/// كل عنصر يفتح شاشة مقاطعه الحقيقية (hafla_tracks_screen).
class LinkListScreen extends StatelessWidget {
  final String title;
  final List<HaflaLink> links;

  const LinkListScreen({super.key, required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text(title, style: AppTextStyles.h2)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: links.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final link = links[i];
            return GlassCard(
              child: InkWell(
                onTap: () => context.push('/library/tracks', extra: link),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.navyCardAlt,
                        border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                      ),
                      child: const Icon(Icons.music_note_rounded, color: AppColors.gold, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(link.sheikhName, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(link.description, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
