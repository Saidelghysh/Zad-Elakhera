import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gold_divider.dart';
import 'dua_counter_service.dart';

class DuaWalidiScreen extends StatefulWidget {
  const DuaWalidiScreen({super.key});

  @override
  State<DuaWalidiScreen> createState() => _DuaWalidiScreenState();
}

class _DuaWalidiScreenState extends State<DuaWalidiScreen> {
  late int _count;
  bool _justPressed = false;

  static const String duaText =
      'اللهم اغفر للحاج عبدالحميد إبراهيم الغايش وارحمه وعافه واعف عنه '
      'وأكرم نزله ووسع مدخله، واغسله بالماء والثلج والبرد، ونقّه من الخطايا '
      'كما يُنقّى الثوب الأبيض من الدنس، واجعل قبره روضة من رياض الجنة.';

  @override
  void initState() {
    super.initState();
    _count = DuaCounterService.getCount();
  }

  Future<void> _onDuaPressed() async {
    final newValue = await DuaCounterService.increment();
    setState(() {
      _count = newValue;
      _justPressed = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _justPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('دعاء لوالدي', style: AppTextStyles.h2)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Icon(Icons.favorite_rounded, color: AppColors.gold, size: 34),
              const SizedBox(height: 14),
              Text('صدقة جارية على روح', style: AppTextStyles.bodySecondary),
              const SizedBox(height: 4),
              Text(
                'الحاج عبدالحميد إبراهيم الغايش',
                style: AppTextStyles.h1.copyWith(color: AppColors.gold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const GoldDivider(width: 100),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: GlassCard(
                    glow: true,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      duaText,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.duaText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onDuaPressed,
                  icon: const Icon(Icons.favorite_rounded),
                  label: const Text('دعوت الآن'),
                ),
              ),
              const SizedBox(height: 16),
              Text('إجمالي الدعوات', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Bounce(
                animate: _justPressed,
                duration: const Duration(milliseconds: 500),
                child: Text(_formatNumber(_count), style: AppTextStyles.counterLarge),
              ),
              const SizedBox(height: 6),
              Text('جزاكم الله خيرًا', style: AppTextStyles.bodySecondary),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
