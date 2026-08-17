import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../dua_walidi/dua_counter_service.dart';
import '../notifications/notification_service.dart';
import 'opening_dua_audio_service.dart';
import '../prayer_times/providers/prayer_times_provider.dart';
import '../settings/settings_service.dart';
import 'widgets/prayer_hero_card.dart';
import 'widgets/menu_grid.dart';
import 'widgets/dua_banner.dart';
import 'widgets/live_radio_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  bool _notificationsScheduledThisSession = false;

  @override
  void initState() {
    super.initState();
    // عرض التذكير اليومي عند كل فتح للتطبيق (بعد بناء أول فريم).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showReminder();
      if (SettingsService.getOpeningDuaAudioEnabled()) {
        OpeningDuaAudioService.playOnce();
      }
    });
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
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 3, 2, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السلام عليكم',
                      style: AppTextStyles.h1.copyWith(color: AppColors.gold, fontSize: 25),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'نسأل الله أن يتقبل منا ومنكم صالح الأعمال',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
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
                  if (!_notificationsScheduledThisSession &&
                      SettingsService.getAthanNotificationsEnabled()) {
                    _notificationsScheduledThisSession = true;
                    NotificationService.init().then((_) {
                      NotificationService.scheduleForToday(
                        state.times,
                        reminderMinutes: SettingsService.getReminderMinutes(),
                        adhanVoiceId: SettingsService.getAdhanVoiceId(),
                      );
                    });
                  }
                  return PrayerHeroCard(nextPrayerName: name, timeRemaining: remaining);
                },
              ),
              const SizedBox(height: 12),
              const LiveRadioBanner(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.surfaceBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('خدمات زاد الآخرة', style: AppTextStyles.h3.copyWith(color: AppColors.gold)),
                  ),
                  Expanded(child: Divider(color: AppColors.surfaceBorder)),
                ],
              ),
              const SizedBox(height: 12),
              HomeMenuGrid(onTap: (route) => context.push(route)),
              const SizedBox(height: 14),
              const _SadaqaCard(),
              const SizedBox(height: 12),
              DuaBanner(onTap: () => context.push('/dua-walidi')),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 1) {
            context.push('/library');
          } else if (i == 2) {
            context.push('/dua-walidi');
          } else if (i == 3) {
            context.push('/quran');
          } else if (i == 4) {
            context.push('/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: 'المكتبة'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), label: 'دعاء'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'القرآن'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'حسابي'),
        ],
      ),
    );
  }
}

class _SadaqaCard extends StatelessWidget {
  const _SadaqaCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/dua-walidi'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.heroGradient,
          border: Border.all(color: AppColors.gold.withOpacity(0.65)),
        ),
        child: Row(
          children: [
            const Icon(Icons.volunteer_activism_rounded, color: AppColors.gold, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('صدقة جارية على روح والدي', style: AppTextStyles.h3.copyWith(color: AppColors.gold)),
                  const SizedBox(height: 3),
                  Text('الحاج عبدالحميد إبراهيم الغايش رحمه الله', style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}
