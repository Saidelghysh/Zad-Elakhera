import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// فاصل زخرفي ذهبي بشكل معيني في المنتصف — يُستخدم في السبلاش وعناوين الأقسام.
class GoldDivider extends StatelessWidget {
  final double width;
  const GoldDivider({super.key, this.width = 120});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _line(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 6,
              height: 6,
              color: AppColors.gold,
            ),
          ),
        ),
        _line(),
      ],
    );
  }

  Widget _line() => Container(
        width: width / 2,
        height: 0.6,
        color: AppColors.gold.withOpacity(0.5),
      );
}
