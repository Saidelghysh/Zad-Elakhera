import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';

/// بطاقة البطل في الشاشة الرئيسية: ترحيب + اسم الصلاة القادمة + عداد تنازلي.
/// تستقبل بيانات الصلاة القادمة من [PrayerTimesProvider] (يُوصَل لاحقًا ببيانات حقيقية).
class PrayerHeroCard extends StatefulWidget {
  final String nextPrayerName;
  final Duration timeRemaining;

  const PrayerHeroCard({
    super.key,
    required this.nextPrayerName,
    required this.timeRemaining,
  });

  @override
  State<PrayerHeroCard> createState() => _PrayerHeroCardState();
}

class _PrayerHeroCardState extends State<PrayerHeroCard> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timeRemaining;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glow: true,
      borderColor: AppColors.gold.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      child: Column(
        children: [
          Text('السلام عليكم', style: AppTextStyles.h3.copyWith(fontSize: 17)),
          const SizedBox(height: 6),
          Text(
            'نسأل الله أن يتقبل منا ومنكم صالح الأعمال',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.surfaceBorder.withOpacity(0.6), height: 1),
          const SizedBox(height: 14),
          Text('الصلاة القادمة', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(widget.nextPrayerName, style: AppTextStyles.h1.copyWith(color: AppColors.gold)),
          const SizedBox(height: 6),
          Text(_fmt(_remaining), style: AppTextStyles.counterLarge),
        ],
      ),
    );
  }
}
