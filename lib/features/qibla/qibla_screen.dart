import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../prayer_times/services/location_service.dart';
import '../prayer_times/services/prayer_times_service.dart';

/// شاشة القبلة — بوصلة حقيقية حية تعتمد على حساس المغناطيسية بالجهاز
/// (flutter_compass) مدمجة مع زاوية القبلة المحسوبة من موقع المستخدم
/// الفعلي (adhan_dart). الإبرة الذهبية تدور لحظيًا مع حركة الجهاز.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late Future<double?> _bearingFuture; // زاوية القبلة من الشمال، أو null لو الموقع مرفوض
  bool _isFallback = false;

  @override
  void initState() {
    super.initState();
    _bearingFuture = _loadBearing();
  }

  Future<double?> _loadBearing() async {
    try {
      final location = await LocationService.getCurrentLocation();
      return PrayerTimesCalculationService.qiblaBearing(location);
    } on LocationPermissionDeniedException {
      _isFallback = true;
      return PrayerTimesCalculationService.qiblaBearing(LocationService.meccaFallback);
    }
  }

  void _retry() {
    _isFallback = false;
    setState(() => _bearingFuture = _loadBearing());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('اتجاه القبلة', style: AppTextStyles.h2)),
      body: SafeArea(
        child: FutureBuilder<double?>(
          future: _bearingFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _ErrorState(onRetry: _retry);
            }
            return _LiveCompass(qiblaBearing: snapshot.data!, isFallback: _isFallback, onRetry: _retry);
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_rounded, color: AppColors.gold, size: 32),
            const SizedBox(height: 14),
            Text('تعذّر تحديد اتجاه القبلة', style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'تأكد من تفعيل خدمة الموقع ومنح الإذن، ثم أعد المحاولة.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.gold, width: 0.7),
                foregroundColor: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveCompass extends StatelessWidget {
  final double qiblaBearing;
  final bool isFallback;
  final VoidCallback onRetry;

  const _LiveCompass({required this.qiblaBearing, required this.isFallback, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.heading == null) {
          // بعض الأجهزة (خصوصًا الرخيصة) ما فيها حساس مغناطيسية أصلًا.
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sensors_off_rounded, color: AppColors.gold, size: 32),
                  const SizedBox(height: 14),
                  Text('جهازك لا يدعم حساس البوصلة', style: AppTextStyles.h3, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    'اتجاه القبلة من موقعك: ${qiblaBearing.round()}° من الشمال.',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final heading = snapshot.data!.heading!;
        // زاوية الإبرة = فرق اتجاه القبلة عن اتجاه الجهاز الحالي.
        final needleAngle = (qiblaBearing - heading) * (pi / 180);
        final aligned = (qiblaBearing - heading).abs() % 360 < 3 ||
            (qiblaBearing - heading).abs() % 360 > 357;

        return Column(
          children: [
            if (isFallback)
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
                          'لم يتم تفعيل إذن الموقع — الاتجاه معروض لمكة المكرمة وليس موقعك.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            Text('${heading.round()}°', style: AppTextStyles.counterLarge.copyWith(fontSize: 32)),
            const SizedBox(height: 6),
            Text('اتجاه جهازك الحالي', style: AppTextStyles.caption),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -heading * (pi / 180),
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surfaceBorder, width: 1),
                        color: AppColors.navyCard,
                      ),
                      child: CustomPaint(size: const Size(260, 260), painter: _CompassTicksPainter()),
                    ),
                  ),
                  Transform.rotate(
                    angle: needleAngle,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mosque_rounded,
                          color: aligned ? AppColors.success : AppColors.gold,
                          size: 28,
                        ),
                        Container(
                          width: 3,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                aligned ? AppColors.success : AppColors.gold,
                                (aligned ? AppColors.success : AppColors.gold).withOpacity(0.1),
                              ],
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
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              aligned ? 'أنت متجه الآن نحو القبلة ✓' : 'وجّه جهازك نحو المؤشر الذهبي',
              style: AppTextStyles.bodySecondary.copyWith(
                color: aligned ? AppColors.success : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('تحديث الموقع', style: AppTextStyles.button),
            ),
            const Spacer(),
          ],
        );
      },
    );
  }
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
