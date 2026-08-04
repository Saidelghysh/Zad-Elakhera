import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/arch_crescent_logo.dart';
import '../../core/widgets/gold_divider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.7, curve: Curves.easeOut));
    _scale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Gold particle field (subtle dots scattered across the screen)
          const Positioned.fill(child: _GoldParticles()),

          FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ArchCrescentLogo(size: 130),
                  const SizedBox(height: 18),
                  Text('زاد الآخرة', style: AppTextStyles.appTitle),
                  const SizedBox(height: 10),
                  const GoldDivider(width: 90),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'صدقة جارية على روح\nالحاج عبدالحميد إبراهيم الغايش رحمه الله',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.appSubtitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// طبقة جزيئات ذهبية ثابتة العشوائية (seeded) تعطي إحساس فخامة بدون أصول خارجية.
class _GoldParticles extends StatelessWidget {
  const _GoldParticles();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ParticlePainter());
  }
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // seeded for a stable, elegant pattern
    final paint = Paint()..color = AppColors.gold.withOpacity(0.35);

    for (int i = 0; i < 60; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.4 + 0.3;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
