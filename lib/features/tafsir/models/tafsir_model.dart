/// نسخة تفسير متاحة (مثل التفسير الميسر، ابن كثير، السعدي).
class TafsirEdition {
  final String identifier; // مثال: ar.muyassar
  final String name; // الاسم بالعربي كما تُرجعه الواجهة

  const TafsirEdition({required this.identifier, required this.name});
}

/// نص تفسير آية واحدة (يقابل رقمها في نفس السورة).
class TafsirAyah {
  final int numberInSurah;
  final String text;

  const TafsirAyah({required this.numberInSurah, required this.text});
}
