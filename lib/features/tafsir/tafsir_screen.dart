import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../quran/models/surah_model.dart';
import '../quran/services/quran_api_service.dart';

/// شاشة التفسير — قائمة السور نفسها المستخدمة بشاشة القرآن، لاختيار سورة
/// وعرض التفسير تحت كل آية (بحسب المصدر المختار: الميسر/ابن كثير/السعدي).
class TafsirScreen extends StatefulWidget {
  const TafsirScreen({super.key});

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  late Future<List<SurahInfo>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = QuranApiService.getSurahList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('التفسير', style: AppTextStyles.h2)),
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
                    return Center(child: Text('تعذّر تحميل قائمة السور', style: AppTextStyles.bodySecondary));
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

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final s = filtered[i];
                      return GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: InkWell(
                          onTap: () => context.push('/tafsir/${s.number}', extra: s),
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
                                child: Text(s.name, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                              ),
                              const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
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
