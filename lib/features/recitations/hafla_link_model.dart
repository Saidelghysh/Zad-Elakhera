/// تسجيلات "حفلات" خارجية نادرة — أجزاء وسور متفرقة من مناسبات ولقاءات
/// قديمة، مو مصحف كامل مرتّب بالسور (ولهذا هي نادرة). بما إن هذي التسجيلات
/// مبعثرة عبر ملفات فردية بأسماء معقدة (رموز وتشكيل عربي)، نربطها كـ"روابط
/// خارجية" لصفحات حقيقية وموثوقة على أرشيف الإنترنت (archive.org) بدل
/// محاولة تشغيلها مباشرة داخل التطبيق، لضمان إنها تشتغل ١٠٠٪ بدون روابط
/// مكسورة.
class HaflaLink {
  final String sheikhName;
  final String description;
  final String identifier; // معرّف العنصر على archive.org (يُستخدم لجلب الملفات الحقيقية)

  const HaflaLink({required this.sheikhName, required this.description, required this.identifier});

  String get pageUrl => 'https://archive.org/details/$identifier';
}

const List<HaflaLink> haflaLinks = [
  HaflaLink(
    sheikhName: 'محمد صديق المنشاوي',
    description: 'الحفلات والتسجيلات الخارجية — ٧٣ حفلة وتلاوة خاشعة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Mohamed-siddiq-al-minshawi_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'عبدالباسط عبدالصمد',
    description: 'التسجيلات الخارجية النادرة — ١٠٢ تلاوة',
    identifier: 'Abdel_Baset_Abd-Samad_TilawaT-Nadira_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'محمد الليثي',
    description: 'تسجيلات خارجية ونادرة بجودة عالية',
    identifier: 'mohammad.allythy.mogawwad.uP.bY.ReDa.MoHamMeD',
  ),
  HaflaLink(
    sheikhName: 'محمود علي البنا',
    description: '٣٥٩ حفلة مجودة ونادرة بجودة عالية',
    identifier: 'Mahmoud.Ali.Al.Banna.7flat.uP.bY.ReDa.MoHamMeD',
  ),
  HaflaLink(
    sheikhName: 'شعبان الصياد',
    description: 'ضمن تجميعة حفلات مجودة مشتركة (مع المنشاوي والحصري)',
    identifier: 'Tilawat_wa_Hafalat_Mojawada_uP_bY_mUSLEm',
  ),
];
