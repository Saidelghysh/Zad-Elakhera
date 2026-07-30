import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import 'data/azkar_data.dart';

/// شاشة الأذكار: تبويبات للفئات (صباح/مساء/نوم/سفر/صلاة) وقائمة أذكار
/// كل ذكر له عداد تكرار خاص به يُحفظ محليًا (تقدّم المستخدم يُصفّر يوميًا).
class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  int _tabIndex = 0;
  late List<int> _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = morningAzkar.items.map((e) => e.repeat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('الأذكار', style: AppTextStyles.h2)),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: azkarCategoryNames.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = _tabIndex == i;
                  return ChoiceChip(
                    label: Text(azkarCategoryNames[i]),
                    selected: selected,
                    onSelected: (_) => setState(() => _tabIndex = i),
                    backgroundColor: AppColors.navyCard,
                    selectedColor: AppColors.gold.withOpacity(0.2),
                    labelStyle: AppTextStyles.caption.copyWith(
                      color: selected ? AppColors.gold : AppColors.textMuted,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: morningAzkar.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final item = morningAzkar.items[i];
                  final left = _remaining[i];
                  return GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.text, style: AppTextStyles.duaText, textAlign: TextAlign.right),
                        if (item.source != null) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('(${item.source})', style: AppTextStyles.caption),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share_outlined, size: 18),
                              color: AppColors.textMuted,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite_border_rounded, size: 18),
                              color: AppColors.textMuted,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.repeat_rounded, size: 18),
                              color: AppColors.textMuted,
                              onPressed: () => setState(() => _remaining[i] = item.repeat),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: left > 0 ? () => setState(() => _remaining[i] = left - 1) : null,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: left == 0 ? AppColors.success.withOpacity(0.15) : AppColors.navyCardAlt,
                                  border: Border.all(
                                    color: left == 0 ? AppColors.success : AppColors.gold,
                                    width: 0.8,
                                  ),
                                ),
                                child: Center(
                                  child: left == 0
                                      ? const Icon(Icons.check_rounded, color: AppColors.success, size: 18)
                                      : Text('$left', style: AppTextStyles.counterMedium.copyWith(fontSize: 15)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
