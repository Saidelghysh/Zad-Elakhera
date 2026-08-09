import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/reciter_model.dart';

/// وصف قارئ مطلوب: الاسم كما يظهر بواجهة mp3quran.net العربية، اسم عرض
/// مختصر، الفئة (معاصر/نادر-كلاسيكي)، وهل نفضّل رواية "المجوَّد" له
/// (الأسلوب البطيء المُتقَن المعروف عن كبار القراء القدامى).
class _CuratedEntry {
  final String arabicName;
  final String displayName;
  final String category;
  final bool preferMujawwad;

  const _CuratedEntry({
    required this.arabicName,
    required this.displayName,
    required this.category,
    this.preferMujawwad = false,
  });
}

/// يجلب قراء مختارين من واجهة mp3quran.net المجانية (بدون مفتاح اشتراك)،
/// ويخزّن النتيجة محليًا. القائمة تشمل مجموعتين:
/// - "معاصرون": أصوات مألوفة يوميًا (العفاسي، السديس، ماهر، الغامدي، الدوسري).
/// - "نادرة/كلاسيكية": تلاوات القراء القدامى المشهورين بأسلوب التجويد المُتقَن
///   (عبدالباسط عبدالصمد، محمد صديق المنشاوي، محمود خليل الحصري، مصطفى إسماعيل).
class RecitationsApiService {
  static const String _baseUrl = 'https://www.mp3quran.net/api/v3';
  static const String _boxName = 'recitations_cache_box';
  static const String _recitersKey = 'curated_reciters_v2';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  static const List<_CuratedEntry> _curated = [
    // معاصرون
    _CuratedEntry(arabicName: 'مشاري راشد العفاسي', displayName: 'مشاري العفاسي', category: 'modern'),
    _CuratedEntry(arabicName: 'عبدالرحمن السديس', displayName: 'عبدالرحمن السديس', category: 'modern'),
    _CuratedEntry(arabicName: 'ماهر المعيقلي', displayName: 'ماهر المعيقلي', category: 'modern'),
    _CuratedEntry(arabicName: 'سعد الغامدي', displayName: 'سعد الغامدي', category: 'modern'),
    _CuratedEntry(arabicName: 'ياسر الدوسري', displayName: 'ياسر الدوسري', category: 'modern'),
    // نادرة / كلاسيكية (تُفضَّل رواية المجوَّد إن وُجدت)
    _CuratedEntry(
      arabicName: 'عبدالباسط عبدالصمد',
      displayName: 'عبدالباسط عبدالصمد',
      category: 'classic',
      preferMujawwad: true,
    ),
    _CuratedEntry(
      arabicName: 'محمد صديق المنشاوي',
      displayName: 'محمد صديق المنشاوي',
      category: 'classic',
      preferMujawwad: true,
    ),
    _CuratedEntry(
      arabicName: 'محمود خليل الحصري',
      displayName: 'محمود خليل الحصري',
      category: 'classic',
      preferMujawwad: true,
    ),
    _CuratedEntry(
      arabicName: 'مصطفى إسماعيل',
      displayName: 'مصطفى إسماعيل',
      category: 'classic',
      preferMujawwad: true,
    ),
  ];

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<List<Reciter>> getCuratedReciters() async {
    final cached = _box.get(_recitersKey) as String?;
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list
          .map((e) => Reciter(
                id: e['id'] as int,
                name: e['name'] as String,
                serverBaseUrl: e['server'] as String,
                category: e['category'] as String? ?? 'modern',
              ))
          .toList();
    }

    final response = await _dio.get('/reciters', queryParameters: {'language': 'ar'});
    final allReciters = response.data['reciters'] as List;

    final found = <Reciter>[];
    for (final entry in _curated) {
      final match = allReciters.firstWhere(
        (r) => (r['name'] as String).contains(entry.arabicName) || entry.arabicName.contains(r['name'] as String),
        orElse: () => null,
      );
      if (match == null) continue;

      final moshafList = match['moshaf'] as List;
      if (moshafList.isEmpty) continue;

      Map<String, dynamic> chosen;
      if (entry.preferMujawwad) {
        chosen = moshafList.firstWhere(
          (m) => (m['name'] as String).contains('مجود') || (m['name'] as String).toLowerCase().contains('mujawwad'),
          orElse: () => moshafList.firstWhere(
            (m) => (m['name'] as String).contains('مرتل'),
            orElse: () => moshafList.first,
          ),
        );
      } else {
        chosen = moshafList.firstWhere(
          (m) => (m['name'] as String).contains('مرتل') || (m['name'] as String).toLowerCase().contains('murattal'),
          orElse: () => moshafList.first,
        );
      }

      found.add(Reciter(
        id: match['id'] as int,
        name: entry.displayName,
        serverBaseUrl: chosen['server'] as String,
        category: entry.category,
      ));
    }

    if (found.isNotEmpty) {
      await _box.put(
        _recitersKey,
        jsonEncode(found
            .map((r) => {'id': r.id, 'name': r.name, 'server': r.serverBaseUrl, 'category': r.category})
            .toList()),
      );
    }
    return found;
  }
}
