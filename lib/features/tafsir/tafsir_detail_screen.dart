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
  Future<List<Ayah>>? _ayahsFuture;
  Future<List<TafsirAyah>>? _tafsirFuture;
  bool _loadingEditions = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ayahsFuture = QuranApiService.getSurahAyahs(widget.surahNumber);
    _loadEditions();
  }

  Future<void> _loadEditions() async {
    try {
      final editions = await TafsirApiService.getAvailableEditions();
      if (!mounted) return;
      setState(() {
        _editions = editions;
        _loadingEditions = false;
        if (editions.isNotEmpty) {
          _selected = editions.first;
          _tafsirFuture = TafsirApiService.getSurahTafsir(editions.first.identifier, widget.surahNumber);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingEditions = false;
        _errorMessage = 'تعذّر تحميل مصادر التفسير. تأكد من اتصالك بالإنترنت.';
      });
    }
  }

  void _selectEdition(TafsirEdition edition) {
    setState(() {
      _selected = edition;
      _tafsirFuture = TafsirApiService.getSurahTafsir(edition.identifier, widget.surahNumber);
    });
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
              child: _loadingEditions
                  ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(_errorMessage!, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
                          ),
                        )
                      : FutureBuilder(
                          future: Future.wait([_ayahsFuture!, _tafsirFuture!]),
                          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                            if (snapshot.connectionState != ConnectionState.done) {
                              return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return Center(
                                child: Text('تعذّر تحميل التفسير لهذه السورة', style: AppTextStyles.bodySecondary),
                              );
                            }

                            final ayahs = snapshot.data![0] as List<Ayah>;
                            final tafsirList = snapshot.data![1] as List<TafsirAyah>;
                            final tafsirMap = {for (final t in tafsirList) t.numberInSurah: t.text};

                            return ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: ayahs.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final a = ayahs[i];
                                final tafsirText = tafsirMap[a.numberInSurah] ?? '';
                                return GlassCard(
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                a.text,
                                                style: AppTextStyles.quranAyah.copyWith(fontSize: 19),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Divider(color: AppColors.surfaceBorder.withOpacity(0.5), height: 1),
                                        const SizedBox(height: 8),
                                        Text(
                                          tafsirText.isEmpty ? 'لا يتوفر تفسير لهذه الآية من هذا المصدر.' : tafsirText,
                                          style: AppTextStyles.bodySecondary,
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
