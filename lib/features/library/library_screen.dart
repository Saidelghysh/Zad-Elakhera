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

  const _LibrarySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

const List<_LibrarySection> _sections = [
  _LibrarySection(
    title: 'التلاوات',
    subtitle: 'قراء معاصرون بأصوات كاملة للمصحف',
    icon: Icons.headphones_rounded,
    route: '/recitations',
  ),
  _LibrarySection(
    title: 'حفلات وتسجيلات نادرة',
    subtitle: 'المنشاوي، عبدالباسط، الليثي، البنا وغيرهم',
    icon: Icons.auto_awesome_rounded,
    route: '/library/hafla',
  ),
  _LibrarySection(
    title: 'الابتهالات',
    subtitle: 'النقشبندي، محمد عمران، نصر الدين طوبار',
    icon: Icons.nights_stay_rounded,
    route: '/library/ibtihalat',
  ),
  _LibrarySection(
    title: 'أمسيات دينية',
    subtitle: 'من تراث إذاعة القرآن الكريم من القاهرة',
    icon: Icons.menu_book_rounded,
    route: '/library/evenings',
  ),
  _LibrarySection(
    title: 'بث مباشر',
    subtitle: 'إذاعة القرآن الكريم من القاهرة، على مدار الساعة',
    icon: Icons.podcasts_rounded,
    route: '/library/live-radio',
  ),
];

/// شاشة المكتبة — مدخل موحّد لكل المحتوى الصوتي الإضافي بالتطبيق.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('المكتبة', style: AppTextStyles.h2)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final s = _sections[i];
            return GlassCard(
              glow: i == 0,
              child: InkWell(
                onTap: () => context.push(s.route),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.navyCardAlt,
                        border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                        boxShadow: [
                          BoxShadow(color: AppColors.gold.withOpacity(0.15), blurRadius: 10, spreadRadius: 1),
                        ],
                      ),
                      child: Icon(s.icon, color: AppColors.gold, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: 3),
                          Text(s.subtitle, style: AppTextStyles.caption),
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
