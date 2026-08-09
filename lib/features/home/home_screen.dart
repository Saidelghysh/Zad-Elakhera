import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../dua_walidi/dua_counter_service.dart';
import '../prayer_times/providers/prayer_times_provider.dart';
import 'widgets/prayer_hero_card.dart';
import 'widgets/menu_grid.dart';
import 'widgets/dua_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    // عرض التذكير اليومي عند كل فتح للتطبيق (بعد بناء أول فريم).
    WidgetsBinding.instance.addPostFrameCallback((_) => _showReminder());
  }

  static const String _duaText =
      'اللهم اغفر للحاج عبدالحميد إبراهيم الغايش وارحمه وعافه واعف عنه '
      'وأكرم نزله ووسع مدخله، واغسله بالماء والثلج والبرد، ونقّه من الخطايا '
      'كما يُنقّى الثوب الأبيض من الدنس، واجعل قبره روضة من رياض الجنة.';

  bool _justPressed = false;

  void _showReminder() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: GlassCard(
              glow: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_rounded, color: AppColors.gold, size: 26),
                  const SizedBox(height: 10),
                  Text('دعاء لوالدي', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    'الحاج عبدالحميد إبراهيم الغايش رحمه الله',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _duaText,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.duaText.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await DuaCounterService.increment();
                        setDialogState(() => _justPressed = true);
                      },
                      icon: Icon(_justPressed ? Icons.check_rounded : Icons.favorite_rounded),
                      label: Text(_justPressed ? 'تقبّل الله دعاءك' : 'دعوت الآن'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('إغلاق', style: AppTextStyles.button),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((_) => _justPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final asyncPrayerState = ref.watch(prayerTimesProvider);

    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(
        title: Text('زاد الآخرة', style: AppTextStyles.h2.copyWith(color: AppColors.gold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              asyncPrayerState.when(
                loading: () => const PrayerHeroCard(
                  nextPrayerName: '...',
                  timeRemaining: Duration.zero,
                ),
                error: (err, st) => const PrayerHeroCard(
                  nextPrayerName: '—',
                  timeRemaining: Duration.zero,
                ),
                data: (state) {
                  final (name, remaining) = state.times.nextPrayer();
                  return PrayerHeroCard(nextPrayerName: name, timeRemaining: remaining);
                },
              ),
              const SizedBox(height: 18),
              HomeMenuGrid(onTap: (route) => context.push(route)),
              const SizedBox(height: 16),
              DuaBanner(onTap: () => context.push('/dua-walidi')),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 4) context.push('/settings');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'المكتبة'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'بحث'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
