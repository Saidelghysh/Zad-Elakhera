import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../dua_walidi/dua_counter_service.dart';
import '../notifications/notification_service.dart';
import '../prayer_times/providers/prayer_times_provider.dart';
import '../settings/settings_service.dart';

/// Premium Home Screen for Zad Al-Akhira.
/// Replace:
/// lib/features/home/home_screen.dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  bool _notificationsScheduledThisSession = false;
  bool _justPressed = false;

  static const String _duaText =
      'اللهم اغفر للحاج عبدالحميد إبراهيم الغايش وارحمه وعافه واعف عنه '
      'وأكرم نزله ووسع مدخله، واغسله بالماء والثلج والبرد، ونقّه من الخطايا '
      'كما يُنقّى الثوب الأبيض من الدنس، واجعل قبره روضة من رياض الجنة.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showReminder());
  }

  void _showReminder() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 22),
            child: GlassCard(
              glow: true,
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withOpacity(.10),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(.45),
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.gold,
                      size: 25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('دعاء لوالدي', style: AppTextStyles.h3.copyWith(fontSize: 18)),
                  const SizedBox(height: 5),
                  Text(
                    'الحاج عبدالحميد إبراهيم الغايش رحمه الله',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _duaText,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.duaText.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.goldButton,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.royalBlack,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          await DuaCounterService.increment();
                          setDialogState(() => _justPressed = true);
                        },
                        icon: Icon(
                          _justPressed
                              ? Icons.check_rounded
                              : Icons.favorite_rounded,
                        ),
                        label: Text(
                          _justPressed ? 'تقبّل الله دعاءك' : 'دعوت الآن',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
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
        backgroundColor: AppColors.royalBlack,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 72,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'زاد الآخرة',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.goldBright,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'زادٌ ليومٍ لا ينفع فيه إلا العمل',
              style: AppTextStyles.caption.copyWith(fontSize: 9.5),
            ),
          ],
        ),
        leading: _HeaderButton(
          icon: Icons.settings_outlined,
          onTap: () => context.push('/settings'),
        ),
        actions: [
          _HeaderButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionEyebrow(
                icon: Icons.auto_awesome_rounded,
                text: 'يومك مع الله',
              ),
              const SizedBox(height: 8),

              asyncPrayerState.when(
                loading: () => const _PrayerHeroCard(
                  nextPrayerName: '...',
                  timeRemaining: Duration.zero,
                ),
                error: (err, st) => const _PrayerHeroCard(
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
                        reminderMinutes:
                            SettingsService.getReminderMinutes(),
                        adhanVoiceId: SettingsService.getAdhanVoiceId(),
                      );
                    });
                  }

                  return _PrayerHeroCard(
                    nextPrayerName: name,
                    timeRemaining: remaining,
                  );
                },
              ),

              const SizedBox(height: 20),
              _SectionTitle(
                title: 'العبادات اليومية',
                subtitle: 'اختر ما تحب أن تبدأ به الآن',
              ),
              const SizedBox(height: 11),

              _HomeMenuGrid(
                onTap: (route) => context.push(route),
              ),

              const SizedBox(height: 18),

              _DuaBanner(
                onTap: () => context.push('/dua-walidi'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);

          if (index == 0) return;
          if (index == 4) {
            context.push('/settings');
          }
          // Other sections keep their current navigation behavior for now.
        },
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Material(
        color: AppColors.navyCard.withOpacity(.72),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              icon,
              color: AppColors.goldBright,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionEyebrow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SectionEyebrow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(.08),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: AppColors.gold.withOpacity(.22),
            ),
          ),
          child: Icon(icon, color: AppColors.gold, size: 15),
        ),
        const SizedBox(width: 9),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gold,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withOpacity(.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h2.copyWith(fontSize: 16)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textMuted,
          size: 13,
        ),
      ],
    );
  }
}

class _PrayerHeroCard extends StatefulWidget {
  final String nextPrayerName;
  final Duration timeRemaining;

  const _PrayerHeroCard({
    required this.nextPrayerName,
    required this.timeRemaining,
  });

  @override
  State<_PrayerHeroCard> createState() => _PrayerHeroCardState();
}

