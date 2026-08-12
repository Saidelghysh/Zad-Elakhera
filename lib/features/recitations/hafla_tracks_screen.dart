import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'hafla_link_model.dart';
import 'services/hafla_api_service.dart';

/// شاشة مقاطع "الحفلة" الخارجية — تُجلب الأسماء والروابط الحقيقية من
/// أرشيف الإنترنت وقت التشغيل، وتُشغَّل داخل التطبيق مباشرة.
class HaflaTracksScreen extends StatefulWidget {
  final HaflaLink link;
  const HaflaTracksScreen({super.key, required this.link});

  @override
  State<HaflaTracksScreen> createState() => _HaflaTracksScreenState();
}

class _HaflaTracksScreenState extends State<HaflaTracksScreen> {
  late Future<List<HaflaTrack>> _future;
  final AudioPlayer _player = AudioPlayer();
  HaflaTrack? _current;
  bool _loadingAudio = false;

  @override
  void initState() {
    super.initState();
    _future = HaflaApiService.getTracks(widget.link.identifier);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _play(HaflaTrack track) async {
    setState(() {
      _current = track;
      _loadingAudio = true;
    });
    try {
      await _player.setUrl(track.url);
      await _player.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تشغيل هذا المقطع، جرّب مقطع ثاني أو افتح صفحة الأرشيف مباشرة.')),
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
      appBar: AppBar(
        title: Text(widget.link.sheikhName, style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'فتح صفحة الأرشيف',
            onPressed: () => launchUrl(Uri.parse(widget.link.pageUrl), mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<HaflaTrack>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded, color: AppColors.gold, size: 32),
                            const SizedBox(height: 12),
                            Text('تعذّر تحميل المقاطع', style: AppTextStyles.h3),
                            const SizedBox(height: 8),
                            Text(
                              'تأكد من اتصالك بالإنترنت، أو افتح صفحة الأرشيف مباشرة من الزر فوق.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final tracks = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: tracks.length,
                    separatorBuilder: (_, __) => Divider(color: AppColors.surfaceBorder.withOpacity(0.4), height: 1),
                    itemBuilder: (context, i) {
                      final t = tracks[i];
                      final isPlaying = _current?.url == t.url;
                      return ListTile(
                        onTap: () => _play(t),
                        leading: Icon(
                          isPlaying ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                          color: AppColors.gold,
                        ),
                        title: Text(
                          t.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
            if (_current != null) _MiniPlayer(player: _player, title: _current!.title),
          ],
        ),
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  final AudioPlayer player;
  final String title;
  const _MiniPlayer({required this.player, required this.title});

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
              Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.h3)),
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
