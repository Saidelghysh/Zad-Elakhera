import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MenuItemData {
  final IconData icon;
  final String label;
  final String route;

  const MenuItemData({required this.icon, required this.label, required this.route});
}

const List<MenuItemData> homeMenuItems = [
  MenuItemData(icon: Icons.menu_book_rounded, label: 'القرآن الكريم', route: '/quran'),
  MenuItemData(icon: Icons.headphones_rounded, label: 'التلاوات', route: '/recitations'),
  MenuItemData(icon: Icons.auto_stories_rounded, label: 'التفسير', route: '/tafsir'),
  MenuItemData(icon: Icons.mosque_rounded, label: 'أوقات الصلاة', route: '/prayer-times'),
  MenuItemData(icon: Icons.explore_rounded, label: 'القبلة', route: '/qibla'),
  MenuItemData(icon: Icons.self_improvement_rounded, label: 'الأذكار', route: '/azkar'),
  MenuItemData(icon: Icons.fiber_manual_record_rounded, label: 'التسبيح', route: '/tasbeeh'),
  MenuItemData(icon: Icons.record_voice_over_rounded, label: 'أحكام التجويد', route: '/tajweed'),
  MenuItemData(icon: Icons.accessibility_new_rounded, label: 'تعلم الصلاة', route: '/learn-salah'),
  MenuItemData(icon: Icons.favorite_rounded, label: 'دعاء لوالدي', route: '/dua-walidi'),
];

/// شبكة القوائم الرئيسية — بطاقات فاخرة بحدود ذهبية رفيعة.
class HomeMenuGrid extends StatelessWidget {
  final void Function(String route) onTap;
  const HomeMenuGrid({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: homeMenuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final item = homeMenuItems[index];
        final isSpecial = item.route == '/dua-walidi';
        return _MenuTile(item: item, isSpecial: isSpecial, onTap: () => onTap(item.route));
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final MenuItemData item;
  final bool isSpecial;
  final VoidCallback onTap;

  const _MenuTile({required this.item, required this.isSpecial, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.navyCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSpecial ? AppColors.gold : AppColors.surfaceBorder,
            width: isSpecial ? 1 : 0.6,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: AppColors.gold, size: 24),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: AppTextStyles.menuLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
