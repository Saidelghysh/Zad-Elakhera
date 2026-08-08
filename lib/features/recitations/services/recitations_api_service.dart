import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/reciter_model.dart';

/// يجلب قراء مختارين ومشهورين (بأصواتهم) من واجهة mp3quran.net المجانية
/// (https://mp3quran.net/api) — بدون مفتاح اشتراك، ويخزّن النتيجة محليًا.
///
/// نطلب قائمة القراء كاملة (٢٠٠+) ثم نُصفّي على أسماء أربعة قراء مشهورين
/// مذكورين في مواصفات التطبيق، بدل ترميز روابط الخوادم يدويًا (أكثر أمانًا
/// لأن أرقام الخوادم على mp3quran.net قد تتغيّر بمرور الوقت).
class RecitationsApiService {
  static const String _baseUrl = 'https://www.mp3quran.net/api/v3';
  static const String _boxName = 'recitations_cache_box';
  static const String _recitersKey = 'curated_reciters';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  // أسماء القراء المطلوبين (كما تُكتب عادة بواجهة mp3quran.net العربية)
  // مع اسم عرض مختصر أنيق للواجهة.
  static const Map<String, String> _curatedNames = {
    'مشاري راشد العفاسي': 'العفاسي',
    'عبدالرحمن السديس': 'السديس',
    'ماهر المعيقلي': 'ماهر المعيقلي',
    'سعد الغامدي': 'سعد الغامدي',
  };

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
              ))
          .toList();
    }

    final response = await _dio.get('/reciters', queryParameters: {'language': 'ar'});
    final allReciters = response.data['reciters'] as List;

    final found = <Reciter>[];
    for (final targetName in _curatedNames.keys) {
      final match = allReciters.firstWhere(
        (r) => (r['name'] as String).contains(targetName) || targetName.contains(r['name'] as String),
        orElse: () => null,
      );
      if (match == null) continue;
      final moshafList = match['moshaf'] as List;
      if (moshafList.isEmpty) continue;
      // نفضّل رواية "مرتل" إن وجدت، وإلا نأخذ أول رواية متاحة.
      final murattal = moshafList.firstWhere(
        (m) => (m['name'] as String).contains('مرتل') || (m['name'] as String).toLowerCase().contains('murattal'),
        orElse: () => moshafList.first,
      );
      found.add(Reciter(
        id: match['id'] as int,
        name: _curatedNames[targetName]!,
        serverBaseUrl: murattal['server'] as String,
      ));
    }

    if (found.isNotEmpty) {
      await _box.put(
        _recitersKey,
        jsonEncode(found.map((r) => {'id': r.id, 'name': r.name, 'server': r.serverBaseUrl}).toList()),
      );
    }
    return found;
  }
}
