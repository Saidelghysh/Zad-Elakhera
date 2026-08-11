import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../quran/models/surah_model.dart';
import '../quran/services/quran_api_service.dart';
import 'models/tafsir_model.dart';
import 'services/tafsir_api_service.dart';

/// شاشة عرض التفسير — نص كل آية، وتحتها تفسيرها من المصدر المختار.
class TafsirDetailScreen extends StatefulWidget {
  final int surahNumber;
  final SurahInfo? surahInfo;

  const TafsirDetailScreen({super.key, required this.surahNumber, this.surahInfo});

  @override
  State<TafsirDetailScreen> createState() => _TafsirDetailScreenState();
}

class _TafsirDetailScreenState extends State<TafsirDetailScreen> {
  List<TafsirEdition> _editions = [];
  TafsirEdition? _selected;
  List<Ayah> _ayahs = [];
  Map<int, String> _tafsirMap = {};

  bool _loading = true;
  bool _loadingTafsirOnly = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      // نجيب نص القرآن أولًا (لازم نعرف عدد آيات السورة قبل ما نطلب تفسيرها).
      final ayahs = await QuranApiService.getSurahAyahs(widget.surahNumber);
      final editions = await TafsirApiService.getAvailableEditions();

      if (!mounted) return;

      if (editions.isEmpty) {
        setState(() {
          _ayahs = ayahs;
          _loading = false;
          _errorMessage = 'تعذّر إيجاد مصادر تفسير متاحة حاليًا. حاول لاحقًا.';
        });
        return;
      }

      final tafsirList = await TafsirApiService.getSurahTafsir(
        editions.first.identifier,
        widget.surahNumber,
        ayahs.length,
      );

      if (!mounted) return;
      setState(() {
        _ayahs = ayahs;
        _editions = editions;
        _selected = editions.first;
        _tafsirMap = {for (final t in tafsirList) t.numberInSurah: t.text};
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'تعذّر تحميل التفسير. تأكد من اتصالك بالإنترنت ثم أعد المحاولة.';
      });
    }
  }

  Future<void> _selectEdition(TafsirEdition edition) async {
    setState(() {
      _selected = edition;
      _loadingTafsirOnly = true;
    });
    try {
      final tafsirList = await TafsirApiService.getSurahTafsir(
        edition.identifier,
        widget.surahNumber,
        _ayahs.length,
      );
      if (!mounted) return;
      setState(() {
        _tafsirMap = {for (final t in tafsirList) t.numberInSurah: t.text};
        _loadingTafsirOnly = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingTafsirOnly = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.surahInfo?.name ?? 'سورة ${widget.surahNumber}';

    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text(title, style: AppTextStyles.h2)),
      body: SafeArea(
        child: Column(
          children: [
            if (_editions.length > 1)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: _editions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final e = _editions[i];
                    final selected = _selected?.identifier == e.identifier;
                    return ChoiceChip(
                      label: Text(e.name),
                      selected: selected,
                      onSelected: (_) => _selectEdition(e),
                      backgroundColor: AppColors.navyCard,
                      selectedColor: AppColors.gold.withOpacity(0.2),
                      labelStyle: AppTextStyles.caption.copyWith(
                        color: selected ? AppColors.gold : AppColors.textMuted,
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : _errorMessage != null && _ayahs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(_errorMessage!, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
                          ),
                        )
                      : Stack(
                          children: [
                            ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _ayahs.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final a = _ayahs[i];
                                final tafsirText = _tafsirMap[a.numberInSurah] ?? '';
                                return GlassCard(
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          a.text,
                                          style: AppTextStyles.quranAyah.copyWith(fontSize: 19),
                                          textAlign: TextAlign.right,
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(color: AppColors.surfaceBorder.withOpacity(0.5), height: 1),
                                        const SizedBox(height: 8),
                                        Text(
                                          tafsirText.isEmpty
                                              ? 'لا يتوفر تفسير لهذه الآية من هذا المصدر حاليًا.'
                                              : tafsirText,
                                          style: AppTextStyles.bodySecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (_loadingTafsirOnly)
                              Container(
                                color: Colors.black54,
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.gold),
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
