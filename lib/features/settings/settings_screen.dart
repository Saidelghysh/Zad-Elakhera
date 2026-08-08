import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../dua_walidi/dua_counter_service.dart';
import '../tasbeeh/tasbeeh_service.dart';
import 'settings_service.dart';

const Map<String, String> _calcMethodLabels = {
  'muslim_world_league': 'رابطة العالم الإسلامي',
  'umm_al_qura': 'أم القرى (مكة المكرمة)',
  'egyptian': 'الهيئة المصرية العامة للمساحة',
  'karachi': 'جامعة العلوم الإسلامية، كراتشي',
};

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _calcMethod;
  late String _madhab;
  late bool _athanNotifications;

  @override
  void initState() {
    super.initState();
    _calcMethod = SettingsService.getCalculationMethod();
    _madhab = SettingsService.getMadhab();
    _athanNotifications = SettingsService.getAthanNotificationsEnabled();
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
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle('الإشعارات'),
            const SizedBox(height: 10),
            GlassCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.gold,
                title: Text('تنبيه دخول وقت الصلاة', style: AppTextStyles.body),
                subtitle: Text(
                  'يحتاج تفعيل هذا لاحقًا بربط مكتبة إشعارات مخصصة — الخيار محفوظ الآن كتفضيل فقط.',
                  style: AppTextStyles.caption,
                ),
                value: _athanNotifications,
                onChanged: (value) async {
                  await SettingsService.setAthanNotificationsEnabled(value);
                  setState(() => _athanNotifications = value);
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
