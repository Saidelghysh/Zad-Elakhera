import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

class _TajweedLesson {
  final String title;
  final String summary;
  final List<String> points;
  const _TajweedLesson({required this.title, required this.summary, required this.points});
}

const List<_TajweedLesson> _lessons = [
  _TajweedLesson(
    title: 'مخارج الحروف',
    summary: 'مخرج الحرف هو الموضع الذي يُنطق منه الحرف من الفم أو الحلق أو الجوف.',
    points: [
      'الجوف: مخرج حروف المد (ا، و، ي) الساكنة.',
      'الحلق: أقصاه للهمزة والهاء، وسطه للعين والحاء، أدناه للغين والخاء.',
      'اللسان: أكبر مصدر للحروف، بحسب موضع اللسان من الحنك أو الأسنان.',
      'الشفتان: مخرج الباء والميم والواو.',
      'الخيشوم: مخرج الغُنّة (الصوت الأنفي) في النون والميم المشدّدتين وأحكامهما.',
    ],
  ),
  _TajweedLesson(
    title: 'أحكام النون الساكنة والتنوين',
    summary: 'أربعة أحكام تحدّد كيف تُنطق النون الساكنة أو التنوين حسب الحرف الذي يليها.',
    points: [
      'الإظهار: عند حروف الحلق الستة (ء هـ ع ح غ خ) — تُنطق النون واضحة بلا غُنّة زائدة.',
      'الإدغام: عند حروف (ي ر م ل و ن) — تُدمَج النون بالحرف التالي (بغُنّة أو بدونها).',
      'الإقلاب: عند الباء فقط — تُقلَب النون ميمًا مخفاة بغُنّة.',
      'الإخفاء: عند بقية الحروف (خمسة عشر حرفًا) — تُنطق النون بصفة بين الإظهار والإدغام مع غُنّة.',
    ],
  ),
  _TajweedLesson(
    title: 'أحكام الميم الساكنة',
    summary: 'ثلاثة أحكام للميم الساكنة حسب الحرف الذي يليها.',
    points: [
      'الإخفاء الشفوي: عند الباء — تُخفى الميم مع غُنّة خفيفة.',
      'الإدغام الشفوي (المثلين الصغير): عند الميم — تُدمَج الميمان مع غُنّة.',
      'الإظهار الشفوي: عند بقية الحروف — تُنطق الميم واضحة بلا غُنّة زائدة.',
    ],
  ),
  _TajweedLesson(
    title: 'المدود (أنواع المد)',
    summary: 'المد هو إطالة الصوت بحرف من حروف المد الثلاثة (ا و ي) حسب سبب المد.',
    points: [
      'المد الطبيعي: حركتان، بلا همز أو سكون بعده (مثل: قَالَ).',
      'المد المتصل: الهمز بعد حرف المد بنفس الكلمة، يُمَد وجوبًا ٤-٥ حركات.',
      'المد المنفصل: الهمز بعد حرف المد في كلمة تالية، يُمَد جوازًا ٤-٥ حركات.',
      'المد اللازم: بعد حرف المد سكون أصلي، يُمَد ٦ حركات وجوبًا.',
      'مد العارض للسكون: عند الوقف على كلمة آخرها حرف مد، يجوز مدّه ٢ أو ٤ أو ٦ حركات.',
    ],
  ),
  _TajweedLesson(
    title: 'الوقف والابتداء',
    summary: 'قواعد لمعرفة أين يجوز التوقف عند القراءة وأين يُستحسن الوصل.',
    points: [
      'الوقف التام: عند تمام المعنى وعدم تعلّقه بما بعده — يجوز الوقف والابتداء بعده.',
      'الوقف الكافي: تمام الكلام لفظًا مع تعلّق المعنى بما بعده — يجوز الوقف والوصل.',
      'الوقف الحسن: تمام الكلام لكن مع تعلّق شديد بما بعده — يُستحسن عدم الابتداء بعده.',
      'الوقف القبيح: يُغيّر المعنى المقصود — يُتجنّب إلا لضرورة كنفَس، ثم يُعاد ما قبله.',
    ],
  ),
  _TajweedLesson(
    title: 'صفات الحروف',
    summary: 'الصفة هي الكيفية التي يُنطق بها الحرف عند خروجه من مخرجه، وتميّز الحروف المتشابهة بالمخرج.',
    points: [
      'الهمس والجهر: هل يجري النفس مع الحرف (الهمس) أو ينحبس (الجهر).',
      'الشدة والرخاوة والتوسط: مدى انحباس الصوت عند النطق بالحرف.',
      'الاستعلاء والاستفال: ارتفاع اللسان نحو الحنك الأعلى أو انخفاضه.',
      'الإطباق والانفتاح: انطباق اللسان على الحنك (كما في الصاد والضاد والطاء والظاء) أو انفتاحه.',
      'القلقلة: اضطراب الصوت عند النطق بحروف (ق ط ب ج د) عند سكونها.',
    ],
  ),
];

class TajweedScreen extends StatelessWidget {
  const TajweedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.royalBlack,
      appBar: AppBar(title: Text('أحكام التجويد', style: AppTextStyles.h2)),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _lessons.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final lesson = _lessons[i];
            return GlassCard(
              padding: EdgeInsets.zero,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: AppColors.gold,
                  collapsedIconColor: AppColors.textMuted,
                  title: Text(lesson.title, style: AppTextStyles.h3),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(lesson.summary, style: AppTextStyles.caption),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: lesson.points
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6, left: 8),
                                  child: Icon(Icons.circle, size: 5, color: AppColors.gold),
                                ),
                                Expanded(child: Text(p, style: AppTextStyles.bodySecondary)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
