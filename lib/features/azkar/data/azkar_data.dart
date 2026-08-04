class AzkarItem {
  final String text;
  final int repeat;
  final String? source;

  const AzkarItem({required this.text, required this.repeat, this.source});
}

class AzkarCategory {
  final String title;
  final List<AzkarItem> items;
  const AzkarCategory({required this.title, required this.items});
}

/// بيانات نموذجية لأذكار الصباح — نفس البنية تُستخدم لبقية الفئات
/// (المساء، النوم، السفر، الصلاة) بجلب المحتوى الكامل من ملف JSON محلي
/// أو من Firestore عبر لوحة التحكم الإدارية.
const AzkarCategory morningAzkar = AzkarCategory(
  title: 'أذكار الصباح',
  items: [
    AzkarItem(
      text:
          'أصبحنا وأصبح الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، '
          'له الملك وله الحمد وهو على كل شيء قدير.',
      repeat: 1,
      source: 'رواه أبو داود',
    ),
    AzkarItem(
      text: 'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور.',
      repeat: 1,
      source: 'رواه الترمذي',
    ),
    AzkarItem(
      text: 'سبحان الله وبحمده',
      repeat: 100,
    ),
    AzkarItem(
      text: 'اللهم إني أسألك العفو والعافية في الدنيا والآخرة.',
      repeat: 1,
    ),
  ],
);

const List<String> azkarCategoryNames = [
  'أذكار الصباح',
  'أذكار المساء',
  'أذكار النوم',
  'أذكار السفر',
  'أذكار الصلاة',
];
