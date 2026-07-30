import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// شاشة القبلة — بوصلة حقيقية تعتمد على حساس المغناطيسية بالجهاز عبر
/// حزمة flutter_qiblah، مع معالجة كاملة لحالات: تعطيل GPS، رفض الإذن،
/// وعدم دعم الجهاز للحساس (بعض أجهزة أندرويد الرخيصة).
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  late Future<_QiblaReadiness> _readinessFuture;

  @override
  void initState() {
    super.initState();
    _readinessFuture = _checkReadiness();
  }

  Future<_QiblaReadiness> _checkReadiness() async {
    final hasSensor = await FlutterQiblah.androidDeviceSensorSupport() ?? true;
    if (!hasSensor) return _QiblaReadiness.noSensor;

    final status = await FlutterQiblah.checkLocationStatus();
    if (!status.enabled) return _QiblaReadiness.locationDisabled;
    if (status.status == LocationPermission.denied ||
        status.status == LocationPermission.deniedForever) {
      final granted = await FlutterQiblah.requestPermissions();
      if (granted != LocationPermission.always &&
          granted != LocationPermission.whileInUse) {
        return _QiblaReadiness.permissionDenied;
      }
    }
    return _QiblaReadiness.ready;
  }

  Future<void> _retry() async {
    setState(() => _readinessFuture = _checkReadiness());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('اتجاه القبلة', style: AppTextStyles.h2)),
      body: SafeArea(
        child: FutureBuilder<_QiblaReadiness>(
          future: _readinessFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
            }
            switch (snapshot.data!) {
              case _QiblaReadiness.ready:
                return const _QiblaCompass();
              case _QiblaReadiness.noSensor:
                return _QiblaMessage(
                  icon: Icons.sensors_off_rounded,
                  title: 'جهازك لا يدعم حساس البوصلة',
                  message: 'لا يمكن عرض البوصلة التفاعلية على هذا الجهاز.\n'
                      'الحل: عرض اتجاه القبلة عبر خريطة ثابتة بدلًا من البوصلة الحية.',
                  onRetry: _retry,
                );
              case _QiblaReadiness.locationDisabled:
                return _QiblaMessage(
                  icon: Icons.location_off_rounded,
                  title: 'خدمة الموقع غير مفعّلة',
                  message: 'فعّل خدمة الموقع (GPS) من إعدادات جهازك ثم أعد المحاولة.',
                  onRetry: _retry,
                );
              case _QiblaReadiness.permissionDenied:
                return _QiblaMessage(
                  icon: Icons.pin_drop_outlined,
                  title: 'إذن الموقع مطلوب',
                  message: 'نحتاج إذن الوصول لموقعك لحساب اتجاه القبلة الدقيق من مكانك.',
                  onRetry: _retry,
                );
            }
          },
        ),
      ),
    );
  }
}

enum _QiblaReadiness { ready, noSensor, locationDisabled, permissionDenied }

class _QiblaMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _QiblaMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.gold, size: 32),
            const SizedBox(height: 14),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
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

/// البوصلة الحية الفعلية — تدور بناءً على قراءات المغناطيسية الحقيقية للجهاز.
class _QiblaCompass extends StatelessWidget {
  const _QiblaCompass();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }

        final qiblah = snapshot.data!;
        // direction: اتجاه الشمال الحالي بالنسبة للجهاز (0-360).
        // qiblah: زاوية القبلة بالنسبة للشمال — الفرق بينهما هو ما يجب تدويره
        // في مؤشر القبلة كي يشير دائمًا نحو الكعبة بغض النظر عن دوران الجهاز.
        final needleAngle = (qiblah.qiblah) * (pi / 180) * -1;
        final compassAngle = (qiblah.direction) * (pi / 180) * -1;

        // فرق الزاوية يقارب الصفر عندما يكون الجهاز موجّهًا فعليًا نحو القبلة.
        final aligned = (qiblah.direction - qiblah.qiblah).abs() % 360 < 3;

        return Column(
          children: [
            const Spacer(),
            Text('${qiblah.direction.round()}°', style: AppTextStyles.counterLarge.copyWith(fontSize: 32)),
            const SizedBox(height: 24),
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // إطار البوصلة الثابت (تدور معالمه مع دوران الجهاز)
                  Transform.rotate(
                    angle: compassAngle,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surfaceBorder, width: 1),
                        color: AppColors.navyCard,
                      ),
                      child: CustomPaint(
                        size: const Size(260, 260),
                        painter: _CompassTicksPainter(),
                      ),
                    ),
                  ),
                  // إبرة القبلة — تشير دائمًا ناحية الكعبة الفعلية
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
              aligned ? 'أنت متجه الآن نحو القبلة' : 'وجّه جهازك نحو المؤشر الذهبي',
              style: AppTextStyles.bodySecondary.copyWith(
                color: aligned ? AppColors.success : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text('دقة الحساس المغناطيسي حسب الجهاز', style: AppTextStyles.caption),
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
      final outer = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
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