class _PrayerHeroCardState extends State<_PrayerHeroCard> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timeRemaining;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant _PrayerHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.nextPrayerName != widget.nextPrayerName ||
        oldWidget.timeRemaining != widget.timeRemaining) {
      _remaining = widget.timeRemaining;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: AppColors.heroGradient,
        border: Border.all(
          color: AppColors.gold.withOpacity(.48),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(.07),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -75,
            left: -65,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGlow,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGlow,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 17, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.wb_sunny_outlined,
                      color: AppColors.gold,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'السلام عليكم',
                      style: AppTextStyles.h3.copyWith(fontSize: 17),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(.22),
                        ),
                      ),
                      child: Text(
                        'وقت الصلاة',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  'نسأل الله أن يتقبل منا ومنكم صالح الأعمال',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: AppColors.surfaceBorder.withOpacity(.65),
                ),
                const Spacer(),
                Text(
                  'الصلاة القادمة',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.nextPrayerName,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.goldBright,
                    fontSize: 27,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _format(_remaining),
                  style: AppTextStyles.counterLarge.copyWith(
                    fontSize: 31,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final String route;
  final bool featured;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.route,
    this.featured = false,
  });
}

const List<_MenuItemData> _homeMenuItems = [
  _MenuItemData(
    icon: Icons.menu_book_rounded,
    label: 'القرآن الكريم',
    route: '/quran',
    featured: true,
  ),
  _MenuItemData(
    icon: Icons.headphones_rounded,
    label: 'التلاوات',
    route: '/recitations',
  ),
  _MenuItemData(
    icon: Icons.auto_stories_rounded,
    label: 'التفسير',
    route: '/tafsir',
  ),
  _MenuItemData(
    icon: Icons.mosque_rounded,
    label: 'أوقات الصلاة',
    route: '/prayer-times',
  ),
  _MenuItemData(
    icon: Icons.explore_rounded,
    label: 'القبلة',
    route: '/qibla',
  ),
  _MenuItemData(
    icon: Icons.self_improvement_rounded,
    label: 'الأذكار',
    route: '/azkar',
  ),
  _MenuItemData(
    icon: Icons.fiber_manual_record_rounded,
    label: 'التسبيح',
    route: '/tasbeeh',
  ),
  _MenuItemData(
    icon: Icons.record_voice_over_rounded,
    label: 'أحكام التجويد',
    route: '/tajweed',
  ),
  _MenuItemData(
    icon: Icons.accessibility_new_rounded,
    label: 'تعلم الصلاة',
    route: '/learn-salah',
  ),
];

class _HomeMenuGrid extends StatelessWidget {
  final void Function(String route) onTap;

  const _HomeMenuGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _homeMenuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .93,
      ),
      itemBuilder: (context, index) {
        final item = _homeMenuItems[index];
        return _MenuTile(
          item: item,
          onTap: () => onTap(item.route),
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItemData item;
  final VoidCallback onTap;

  const _MenuTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.gold.withOpacity(.10),
        highlightColor: AppColors.gold.withOpacity(.04),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.navyCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.featured
                  ? AppColors.gold.withOpacity(.55)
                  : AppColors.surfaceBorder.withOpacity(.75),
              width: item.featured ? 1 : .7,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.20),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (item.featured)
                Positioned(
                  top: -25,
                  right: -25,
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGlow,
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 47,
                      height: 47,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(.075),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withOpacity(.18),
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.featured
                            ? AppColors.goldBright
                            : AppColors.gold,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.menuLabel.copyWith(
                        fontSize: 11.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DuaBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _DuaBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                Color(0xFF171D3B),
                Color(0xFF0C1228),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.gold.withOpacity(.42),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withOpacity(.09),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(.22),
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.goldBright,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'صدقة جارية عن والدي',
                      style: AppTextStyles.h3.copyWith(fontSize: 14.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'اللهم اغفر له وارحمه واجعل قبره روضة من رياض الجنة',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.gold,
                  size: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  static const items = [
    (Icons.home_rounded, 'الرئيسية'),
    (Icons.grid_view_rounded, 'المكتبة'),
    (Icons.favorite_border_rounded, 'المفضلة'),
    (Icons.search_rounded, 'بحث'),
    (Icons.settings_outlined, 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080D1E),
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceBorder.withOpacity(.75),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = index == currentIndex;
              final item = items[index];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 7,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.gold.withOpacity(.07)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                      border: selected
                          ? Border.all(
                              color: AppColors.gold.withOpacity(.25),
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.$1,
                          size: 23,
                          color: selected
                              ? AppColors.goldBright
                              : AppColors.textMuted,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$2,
                          style: AppTextStyles.caption.copyWith(
                            color: selected
                                ? AppColors.gold
                                : AppColors.textMuted,
                            fontSize: 9.5,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
