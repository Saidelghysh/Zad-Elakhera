import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../recitations/hafla_link_model.dart';

class LinkListScreen extends StatefulWidget {
  final String title;
  final List<HaflaLink> links;

  const LinkListScreen({super.key, required this.title, required this.links});

  @override
  State<LinkListScreen> createState() => _LinkListScreenState();
}

class _LinkListScreenState extends State<LinkListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.links.where((item) {
      final q = _query.trim();
      return q.isEmpty || item.sheikhName.contains(q) || item.description.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text(widget.title, style: AppTextStyles.h2)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: TextField(
                textDirection: TextDirection.rtl,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم القارئ...',
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
              child: filtered.isEmpty
                  ? Center(child: Text('لا توجد نتائج', style: AppTextStyles.bodySecondary))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 9),
                      itemBuilder: (context, i) {
                        final link = filtered[i];
                        return GlassCard(
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            onTap: () => context.push('/library/tracks', extra: link),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(13),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.navyCardAlt,
                                      border: Border.all(color: AppColors.gold.withOpacity(0.55)),
                                    ),
                                    child: const Icon(Icons.library_music_rounded, color: AppColors.gold),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(link.sheikhName, style: AppTextStyles.h3),
                                        const SizedBox(height: 3),
                                        Text(link.description, style: AppTextStyles.caption),
                                        const SizedBox(height: 5),
                                        Text('تشغيل داخل التطبيق', style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ),
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
