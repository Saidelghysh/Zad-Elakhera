import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../quran/models/surah_model.dart';
import '../quran/services/quran_api_service.dart';
import 'models/reciter_model.dart';

/// شاشة سور القارئ — قائمة الـ ١١٤ سورة، مع مشغّل صوتي مصغّر ثابت بالأسفل
/// عند اختيار سورة (تشغيل/إيقاف مؤقت/شريط تقدّم).
class ReciterSurahsScreen extends StatefulWidget {
  final Reciter reciter;
  const ReciterSurahsScreen({super.key, required this.reciter});

  @override
  State<ReciterSurahsScreen> createState() => _ReciterSurahsScreenState();
}

class _ReciterSurahsScreenState extends State<ReciterSurahsScreen> {
  late Future<List<SurahInfo>> _future;
  final AudioPlayer _player = AudioPlayer();
  SurahInfo? _currentSurah;
  bool _loadingAudio = false;

  @override
  void initState() {
    super.initState();
    _future = QuranApiService.getSurahList();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(SurahInfo surah) async {
    setState(() {
      _currentSurah = surah;
      _loadingAudio = true;
    });
    try {
      await _player.setUrl(widget.reciter.surahUrl(surah.number));
      await _player.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تشغيل هذه السورة، تأكد من اتصالك بالإنترنت.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingAudio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text(widget.reciter.name, style: AppTextStyles.h2)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<SurahInfo>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Text('تعذّر تحميل قائمة السور', style: AppTextStyles.bodySecondary),
                    );
                  }

                  final surahs = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: surahs.length,
                    separatorBuilder: (_, __) => Divider(color: AppColors.surfaceBorder.withOpacity(0.4), height: 1),
                    itemBuilder: (context, i) {
                      final s = surahs[i];
                      final isPlaying = _currentSurah?.number == s.number;
                      return ListTile(
                        onTap: () => _play(s),
                        leading: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                          ),
                          child: Text('${s.number}', style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
                        ),
                        title: Text(
                          s.name,
                          style: AppTextStyles.body.copyWith(
                            color: isPlaying ? AppColors.gold : AppColors.textPrimary,
                            fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                        trailing: isPlaying && _loadingAudio
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                              )
                            : Icon(
                                isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_outline_rounded,
                                color: AppColors.gold,
                              ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_currentSurah != null) _MiniPlayer(player: _player, surahName: _currentSurah!.name),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  final AudioPlayer player;
  final String surahName;
  const _MiniPlayer({required this.player, required this.surahName});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.navyCardAlt,
        border: Border(top: BorderSide(color: AppColors.gold.withOpacity(0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(surahName, style: AppTextStyles.h3)),
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return IconButton(
                    icon: Icon(
                      playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                      color: AppColors.gold,
                      size: 34,
                    ),
                    onPressed: () => playing ? player.pause() : player.play(),
                  );
                },
              ),
            ],
          ),
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = player.duration ?? Duration.zero;
              final progress = total.inMilliseconds == 0 ? 0.0 : position.inMilliseconds / total.inMilliseconds;
              return Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      activeTrackColor: AppColors.gold,
                      inactiveTrackColor: AppColors.surfaceBorder,
                      thumbColor: AppColors.gold,
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (v) {
                        final newPos = Duration(milliseconds: (v * total.inMilliseconds).round());
                        player.seek(newPos);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(position), style: AppTextStyles.caption),
                      Text(_fmt(total), style: AppTextStyles.caption),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
