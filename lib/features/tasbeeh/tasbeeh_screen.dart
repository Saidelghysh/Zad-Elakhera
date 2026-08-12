import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'tasbeeh_service.dart';

const List<String> _adhkarChoices = [
  'سبحان الله',
  'الحمد لله',
  'الله أكبر',
  'لا إله إلا الله',
  'أستغفر الله',
];

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int _target = 33;
  int _dhikrIndex = 0;

  @override
  void initState() {
    super.initState();
    _target = TasbeehService.getTarget();
  }

  Future<void> _tap() async {
    final newCount = await TasbeehService.increment();
    HapticFeedback.lightImpact();
    if (newCount % _target == 0) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _reset() async {
    await TasbeehService.reset();
  }

  void _pickTarget() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.navyCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [33, 99, 100, 500, 1000].map((t) {
            return ChoiceChip(
              label: Text('$t'),
              selected: _target == t,
              onSelected: (_) async {
                await TasbeehService.setTarget(t);
                setState(() => _target = t);
                Navigator.pop(ctx);
              },
              backgroundColor: AppColors.navyCardAlt,
              selectedColor: AppColors.gold.withOpacity(0.25),
              labelStyle: AppTextStyles.body,
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(
        title: Text('التسبيح الرقمي', style: AppTextStyles.h2),
        actions: [
          IconButton(icon: const Icon(Icons.flag_outlined), onPressed: _pickTarget),
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _reset),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(_adhkarChoices.length, (i) {
                final selected = _dhikrIndex == i;
                return ChoiceChip(
                  label: Text(_adhkarChoices[i]),
                  selected: selected,
                  onSelected: (_) => setState(() => _dhikrIndex = i),
                  backgroundColor: AppColors.navyCard,
                  selectedColor: AppColors.gold.withOpacity(0.2),
                  labelStyle: AppTextStyles.caption.copyWith(
                    color: selected ? AppColors.gold : AppColors.textMuted,
                  ),
                );
              }),
            ),
            const Spacer(),
            // نستمع مباشرة لصندوق التخزين (Hive) بدل قيمة محفوظة بذاكرة الشاشة،
            // بحيث لو تغيّر العداد من مكان ثاني (زر التصفير بالإعدادات مثلًا)
            // ينعكس فورًا هنا بدون ما نحتاج نرجع لهذي الشاشة من جديد.
            ValueListenableBuilder<Box>(
              valueListenable: Hive.box(TasbeehService.boxName).listenable(),
              builder: (context, box, _) {
                final count = TasbeehService.getCount();
                final progress = _target == 0 ? 0.0 : (count % _target) / _target;
                return GestureDetector(
                  onTap: _tap,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: CircularProgressIndicator(
                            value: progress == 0 ? 1 : progress,
                            strokeWidth: 6,
                            backgroundColor: AppColors.surfaceBorder,
                            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                          ),
                        ),
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.navyCard,
                            border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$count', style: AppTextStyles.counterLarge.copyWith(fontSize: 40)),
                                const SizedBox(height: 4),
                                Text(_adhkarChoices[_dhikrIndex], style: AppTextStyles.bodySecondary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text('الهدف: $_target', style: AppTextStyles.caption),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text('اضغط في أي مكان بالدائرة للتسبيح', style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
    );
  }
}
