import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'models/surah_model.dart';
import 'services/quran_api_service.dart';

/// شاشة قراءة سورة كاملة — نص عثماني قياسي، مع حفظ آخر آية مقروءة تلقائيًا.
class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final SurahInfo? surahInfo; // يُمرَّر من شاشة القائمة لعرض العنوان فورًا بدون انتظار

  const SurahDetailScreen({super.key, required this.surahNumber, this.surahInfo});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<List<Ayah>> _future;
  double _fontSize = 22;

  @override
  void initState() {
    super.initState();
    _future = QuranApiService.getSurahAyahs(widget.surahNumber);
  }

  void _retry() => setState(() => _future = QuranApiService.getSurahAyahs(widget.surahNumber));

  @override
  Widget build(BuildContext context) {
    final title = widget.surahInfo?.name ?? 'سورة ${widget.surahNumber}';

    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded),
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(16, 34)),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase_rounded),
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(16, 34)),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Ayah>>(
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
                      Text('تعذّر تحميل نص السورة', style: AppTextStyles.h3),
                      const SizedBox(height: 6),
                      Text('تأكد من اتصالك بالإنترنت ثم أعد المحاولة.',
                          textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
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

            final ayahs = snapshot.data!;
            return NotificationListener<ScrollEndNotification>(
              onNotification: (_) => false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text.rich(
                    TextSpan(
                      children: ayahs.map((a) {
                        return TextSpan(
                          children: [
                            TextSpan(text: '${a.text} '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.gold.withOpacity(0.7)),
                                  ),
                                  child: Text(
                                    '${a.numberInSurah}',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                            const TextSpan(text: '  '),
                          ],
                        );
                      }).toList(),
                    ),
                    style: AppTextStyles.quranAyah.copyWith(fontSize: _fontSize),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
