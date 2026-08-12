import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../dua_walidi/dua_counter_service.dart';
import '../notifications/adhan_voice_model.dart';
import '../notifications/notification_service.dart';
import '../prayer_times/services/location_service.dart';
import '../prayer_times/services/prayer_times_service.dart';
import '../tasbeeh/tasbeeh_service.dart';
import 'settings_service.dart';

const Map<String, String> _calcMethodLabels = {
  'muslim_world_league': 'رابطة العالم الإسلامي',
  'umm_al_qura': 'أم القرى (مكة المكرمة)',
  'egyptian': 'الهيئة المصرية العامة للمساحة',
  'karachi': 'جامعة العلوم الإسلامية، كراتشي',
};

const List<int> _reminderOptions = [5, 10, 15, 20, 30];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _calcMethod;
  late String _madhab;
  late bool _athanNotifications;
  late String _adhanVoiceId;
  late int _reminderMinutes;
  late bool _openingDuaAudio;

  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _playingVoiceId;

  @override
  void initState() {
    super.initState();
    _calcMethod = SettingsService.getCalculationMethod();
    _madhab = SettingsService.getMadhab();
    _athanNotifications = SettingsService.getAthanNotificationsEnabled();
    _adhanVoiceId = SettingsService.getAdhanVoiceId();
    _reminderMinutes = SettingsService.getReminderMinutes();
    _openingDuaAudio = SettingsService.getOpeningDuaAudioEnabled();
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePreview(AdhanVoice voice) async {
    if (_playingVoiceId == voice.id) {
      await _previewPlayer.stop();
      setState(() => _playingVoiceId = null);
      return;
    }
    try {
      setState(() => _playingVoiceId = voice.id);
      await _previewPlayer.setUrl(voice.url);
      await _previewPlayer.play();
      _previewPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed && mounted) {
          setState(() => _playingVoiceId = null);
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _playingVoiceId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تشغيل هذا الصوت، تأكد من اتصالك بالإنترنت.')),
        );
      }
    }
  }

  Future<void> _rescheduleNotifications() async {
    if (!_athanNotifications) {
      await NotificationService.cancelAll();
      return;
    }
    try {
      await NotificationService.init();
      await NotificationService.requestPermission();
      final location = await LocationService.getCurrentLocation();
      final times = PrayerTimesCalculationService.calculate(location);
      await NotificationService.scheduleForToday(
        times,
        reminderMinutes: _reminderMinutes,
        adhanVoiceId: _adhanVoiceId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم جدولة تنبيهات اليوم بنجاح')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّرت جدولة التنبيهات — تأكد من إذن الموقع والإشعارات')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('الإعدادات', style: AppTextStyles.h2)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionTitle('أوقات الصلاة'),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('طريقة الحساب', style: AppTextStyles.body),
                  const SizedBox(height: 6),
                  DropdownButton<String>(
                    value: _calcMethod,
                    dropdownColor: AppColors.navyCard,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    style: AppTextStyles.body,
                    items: _calcMethodLabels.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) async {
                      if (value == null) return;
                      await SettingsService.setCalculationMethod(value);
                      setState(() => _calcMethod = value);
                      _rescheduleNotifications();
                    },
                  ),
                  const SizedBox(height: 14),
                  Text('المذهب (يؤثر على وقت العصر)', style: AppTextStyles.body),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ChoicePill(
                          label: 'شافعي',
                          selected: _madhab == 'shafi',
                          onTap: () async {
                            await SettingsService.setMadhab('shafi');
                            setState(() => _madhab = 'shafi');
                            _rescheduleNotifications();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ChoicePill(
                          label: 'حنفي',
                          selected: _madhab == 'hanafi',
                          onTap: () async {
                            await SettingsService.setMadhab('hanafi');
                            setState(() => _madhab = 'hanafi');
                            _rescheduleNotifications();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('إشعارات الأذان'),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.gold,
                    title: Text('تفعيل تنبيهات الصلاة', style: AppTextStyles.body),
                    subtitle: Text(
                      'تنبيه قبل الصلاة + إشعار عند دخول الوقت (تُجدَّد يوميًا عند فتح التطبيق).',
                      style: AppTextStyles.caption,
                    ),
                    value: _athanNotifications,
                    onChanged: (value) async {
                      await SettingsService.setAthanNotificationsEnabled(value);
                      setState(() => _athanNotifications = value);
                      _rescheduleNotifications();
                    },
                  ),
                  if (_athanNotifications) ...[
                    const SizedBox(height: 10),
                    Divider(color: AppColors.surfaceBorder.withOpacity(0.5)),
                    const SizedBox(height: 10),
                    Text('التنبيه قبل الصلاة بـ', style: AppTextStyles.body),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _reminderOptions.map((m) {
                        final selected = _reminderMinutes == m;
                        return ChoiceChip(
                          label: Text('$m د'),
                          selected: selected,
                          onSelected: (_) async {
                            await SettingsService.setReminderMinutes(m);
                            setState(() => _reminderMinutes = m);
                            _rescheduleNotifications();
                          },
                          backgroundColor: AppColors.navyCardAlt,
                          selectedColor: AppColors.gold.withOpacity(0.25),
                          labelStyle: AppTextStyles.caption.copyWith(
                            color: selected ? AppColors.gold : AppColors.textMuted,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await NotificationService.sendTestNotification(_adhanVoiceId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('راقب شاشة جوالك خلال ١٠ ثوانٍ...')),
                            );
                          }
                        },
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: const Text('اختبار الإشعار الآن'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.gold, width: 0.7),
                          foregroundColor: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('صوت الأذان'),
            const SizedBox(height: 4),
            Text('اختر صوت المؤذن، واضغط ▶ للاستماع قبل الاختيار', style: AppTextStyles.caption),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: adhanVoices.map((voice) {
                  final selected = _adhanVoiceId == voice.id;
                  final playing = _playingVoiceId == voice.id;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () async {
                      await SettingsService.setAdhanVoiceId(voice.id);
                      setState(() => _adhanVoiceId = voice.id);
                      _rescheduleNotifications();
                    },
                    leading: Icon(
                      selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: selected ? AppColors.gold : AppColors.textMuted,
                    ),
                    title: Text(voice.name, style: AppTextStyles.body),
                    trailing: IconButton(
                      icon: Icon(
                        playing ? Icons.stop_circle_rounded : Icons.play_circle_outline_rounded,
                        color: AppColors.gold,
                      ),
                      onPressed: () => _togglePreview(voice),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('صوت الفتح'),
            const SizedBox(height: 10),
            GlassCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.gold,
                title: Text('تشغيل دعاء الوالدين عند فتح التطبيق', style: AppTextStyles.body),
                subtitle: Text(
                  '"رب ارحمهما كما ربياني صغيرًا" (سورة الإسراء ٢٤) بصوت العفاسي.',
                  style: AppTextStyles.caption,
                ),
                value: _openingDuaAudio,
                onChanged: (value) async {
                  await SettingsService.setOpeningDuaAudioEnabled(value);
                  setState(() => _openingDuaAudio = value);
                },
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('البيانات'),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.refresh_rounded, color: AppColors.gold),
                    title: Text('تصفير عداد التسبيح الحالي', style: AppTextStyles.body),
                    onTap: () async {
                      await TasbeehService.reset();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تصفير عداد التسبيح')),
                        );
                      }
                    },
                  ),
                  Divider(color: AppColors.surfaceBorder.withOpacity(0.5)),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.gold),
                    title: Text('إجمالي دعوات "دعاء لوالدي"', style: AppTextStyles.body),
                    trailing: Text('${DuaCounterService.getCount()}', style: AppTextStyles.counterMedium),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('عن التطبيق'),
            const SizedBox(height: 10),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('زاد الآخرة', style: AppTextStyles.h3),
                  const SizedBox(height: 6),
                  Text(
                    'صدقة جارية على روح الحاج عبدالحميد إبراهيم الغايش رحمه الله.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 6),
                  Text('الإصدار 1.0.0', style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.h3);
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withOpacity(0.15) : AppColors.navyCardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.gold : AppColors.surfaceBorder, width: 0.8),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(color: selected ? AppColors.gold : AppColors.textPrimary),
        ),
      ),
    );
  }
}
