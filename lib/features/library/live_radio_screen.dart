import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/mosque_silhouette_background.dart';

/// شاشة البث المباشر لإذاعة القرآن الكريم من القاهرة.
///
/// نجلب رابط البث الفعلي وقت التشغيل من واجهة mp3quran.net الموثوقة (نفس
/// مصدر التلاوات بالتطبيق) بدل ترميز رابط ثابت قد يتغيّر أو ينكسر —
/// ندوّر على محطة "القاهرة" ضمن قائمة كل الإذاعات المتاحة.
class LiveRadioScreen extends StatefulWidget {
  const LiveRadioScreen({super.key});

  @override
  State<LiveRadioScreen> createState() => _LiveRadioScreenState();
}

class _LiveRadioScreenState extends State<LiveRadioScreen> {
  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio();

  bool _connecting = false;
  bool _isLive = false;
  String? _error;
  String? _streamUrl;
  String _stationName = 'إذاعة القرآن الكريم';

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<String?> _findCairoStreamUrl() async {
    final response = await _dio.get(
      'https://www.mp3quran.net/api/v3/radios',
      queryParameters: {'language': 'ar'},
    );
    final radios = response.data['radios'] as List;

    final match = radios.firstWhere(
      (r) => (r['name'] as String? ?? '').contains('القاهرة'),
      orElse: () => null,
    );
    if (match == null) {
      // تشخيص: نعرض أول ٥ أسماء إذاعات فعلية موجودة بالمصدر، عشان نتأكد
      // هل "القاهرة" موجودة بمصدرنا الحالي أصلًا بأي اسم قريب أو لا.
      final sampleNames = radios.take(8).map((r) => r['name']).join('، ');
      throw Exception('محطة القاهرة مو موجودة بهذا المصدر. محطات متاحة: $sampleNames');
    }

    _stationName = match['name'] as String;
    return match['url'] as String?;
  }

  Future<void> _toggle() async {
    if (_isLive) {
      await _player.stop();
      setState(() => _isLive = false);
      return;
    }

    setState(() {
      _connecting = true;
      _error = null;
    });

    try {
      _streamUrl ??= await _findCairoStreamUrl();
      if (_streamUrl == null) {
        setState(() {
          _connecting = false;
          _error = 'تعذّر إيجاد رابط البث حاليًا. حاول لاحقًا.';
        });
        return;
      }

      await _player.setUrl(_streamUrl!);
      await _player.play();
      setState(() {
        _isLive = true;
        _connecting = false;
      });
    } catch (e) {
      setState(() {
        _connecting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('بث مباشر', style: AppTextStyles.h2)),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const MosqueSilhouetteBackground(height: 130, opacity: 0.3),
            const SizedBox(height: 12),
            GlassCard(
              glow: _isLive,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLive)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
                        ),
                        const SizedBox(width: 6),
                        Text('يبث الآن', style: AppTextStyles.caption.copyWith(color: Colors.redAccent)),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(_stationName, style: AppTextStyles.h1.copyWith(color: AppColors.gold, fontSize: 22), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('من القاهرة — على مدار الساعة', style: AppTextStyles.bodySecondary),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _connecting ? null : _toggle,
                    child: Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.navyCardAlt,
                        border: Border.all(color: AppColors.gold, width: 1.2),
                        boxShadow: [
                          BoxShadow(color: AppColors.gold.withOpacity(0.25), blurRadius: 20, spreadRadius: 2),
                        ],
                      ),
                      child: _connecting
                          ? const CircularProgressIndicator(color: AppColors.gold)
                          : Icon(
                              _isLive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                              color: AppColors.gold,
                              size: 42,
                            ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
                  ],
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
