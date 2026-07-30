import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import 'models/prayer_time_model.dart';
import 'providers/prayer_times_provider.dart';

/// شاشة أوقات الصلاة — مربوطة بالموقع الجغرافي الفعلي عبر Geolocator
/// وحساب حقيقي لأوقات الصلاة عبر adhan_dart (طريقة رابطة العالم الإسلامي).
class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(prayerTimesProvider);
    // نبضة كل ثانية تجبر إعادة بناء العداد التنازلي دون إعادة جلب الموقع.
    ref.watch(prayerTimesTickProvider);

    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(
        title: Text('أوقات الصلاة', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () => ref.invalidate(prayerTimesProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: asyncState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (err, st) => _ErrorState(onRetry: () => ref.invalidate(prayerTimesProvider)),
          data: (state) => _PrayerTimesBody(state: state, onRefresh: () => ref.invalidate(prayerTimesProvider)),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_rounded, color: AppColors.gold, size: 32),
            const SizedBox(height: 12),
            Text('تعذّر تحديد موقعك', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'تأكد من تفعيل خدمة الموقع ومنح إذن الوصول للتطبيق من إعدادات الجهاز.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.gold, width: 0.7),
                foregroundColor: AppColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: Text('فتح إعدادات التطبيق', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimesBody extends StatefulWidget {
  final PrayerTimesState state;
  final VoidCallback onRefresh;
  const _PrayerTimesBody({required this.state, required this.onRefresh});

  @override
  State<_PrayerTimesBody> createState() => _PrayerTimesBodyState();
}

class _PrayerTimesBodyState extends State<_PrayerTimesBody> {
  @override
  Widget build(BuildContext context) {
    final times = widget.state.times;
    final (nextName, remaining) = times.nextPrayer();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.state.isFallbackLocation)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              borderColor: AppColors.danger.withOpacity(0.6),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.danger, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لم يتم تفعيل إذن الموقع — الأوقات المعروضة الآن لمكة المكرمة وليست موقعك الفعلي.',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        GlassCard(
          glow: true,
          child: Column(
            children: [
              Text('الصلاة القادمة', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(nextName, style: AppTextStyles.h1.copyWith(color: AppColors.gold)),
              const SizedBox(height: 4),
              Text(_fmt(remaining), style: AppTextStyles.counterLarge),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: times
                .asList()
                .map((p) => _PrayerRow(entry: p, isNext: p.name == nextName))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.notifications_active_outlined),
          label: const Text('إعدادات الأذان'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.gold, width: 0.7),
            foregroundColor: AppColors.gold,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _PrayerRow extends StatelessWidget {
  final PrayerTimeEntry entry;
  final bool isNext;
  const _PrayerRow({required this.entry, required this.isNext});

  IconData get _icon {
    switch (entry.icon) {
      case 'fajr':
        return Icons.nightlight_round;
      case 'sunrise':
        return Icons.wb_twilight_rounded;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.light_mode_outlined;
      case 'maghrib':
        return Icons.wb_twilight_rounded;
      default:
        return Icons.dark_mode_outlined;
    }
  }

  String _time(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceBorder.withOpacity(0.5), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(_icon, color: isNext ? AppColors.gold : AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.name,
              style: AppTextStyles.body.copyWith(
                color: isNext ? AppColors.gold : AppColors.textPrimary,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          if (isNext) const Icon(Icons.notifications_active_rounded, color: AppColors.gold, size: 16),
          const SizedBox(width: 8),
          Text(_time(entry.time), style: AppTextStyles.body),
        ],
      ),
    );
  }
}
