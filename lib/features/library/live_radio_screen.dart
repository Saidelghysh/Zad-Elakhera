import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/mosque_silhouette_background.dart';

class LiveRadioScreen extends StatefulWidget {
  const LiveRadioScreen({super.key});

  @override
  State<LiveRadioScreen> createState() => _LiveRadioScreenState();
}

class _LiveRadioScreenState extends State<LiveRadioScreen> {
  static const String _fallbackStream = 'https://stream.radiojar.com/8s5u5tpdtwzuv';

  final AudioPlayer _player = AudioPlayer();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  bool _connecting = false;
  bool _isLive = false;
  String? _error;
  String? _streamUrl;
  String _stationName = 'إذاعة القرآن الكريم من القاهرة';

  @override
  void dispose() {
    _player.dispose();
    _dio.close(force: true);
    super.dispose();
  }

  Future<String> _findStreamUrl() async {
    try {
      final response = await _dio.get(
        'https://www.mp3quran.net/api/v3/radios',
        queryParameters: {'language': 'ar'},
      );
      final data = response.data;
      final radios = data is Map && data['radios'] is List ? data['radios'] as List : const [];

      for (final item in radios) {
        if (item is! Map) continue;
        final name = (item['name'] as String? ?? '').trim();
        final url = (item['url'] as String? ?? '').trim();
        if (name.contains('القاهرة') && url.isNotEmpty) {
          _stationName = name;
          return url;
        }
      }
    } catch (_) {
      // نستخدم المصدر الاحتياطي بالأسفل.
    }
    return _fallbackStream;
  }

  Future<void> _toggle() async {
    if (_connecting) return;

    if (_isLive) {
      await _player.stop();
      if (mounted) setState(() => _isLive = false);
      return;
    }

    setState(() {
      _connecting = true;
      _error = null;
    });

    try {
      _streamUrl ??= await _findStreamUrl();
      await _player.setUrl(_streamUrl!);
      await _player.play();
      if (mounted) {
        setState(() {
          _isLive = true;
          _connecting = false;
        });
      }
    } catch (_) {
      try {
        _streamUrl = _fallbackStream;
        await _player.setUrl(_fallbackStream);
        await _player.play();
        if (mounted) {
          setState(() {
            _isLive = true;
            _connecting = false;
            _error = null;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _connecting = false;
            _isLive = false;
            _error = 'تعذّر تشغيل البث الآن. جرّب مرة أخرى بعد قليل.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('البث المباشر', style: AppTextStyles.h2)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          child: Column(
            children: [
              const MosqueSilhouetteBackground(height: 145, opacity: 0.30),
              const SizedBox(height: 10),
              GlassCard(
                glow: _isLive,
                borderColor: AppColors.gold.withOpacity(0.70),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  children: [
                    if (_isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.55)),
                        ),
                        child: Text('●  يبث الآن', style: AppTextStyles.caption.copyWith(color: Colors.redAccent)),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _stationName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1.copyWith(color: AppColors.gold, fontSize: 23),
                    ),
                    const SizedBox(height: 4),
                    Text('استماع مباشر من داخل التطبيق', style: AppTextStyles.bodySecondary),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _connecting ? null : _toggle,
                      child: Container(
                        width: 96,
                        height: 96,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.navyCardAlt,
                          border: Border.all(color: AppColors.gold, width: 1.3),
                          boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.23), blurRadius: 22, spreadRadius: 2)],
                        ),
                        child: _connecting
                            ? const CircularProgressIndicator(color: AppColors.gold)
                            : Icon(
                                _isLive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                                color: AppColors.gold,
                                size: 48,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_isLive ? 'إيقاف البث' : 'تشغيل البث', style: AppTextStyles.h3.copyWith(color: AppColors.gold)),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_rounded, color: AppColors.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'البث يحتاج اتصال إنترنت. إذا تعطل مصدر، يحاول التطبيق تلقائيًا استخدام المصدر الاحتياطي.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
