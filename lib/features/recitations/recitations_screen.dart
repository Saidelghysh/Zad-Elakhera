import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gold_divider.dart';
import 'models/reciter_model.dart';
import 'services/recitations_api_service.dart';

/// شاشة التلاوات — قائمتان: قراء معاصرون، وتلاوات نادرة/كلاسيكية للقراء القدامى.
class RecitationsScreen extends StatefulWidget {
  const RecitationsScreen({super.key});

  @override
  State<RecitationsScreen> createState() => _RecitationsScreenState();
}

class _RecitationsScreenState extends State<RecitationsScreen> {
  late Future<List<Reciter>> _future;

  @override
  void initState() {
    super.initState();
    _future = RecitationsApiService.getCuratedReciters();
  }

  void _retry() => setState(() => _future = RecitationsApiService.getCuratedReciters());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('التلاوات', style: AppTextStyles.h2)),
      body: SafeArea(
        child: FutureBuilder<List<Reciter>>(
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
                      Text('تعذّر تحميل قائمة القراء', style: AppTextStyles.h3),
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

            final all = snapshot.data!;
            final modern = all.where((r) => r.category == 'modern').toList();
            final classic = all.where((r) => r.category == 'classic').toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (modern.isNotEmpty) ...[
                  Text('قراء معاصرون', style: AppTextStyles.h3),
                  const SizedBox(height: 10),
                  ...modern.map((r) => _ReciterTile(reciter: r)),
                  const SizedBox(height: 26),
                ],
                if (classic.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 16),
                      const SizedBox(width: 6),
                      Text('تلاوات نادرة', style: AppTextStyles.h3),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تسجيلات كلاسيكية للقراء القدامى بأسلوب التجويد المُتقَن (المجوَّد)',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 10),
                  const GoldDivider(width: 60),
                  const SizedBox(height: 14),
                  ...classic.map((r) => _ReciterTile(reciter: r, isClassic: true)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReciterTile extends StatelessWidget {
  final Reciter reciter;
  final bool isClassic;
  const _ReciterTile({required this.reciter, this.isClassic = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        borderColor: isClassic ? AppColors.gold.withOpacity(0.45) : AppColors.surfaceBorder,
        child: InkWell(
          onTap: () => context.push('/recitations/${reciter.id}', extra: reciter),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.navyCardAlt,
                  border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                ),
                child: Icon(
                  isClassic ? Icons.auto_awesome_rounded : Icons.headphones_rounded,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(reciter.name, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              ),
              const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
