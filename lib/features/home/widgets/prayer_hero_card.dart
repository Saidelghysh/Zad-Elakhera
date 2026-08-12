import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mosque_silhouette_background.dart';
import '../hero_phrases.dart';

/// بطاقة البطل في الشاشة الرئيسية — مصغّرة، تعرض ذكر أو صيغة صلاة على
/// النبي ﷺ عشوائية (تتجدد كل فتحة)، واسم الصلاة القادمة وعدّادها التنازلي.
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
  late final String _phrase;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timeRemaining;
    _phrase = HeroPhrases.random();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant PrayerHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nextPrayerName != widget.nextPrayerName ||
        oldWidget.timeRemaining != widget.timeRemaining) {
      setState(() => _remaining = widget.timeRemaining);
    }
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
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.4,
              colors: [AppColors.gold.withOpacity(0.10), Colors.transparent],
            ),
          ),
          child: const MosqueSilhouetteBackground(height: 100, opacity: 0.22),
        ),
        GlassCard(
          glow: true,
          borderColor: AppColors.gold.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Column(
            children: [
              Text(
                _phrase,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.gold, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Divider(color: AppColors.surfaceBorder.withOpacity(0.6), height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('الصلاة القادمة: ', style: AppTextStyles.caption),
                  Text(widget.nextPrayerName, style: AppTextStyles.h3.copyWith(color: AppColors.gold)),
                ],
              ),
              const SizedBox(height: 4),
              Text(_fmt(_remaining), style: AppTextStyles.counterLarge.copyWith(fontSize: 24)),
            ],
          ),
        ),
      ],
    );
  }
}
