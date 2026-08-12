import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gold_divider.dart';
import 'models/surah_model.dart';
import 'services/quran_api_service.dart';

/// تحويل الأرقام الإنجليزية إلى أرقام عربية-هندية (١٢٣) للمظهر التقليدي.
String _arabicDigits(int number) {
  const western = '0123456789';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  return number.toString().split('').map((c) {
    final i = western.indexOf(c);
    return i == -1 ? c : arabic[i];
  }).join();
}

/// شاشة قراءة سورة كاملة — نص عثماني قياسي، بتصميم "صفحة مصحف" فاخر:
/// عنوان مزخرف، بسملة، شريط تقدّم القراءة، وحفظ آخر موضع تلقائيًا.
class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final SurahInfo? surahInfo;

  const SurahDetailScreen({super.key, required this.surahNumber, this.surahInfo});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late Future<List<Ayah>> _future;
  final ScrollController _scrollController = ScrollController();
  double _fontSize = 22;
  double _readProgress = 0;
  List<Ayah> _loadedAyahs = [];

  @override
  void initState() {
    super.initState();
    _future = QuranApiService.getSurahAyahs(widget.surahNumber);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _saveLastRead();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _scrollController.position.maxScrollExtent == 0) return;
    final progress = (_scrollController.offset / _scrollController.position.maxScrollExtent).clamp(0.0, 1.0);
    if ((progress - _readProgress).abs() > 0.01) {
      setState(() => _readProgress = progress);
    }
  }

  void _saveLastRead() {
    if (_loadedAyahs.isEmpty) return;
    final approxIndex = (_readProgress * (_loadedAyahs.length - 1)).round().clamp(0, _loadedAyahs.length - 1);
    QuranApiService.saveLastRead(widget.surahNumber, _loadedAyahs[approxIndex].numberInSurah);
  }

  void _retry() => setState(() => _future = QuranApiService.getSurahAyahs(widget.surahNumber));

  // البسملة تُعرض كعنوان مستقل قبل كل سورة، ما عدا التوبة (لا بسملة فيها)
  // والفاتحة (لأن آيتها الأولى هي البسملة نفسها، فلا داعي لتكرارها).
  bool get _showBismillahHeader => widget.surahNumber != 9 && widget.surahNumber != 1;

  @override
  Widget build(BuildContext context) {
    final info = widget.surahInfo;
    final title = info?.name ?? 'سورة ${widget.surahNumber}';

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: _readProgress == 0 ? null : _readProgress,
            minHeight: 3,
            backgroundColor: AppColors.surfaceBorder.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
          ),
        ),
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
            _loadedAyahs = ayahs;
            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                children: [
                  // عنوان السورة المزخرف، بإطار زخرفي علوي وسفلي بسيط
                  Column(
                    children: [
                      const _CornerOrnament(),
                      const SizedBox(height: 6),
                      Text(
                        info?.name ?? title,
                        style: AppTextStyles.h1.copyWith(color: AppColors.gold, fontSize: 26),
                      ),
                      const SizedBox(height: 8),
                      const GoldDivider(width: 90),
                      const SizedBox(height: 8),
                      if (info != null)
                        Text(
                          '${info.isMeccan ? "مكية" : "مدنية"} · ${_arabicDigits(info.numberOfAyahs)} آية',
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (_showBismillahHeader) ...[
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.quranAyah.copyWith(
                        fontSize: _fontSize + 2,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // "صفحة" النص — إطار فاخر بخلفية بطاقة داكنة وحدود ذهبية رفيعة
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    borderColor: AppColors.gold.withOpacity(0.35),
                    glow: true,
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
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.gold.withOpacity(0.8), width: 0.8),
                                      ),
                                      child: Text(
                                        _arabicDigits(a.numberInSurah),
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.gold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(text: '  '),
                              ],
                            );
                          }).toList(),
                        ),
                        style: AppTextStyles.quranAyah.copyWith(fontSize: _fontSize, height: 2.3),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _CornerOrnament(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// زخرفة صغيرة (نجمة إسلامية مبسطة) تُستخدم أعلى وأسفل صفحة القراءة —
/// لمسة فخامة بسيطة بدون أي اعتماد على صور خارجية.
class _CornerOrnament extends StatelessWidget {
  const _CornerOrnament();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(painter: _StarPainter()),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    const points = 8;
    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? radius : radius * 0.45;
      final angle = (i * pi / points) - (pi / 2);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
