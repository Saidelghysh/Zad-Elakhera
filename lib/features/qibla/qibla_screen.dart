import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../prayer_times/services/location_service.dart';
import '../prayer_times/services/prayer_times_service.dart';

/// شاشة القبلة — تعرض زاوية اتجاه القبلة المحسوبة من موقع المستخدم الفعلي
/// (عبر adhan_dart)، معروضة على بوصلة ثابتة الاتجاه (الشمال دائمًا للأعلى).
///
/// ملاحظة: النسخة السابقة كانت تستخدم حزمة flutter_qiblah لتدوير الإبرة مع
/// حركة الجهاز الفعلية عبر حساس المغناطيسية، لكن هذي الحزمة مهجورة وغير
/// متوافقة مع أحدث أدوات بناء أندرويد. للحصول على إبرة حية تتحرك مع الجهاز
/// لاحقًا، يمكن استبدالها بحزمة flutter_compass (تجيب اتجاه الشمال فقط من
/// الحساس) مع حساب الزاوية النسبية يدويًا من [bearing] أدناه.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late Future<_QiblaResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_QiblaResult> _load() async {
    try {
      final location = await LocationService.getCurrentLocation();
      final bearing = PrayerTimesCalculationService.qiblaBearing(location);
      return _QiblaResult(bearing: bearing, isFallback: false);
    } on LocationPermissionDeniedException {
      final bearing = PrayerTimesCalculationService.qiblaBearing(LocationService.meccaFallback);
      return _QiblaResult(bearing: bearing, isFallback: true);
    }
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('اتجاه القبلة', style: AppTextStyles.h2)),
      body: SafeArea(
        child: FutureBuilder<_QiblaResult>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _QiblaMessage(
                icon: Icons.error_outline_rounded,
                title: 'تعذّر حساب اتجاه القبلة',
                message: 'حدث خطأ غير متوقع. تأكد من تفعيل الموقع وإعطاء الإذن، ثم أعد المحاولة.',
                onRetry: _retry,
              );
            }
            final result = snapshot.data!;
            return Column(
              children: [
                if (result.isFallback)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.navyCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.danger.withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'لم يتم تفعيل إذن الموقع — الزاوية المعروضة لمكة المكرمة وليست موقعك الفعلي.',
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Spacer(),
                Text('${result.bearing.round()}°', style: AppTextStyles.counterLarge.copyWith(fontSize: 32)),
                const SizedBox(height: 6),
                Text('من الشمال باتجاه الكعبة', style: AppTextStyles.caption),
                const SizedBox(height: 24),
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surfaceBorder, width: 1),
                          color: AppColors.navyCard,
                        ),
                        child: CustomPaint(size: const Size(260, 260), painter: _CompassTicksPainter()),
                      ),
                      Transform.rotate(
                        angle: result.bearing * (pi / 180),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.mosque_rounded, color: AppColors.gold, size: 28),
                            Container(
                              width: 3,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [AppColors.gold, AppColors.gold.withOpacity(0.1)],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold),
                      ),
                      const Positioned(
                        top: 6,
                        child: Text('شمال', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'المؤشر الذهبي يشير لاتجاه القبلة بالنسبة للشمال. امسك جوالك بحيث تكون البوصلة '
                    'العادية بجواله متجهة شمالًا، ثم ابحث عن اتجاه المؤشر الذهبي.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text('تحديث الموقع', style: AppTextStyles.button),
                ),
                const Spacer(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QiblaResult {
  final double bearing;
  final bool isFallback;
  const _QiblaResult({required this.bearing, required this.isFallback});
}

class _CompassTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.4)
      ..strokeWidth = 1.5;

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * pi / 180;
      final isMajor = i % 9 == 0;
      final outer = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      final inner = Offset(
        center.dx + (radius - (isMajor ? 14 : 7)) * cos(angle),
        center.dy + (radius - (isMajor ? 14 : 7)) * sin(angle),
      );
      canvas.drawLine(outer, inner, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
