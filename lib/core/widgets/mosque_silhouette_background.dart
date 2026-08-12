import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// سيلويت مسجد مزخرف (قبة + مئذنتان + هلال) مرسوم بالكامل بالكود — يُستخدم
/// كخلفية زخرفية خلف البطاقات الرئيسية لإعطاء إحساس فخامة شبيه بالتطبيقات
/// الكبرى، بدون الاعتماد على أي صورة فوتوغرافية خارجية أو محتوى محمي.
class MosqueSilhouetteBackground extends StatelessWidget {
  final double height;
  final double opacity;

  const MosqueSilhouetteBackground({super.key, this.height = 140, this.opacity = 0.22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(painter: _MosquePainter()),
      ),
    );
  }
}

class _MosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.gold.withOpacity(0.9), AppColors.gold.withOpacity(0.1)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final w = size.width;
    final h = size.height;
    final baseY = h * 0.92;

    final path = Path();
    path.moveTo(0, baseY);

    // مئذنة يسار
    _drawMinaret(path, w * 0.10, baseY, w * 0.05, h * 0.55);

    path.lineTo(w * 0.22, baseY);
    path.lineTo(w * 0.22, h * 0.55);

    // قبة مركزية
    path.cubicTo(
      w * 0.22, h * 0.22,
      w * 0.40, h * 0.05,
      w * 0.5, h * 0.05,
    );
    path.cubicTo(
      w * 0.60, h * 0.05,
      w * 0.78, h * 0.22,
      w * 0.78, h * 0.55,
    );

    path.lineTo(w * 0.78, baseY);

    // مئذنة يمين
    _drawMinaret(path, w * 0.90, baseY, w * 0.05, h * 0.55);

    path.lineTo(w, baseY);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawPath(path, fill);

    // خط قاعدة رفيع ذهبي
    final basePaint = Paint()
      ..color = AppColors.gold.withOpacity(0.5)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(0, baseY), Offset(w, baseY), basePaint);
  }

  void _drawMinaret(Path path, double cx, double baseY, double width, double towerHeight) {
    final left = cx - width / 2;
    final right = cx + width / 2;
    final top = baseY - towerHeight;

    path.lineTo(left, baseY);
    path.lineTo(left, top + width * 0.6);
    path.lineTo(cx, top);
    path.lineTo(right, top + width * 0.6);
    path.lineTo(right, baseY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
