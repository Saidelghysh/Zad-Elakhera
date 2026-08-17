/// مصدر صوتي خارجي من Internet Archive.
/// التطبيق يجلب قائمة الملفات الفعلية وقت التشغيل ويشغلها داخله.
class HaflaLink {
  final String sheikhName;
  final String description;
  final String identifier;

  const HaflaLink({
    required this.sheikhName,
    required this.description,
    required this.identifier,
  });

  String get pageUrl => 'https://archive.org/details/$identifier';
}

/// حفلات وتسجيلات خارجية مرتبة حسب القارئ.
/// المعرفات التالية لعناصر أرشيفية فعلية، والملفات الصوتية تُكتشف آليًا.
const List<HaflaLink> haflaLinks = [
  HaflaLink(
    sheikhName: 'محمد صديق المنشاوي',
    description: 'حفلات مجودة وتسجيلات خارجية نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Mohamed-siddiq-al-minshawi_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'عبدالباسط عبدالصمد',
    description: 'تسجيلات خارجية نادرة بجودة متنوعة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Abdel_Baset_Abd-Samad_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'محمد الليثي',
    description: 'حفلات وتسجيلات خارجية مجودة',
    identifier: 'Tasjilat-mojawada_kharijia_mohammadAl-laythi_up_by_muslem',
  ),
  HaflaLink(
    sheikhName: 'محمود علي البنا',
    description: 'حفلات مجودة وتسجيلات خارجية',
    identifier: 'Tasjilat-Mojawada_Kharijia_Mahmud_Ali_Al_Banna_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'شعبان الصياد',
    description: 'حفلات وتسجيلات خارجية نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Chaaben_Sayad_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'سيد متولي',
    description: 'حفلات خارجية مجودة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Saiid_Metwali_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'أحمد نعينع',
    description: 'حفلات مجودة وتسجيلات خارجية',
    identifier: 'Tasjilat-Mojawada_Kharijia_Ahmad_Nuina_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'الشحات محمد أنور',
    description: 'حفلات وتسجيلات خارجية نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Al-Chahhat-Mohamed-Anouar_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'راغب مصطفى غلوش',
    description: 'حفلات خارجية وتلاوات مجودة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Ragheb-Mostafa-Ghalwash_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'مصطفى إسماعيل',
    description: 'حفلات خارجية وتسجيلات نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Mustapha_Ismail_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'محمد رفعت',
    description: 'حفلات وتسجيلات خارجية نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Mohammed_Refat_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'محمد عبدالعزيز حصان',
    description: 'حفلات خارجية وتسجيلات مجودة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Mohamed-Abdelaziz-Hassan_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'سيد النقشبندي',
    description: 'تسجيلات وابتهالات وحفلات نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Sayed_Al_Nakshabandi_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'حجاج الهنداوي',
    description: 'تسجيلات خارجية وحفلات مجودة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Hajjaj-Al-Hindawi_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'حمدي الزامل',
    description: 'حفلات وتسجيلات خارجية',
    identifier: 'Tasjilat-Mojawada_Kharijia_Hamdi-Zamil_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'حلمي الجمل',
    description: 'حفلات وتسجيلات خارجية نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Hilmi-Al-Jamal_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'كامل يوسف البهتيمي',
    description: 'حفلات خارجية وتلاوات نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Kamel_Yusuf_Albahtemy_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'محمد أحمد شبيب',
    description: 'حفلات خارجية وتسجيلات مجودة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Mohammed-Ahmed-Chabib_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'عبدالفتاح الشعشاعي',
    description: 'حفلات خارجية وتسجيلات نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Abdul-Fatah-Alsheshai_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'محمود أبو الوفا الصعيدي',
    description: 'حفلات وتسجيلات خارجية',
    identifier: 'Tasjilat-Mojawada_Kharijia_Mahmoud-Abou-Al-Wafa_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'أبو العينين شعيشع',
    description: 'حفلات مجودة وتسجيلات خارجية',
    identifier: 'Tasjilat-Mojawada_Kharijia_Abou_Il_Ainin_Chichaa_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'أحمد الرزيقي',
    description: 'حفلات وتسجيلات خارجية',
    identifier: 'Tasjilat-Mojawada_Kharijia_Ahmed-Al-Rozaiki_uP_bY_mUSLEm',
  ),
  HaflaLink(
    sheikhName: 'محمد عبدالوهاب الطنطاوي',
    description: 'حفلات وتسجيلات خارجية نادرة',
    identifier: 'Tasjilat-Mojawada_Kharijia_Mohamed-Abdel-Wahab-Tantawi_uP_bY_mUSLEm',
  ),
];
