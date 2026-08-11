/// تسجيلات "حفلات" خارجية نادرة — أجزاء وسور متفرقة من مناسبات ولقاءات
/// قديمة، مو مصحف كامل مرتّب بالسور (ولهذا هي نادرة). بما إن هذي التسجيلات
/// مبعثرة عبر ملفات فردية بأسماء معقدة (رموز وتشكيل عربي)، نربطها كـ"روابط
/// خارجية" لصفحات حقيقية وموثوقة على أرشيف الإنترنت (archive.org) بدل
/// محاولة تشغيلها مباشرة داخل التطبيق، لضمان إنها تشتغل ١٠٠٪ بدون روابط
/// مكسورة.
class HaflaLink {
  final String sheikhName;
  final String description;
  final String url;

  const HaflaLink({required this.sheikhName, required this.description, required this.url});
}

const List<HaflaLink> haflaLinks = [
  HaflaLink(
    sheikhName: 'محمد صديق المنشاوي',
    description: 'الحفلات والتسجيلات الخارجية — ٧٣ حفلة وتلاوة خاشعة',
    url: 'https://archive.org/details/Tasjilat-Mojawada_Kharijia_Mohamed-siddiq-al-minshawi_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'عبدالباسط عبدالصمد',
    description: 'التسجيلات الخارجية النادرة — ١٠٢ تلاوة',
    url: 'https://archive.org/details/Abdel_Baset_Abd-Samad_TilawaT-Nadira_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'محمد الليثي',
    description: 'تسجيلات خارجية ونادرة بجودة عالية',
    url: 'https://archive.org/details/mohammad.allythy.mogawwad.uP.bY.ReDa.MoHamMeD',
  ),
  HaflaLink(
    sheikhName: 'محمود علي البنا',
    description: '٣٥٩ حفلة مجودة ونادرة بجودة عالية',
    url: 'https://archive.org/details/Mahmoud.Ali.Al.Banna.7flat.uP.bY.ReDa.MoHamMeD',
  ),
  HaflaLink(
    sheikhName: 'شعبان الصياد',
    description: 'ضمن تجميعة حفلات مجودة مشتركة (مع المنشاوي والحصري)',
    url: 'https://archive.org/details/Tilawat_wa_Hafalat_Mojawada_uP_bY_mUSLEm',
  ),
];
