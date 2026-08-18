import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import 'models/surah_model.dart';
import 'services/quran_api_service.dart';

/// شاشة القرآن الكريم — قائمة السور الـ ١١٤، مع بحث سريع بالاسم أو الرقم.
/// عند اختيار سورة، ينتقل لشاشة القراءة (surah_detail_screen).
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late Future<List<SurahInfo>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = QuranApiService.getSurahList();
  }

  void _retry() => setState(() => _future = QuranApiService.getSurahList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('القرآن الكريم', style: AppTextStyles.h2)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v.trim()),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم السورة أو رقمها...',
                  hintStyle: AppTextStyles.caption,
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.navyCard,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.surfaceBorder.withOpacity(0.6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.surfaceBorder.withOpacity(0.6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.gold, width: 0.8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<SurahInfo>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded, color: AppColors.gold, size: 32),
                            const SizedBox(height: 12),
                            Text('تعذّر تحميل قائمة السور', style: AppTextStyles.h3),
                            const SizedBox(height: 6),
                            Text(
                              'تأكد من اتصالك بالإنترنت ثم أعد المحاولة.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('إعادة المحاولة'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.gold, width: 0.7),
                                foregroundColor: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final all = snapshot.data!;
                  final filtered = _query.isEmpty
                      ? all
                      : all.where((s) {
                          final q = _query.toLowerCase();
                          return s.name.contains(_query) ||
                              s.englishName.toLowerCase().contains(q) ||
                              s.number.toString() == _query;
                        }).toList();

                  final lastRead = QuranApiService.getLastRead();
                  SurahInfo? lastReadSurah;
                  if (lastRead != null) {
                    try {
                      lastReadSurah = all.firstWhere((s) => s.number == lastRead.$1);
                    } catch (_) {
                      lastReadSurah = null;
                    }
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: filtered.length + (lastReadSurah != null && _query.isEmpty ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      if (lastReadSurah != null && _query.isEmpty) {
                        if (i == 0) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push('/quran/${lastReadSurah.number}', extra: lastReadSurah),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.navyCardAlt,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.gold, width: 0.9),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_stories_rounded, color: AppColors.gold, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('متابعة القراءة', style: AppTextStyles.h3),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${lastReadSurah.name} — آية ${lastRead.$2}',
                                          style: AppTextStyles.caption,
                                        ),
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
                      final adjustedIndex = (lastReadSurah != null && _query.isEmpty) ? i - 1 : i;
                      final s = filtered[adjustedIndex];
                      return GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: InkWell(
                          onTap: () => context.push('/quran/${s.number}', extra: s),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                                ),
                                child: Text('${s.number}', style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.name, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${s.englishNameTranslation} · ${s.numberOfAyahs} آية',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                s.isMeccan ? Icons.mosque_outlined : Icons.location_city_outlined,
                                color: AppColors.textMuted,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
