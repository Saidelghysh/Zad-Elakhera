import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import 'hafla_link_model.dart';
import 'services/hafla_api_service.dart';

/// قائمة التسجيلات الخارجية مع تشغيل مباشر داخل التطبيق.
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
  String _query = '';

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

  Future<void> _retry() async {
    setState(() => _future = HaflaApiService.getTracks(widget.link.identifier));
  }

  Future<void> _play(HaflaTrack track) async {
    if (_current?.url == track.url) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      if (mounted) setState(() {});
      return;
    }

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
          const SnackBar(content: Text('تعذّر تشغيل التسجيل الآن. جرّب تسجيلًا آخر.')),
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
            tooltip: 'المصدر الأصلي',
            icon: const Icon(Icons.open_in_new_rounded),
            onPressed: () => launchUrl(
              Uri.parse(widget.link.pageUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill_rounded, color: AppColors.gold, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'اضغط على أي تسجيل للاستماع إليه مباشرة داخل التطبيق',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                textDirection: TextDirection.rtl,
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'ابحث داخل التسجيلات...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => _query = ''),
                        ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<HaflaTrack>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return _StateMessage(
                      title: 'تعذّر تحميل التسجيلات',
                      message: 'تأكد من الإنترنت ثم أعد المحاولة.',
                      action: _retry,
                    );
                  }

                  final tracks = snapshot.data!
                      .where((t) => _query.isEmpty || t.title.contains(_query))
                      .toList();
                  if (tracks.isEmpty) {
                    return _StateMessage(
                      title: 'لا توجد نتائج',
                      message: 'جرّب كلمة بحث أخرى.',
                      action: _query.isEmpty ? _retry : null,
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    itemCount: tracks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final track = tracks[i];
                      final selected = _current?.url == track.url;
                      return GlassCard(
                        padding: EdgeInsets.zero,
                        borderColor: selected ? AppColors.gold : AppColors.surfaceBorder,
                        child: ListTile(
                          onTap: () => _play(track),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          leading: Container(
                            width: 42,
                            height: 42,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.navyCardAlt,
                              border: Border.all(color: AppColors.gold.withOpacity(0.55)),
                            ),
                            child: _loadingAudio && selected
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                                  )
                                : Icon(
                                    selected && _player.playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: AppColors.gold,
                                  ),
                          ),
                          title: Text(
                            track.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              color: selected ? AppColors.gold : AppColors.textPrimary,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                          trailing: Text('${i + 1}', style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
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

class _StateMessage extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? action;

  const _StateMessage({required this.title, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: AppColors.gold, size: 36),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.h3),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodySecondary),
            if (action != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: action,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
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
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.navyCardAlt,
        border: Border(top: BorderSide(color: AppColors.gold.withOpacity(0.35))),
      ),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
                StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) => Text(
                    '${_fmt(snapshot.data ?? Duration.zero)} / ${_fmt(player.duration ?? Duration.zero)}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.gold, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return IconButton(
                icon: Icon(
                  playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: AppColors.gold,
                  size: 32,
                ),
                onPressed: () => playing ? player.pause() : player.play(),
              );
            },
          ),
        ],
      ),
    );
  }
}
