import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import 'models/reciter_model.dart';
import 'services/recitations_api_service.dart';

/// شاشة التلاوات — قائمة قراء مختارين، يفتح كل واحد منهم قائمة السور للتشغيل.
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

            final reciters = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reciters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final r = reciters[i];
                return GlassCard(
                  child: InkWell(
                    onTap: () => context.push('/recitations/${r.id}', extra: r),
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
                          child: const Icon(Icons.headphones_rounded, color: AppColors.gold),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(r.name, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                        ),
                        const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
