import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gold_divider.dart';

class _SalahStep {
  final String title;
  final String description;
  const _SalahStep({required this.title, required this.description});
}

const List<_SalahStep> _wuduSteps = [
  _SalahStep(title: 'النية', description: 'ينوي القلب الوضوء لله تعالى، بلا تلفّظ.'),
  _SalahStep(title: 'التسمية', description: 'يقول: بسم الله.'),
  _SalahStep(title: 'غسل الكفين', description: 'ثلاث مرات، مع تخليل الأصابع.'),
  _SalahStep(title: 'المضمضة والاستنشاق', description: 'ثلاث مرات، بغرفة واحدة أو أكثر.'),
  _SalahStep(title: 'غسل الوجه', description: 'ثلاث مرات، من منابت الشعر إلى الذقن، ومن الأذن للأذن.'),
  _SalahStep(title: 'غسل اليدين إلى المرفقين', description: 'ثلاث مرات، اليمنى ثم اليسرى.'),
  _SalahStep(title: 'مسح الرأس', description: 'مرة واحدة، مع مسح الأذنين ظاهرًا وباطنًا.'),
  _SalahStep(title: 'غسل الرجلين إلى الكعبين', description: 'ثلاث مرات، اليمنى ثم اليسرى، مع تخليل الأصابع.'),
];

const List<_SalahStep> _prayerSteps = [
  _SalahStep(
    title: 'تكبيرة الإحرام',
    description: 'يستقبل القبلة، يرفع يديه حذو منكبيه، ويقول: الله أكبر، ثم يضع يده اليمنى على اليسرى فوق الصدر.',
  ),
  _SalahStep(
    title: 'دعاء الاستفتاح وقراءة الفاتحة',
    description: 'يقرأ دعاء الاستفتاح، ثم يتعوذ ويبسمل، ثم يقرأ سورة الفاتحة، ثم ما تيسّر من القرآن.',
  ),
  _SalahStep(
    title: 'الركوع',
    description: 'يكبّر وينحني حتى يستوي ظهره، يضع يديه على ركبتيه، ويقول: سبحان ربي العظيم (ثلاثًا).',
  ),
  _SalahStep(
    title: 'الرفع من الركوع',
    description: 'يرفع رأسه قائلًا: سمع الله لمن حمده، ثم يقف معتدلًا قائلًا: ربنا ولك الحمد.',
  ),
  _SalahStep(
    title: 'السجود',
    description:
        'يكبّر ويسجد على سبعة أعضاء (الجبهة مع الأنف، الكفين، الركبتين، أطراف القدمين)، '
        'ويقول: سبحان ربي الأعلى (ثلاثًا).',
  ),
  _SalahStep(
    title: 'الجلوس بين السجدتين',
    description: 'يرفع رأسه مكبّرًا، يجلس مطمئنًا، ويقول: رب اغفر لي، رب اغفر لي.',
  ),
  _SalahStep(
    title: 'السجدة الثانية',
    description: 'يكبّر ويسجد مرة أخرى كالسجدة الأولى، وهذا يكمل الركعة الأولى.',
  ),
  _SalahStep(
    title: 'التشهد',
    description:
        'في الركعة الثانية (والأخيرة)، يجلس ويقرأ التشهد: التحيات لله والصلوات والطيبات... '
        'ثم الصلاة الإبراهيمية إن كان التشهد الأخير.',
  ),
  _SalahStep(
    title: 'التسليم',
    description: 'يلتفت يمينًا قائلًا: السلام عليكم ورحمة الله، ثم يسارًا بنفس القول، وتنتهي الصلاة.',
  ),
];

const List<String> _commonMistakes = [
  'عدم الطمأنينة في الركوع والسجود (الاستعجال بدل السكون في كل ركن).',
  'عدم تسوية الصفوف والتراص في صلاة الجماعة.',
  'رفع البصر إلى السماء أثناء الصلاة بدل النظر لموضع السجود.',
  'الانشغال بتحريك الجوال أو الالتفات الكثير بلا حاجة.',
  'عدم إتمام الوضوء بشكل صحيح (ترك جزء من العضو بلا غسل).',
];

class LearnSalahScreen extends StatelessWidget {
  const LearnSalahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.royalBlack,
        appBar: AppBar(
          title: Text('تعلم الصلاة', style: AppTextStyles.h2),
          bottom: TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: AppColors.textMuted,
            tabs: const [
              Tab(text: 'الوضوء'),
              Tab(text: 'خطوات الصلاة'),
              Tab(text: 'أخطاء شائعة'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _StepsList(steps: _wuduSteps),
              _StepsList(steps: _prayerSteps),
              _MistakesList(mistakes: _commonMistakes),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepsList extends StatelessWidget {
  final List<_SalahStep> steps;
  const _StepsList({required this.steps});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final step = steps[i];
        return GlassCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withOpacity(0.7)),
                ),
                child: Text('${i + 1}', style: AppTextStyles.caption.copyWith(color: AppColors.gold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(step.description, style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MistakesList extends StatelessWidget {
  final List<String> mistakes;
  const _MistakesList({required this.mistakes});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.gold, size: 28),
            const SizedBox(height: 8),
            Text('تنبّه لهذي الأخطاء أثناء الصلاة', style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const GoldDivider(width: 80),
          ],
        ),
        const SizedBox(height: 18),
        ...mistakes.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.close_rounded, color: AppColors.danger, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(m, style: AppTextStyles.body)),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
