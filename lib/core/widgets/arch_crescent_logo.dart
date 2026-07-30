import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// شعار متجه (Vector) مرسوم بالكود: قوس إسلامي زخرفي + مصحف مفتوح + هلال.
/// لا يعتمد على أي صورة خارجية — مناسب للسبلاش والشاشة الرئيسية.
class ArchCrescentLogo extends StatelessWidget {
  final double size;
  const ArchCrescentLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(
        painter: _ArchCrescentPainter(),
      ),
    );
  }
}

class _ArchCrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.014
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Islamic pointed arch outline
    final archPath = Path();
    archPath.moveTo(w * 0.12, h * 0.62);
    archPath.lineTo(w * 0.12, h * 0.34);
    archPath.quadraticBezierTo(w * 0.12, h * 0.14, w * 0.5, h * 0.06);
    archPath.quadraticBezierTo(w * 0.88, h * 0.14, w * 0.88, h * 0.34);
    archPath.lineTo(w * 0.88, h * 0.62);
    canvas.drawPath(archPath, gold);

    // Base line
    canvas.drawLine(Offset(w * 0.08, h * 0.62), Offset(w * 0.92, h * 0.62), gold);

    // Crescent moon at the top of the arch
    final crescentCenter = Offset(w * 0.5, h * 0.22);
    final crescentRadius = w * 0.09;
    final outerCircle = Path()
      ..addOval(Rect.fromCircle(center: crescentCenter, radius: crescentRadius));
    final innerCircle = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(crescentCenter.dx + crescentRadius * 0.55, crescentCenter.dy - crescentRadius * 0.15),
        radius: crescentRadius * 0.85,
      ));
    final crescentPath = Path.combine(PathOperation.difference, outerCircle, innerCircle);
    canvas.drawPath(crescentPath, Paint()..color = AppColors.gold);

    // Open Quran (two pages) centered lower in the arch
    final bookWidth = w * 0.5;
    final bookHeight = h * 0.16;
    final bookTop = h * 0.36;
    final centerX = w * 0.5;

    final leftPage = Path();
    leftPage.moveTo(centerX, bookTop);
    leftPage.quadraticBezierTo(centerX - bookWidth * 0.5, bookTop - bookHeight * 0.1, centerX - bookWidth * 0.5, bookTop + bookHeight * 0.15);
    leftPage.lineTo(centerX - bookWidth * 0.5, bookTop + bookHeight);
    leftPage.quadraticBezierTo(centerX - bookWidth * 0.2, bookTop + bookHeight * 0.85, centerX, bookTop + bookHeight * 0.98);
    leftPage.close();

    final rightPage = Path();
    rightPage.moveTo(centerX, bookTop);
    rightPage.quadraticBezierTo(centerX + bookWidth * 0.5, bookTop - bookHeight * 0.1, centerX + bookWidth * 0.5, bookTop + bookHeight * 0.15);
    rightPage.lineTo(centerX + bookWidth * 0.5, bookTop + bookHeight);
    rightPage.quadraticBezierTo(centerX + bookWidth * 0.2, bookTop + bookHeight * 0.85, centerX, bookTop + bookHeight * 0.98);
    rightPage.close();

    final pagePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.011;

    canvas.drawPath(leftPage, pagePaint);
    canvas.drawPath(rightPage, pagePaint);
    canvas.drawLine(
      Offset(centerX, bookTop),
      Offset(centerX, bookTop + bookHeight * 0.98),
      pagePaint,
    );

    // Decorative page lines
    for (var i = 1; i <= 3; i++) {
      final y = bookTop + bookHeight * 0.25 * i;
      canvas.drawLine(
        Offset(centerX - bookWidth * 0.35, y),
        Offset(centerX - bookWidth * 0.08, y),
        pagePaint..strokeWidth = size.width * 0.005,
      );
      canvas.drawLine(
        Offset(centerX + bookWidth * 0.08, y),
        Offset(centerX + bookWidth * 0.35, y),
        pagePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
