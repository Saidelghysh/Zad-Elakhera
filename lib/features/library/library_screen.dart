import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

class _LibrarySection {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final bool featured;

  const _LibrarySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.featured = false,
  });
}

const List<_LibrarySection> _sections = [
  _LibrarySection(
    title: 'البث المباشر',
    subtitle: 'إذاعة القرآن الكريم من القاهرة — استماع مباشر',
    icon: Icons.podcasts_rounded,
    route: '/library/live-radio',
    featured: true,
  ),
  _LibrarySection(
    title: 'التلاوات',
    subtitle: 'تلاوات كاملة لكبار القراء',
    icon: Icons.headphones_rounded,
    route: '/recitations',
  ),
  _LibrarySection(
    title: 'الحفلات الخارجية',
    subtitle: 'حفلات وتسجيلات نادرة — تشغيل داخل التطبيق',
    icon: Icons.library_music_rounded,
    route: '/library/hafla',
  ),
  _LibrarySection(
    title: 'الابتهالات والتواشيح',
    subtitle: 'مختارات خاشعة من كبار المبتهلين',
    icon: Icons.nights_stay_rounded,
    route: '/library/ibtihalat',
  ),
  _LibrarySection(
    title: 'الأمسيات الدينية',
    subtitle: 'تسجيلات دينية أرشيفية مرتبة',
    icon: Icons.auto_awesome_rounded,
    route: '/library/evenings',
  ),
];

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('المكتبة', style: AppTextStyles.h2)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('مكتبة زاد الآخرة', style: AppTextStyles.h1.copyWith(color: AppColors.gold, fontSize: 24)),
            const SizedBox(height: 4),
            Text('محتوى صوتي مرتب وواضح — اضغط واستمع مباشرة.', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 16),
            ..._sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  glow: section.featured,
                  borderColor: section.featured ? AppColors.gold : AppColors.surfaceBorder,
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () => context.push(section.route),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.navyCardAlt,
                              border: Border.all(color: AppColors.gold.withOpacity(0.60)),
                            ),
                            child: Icon(section.icon, color: AppColors.gold, size: 25),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(section.title, style: AppTextStyles.h3)),
                                    if (section.featured)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: AppColors.gold.withOpacity(0.45)),
                                        ),
                                        child: Text('مباشر', style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontSize: 10)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(section.subtitle, style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
