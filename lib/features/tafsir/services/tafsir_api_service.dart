import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tafsir_model.dart';

/// يجلب نصوص التفسير من مصدر Tafsir API المجاني (مرآة عبر شبكة jsDelivr
/// السريعة: https://github.com/spa5k/tafsir_api) — نفس الطريقة يعتمدها
/// مطورون كثير لأن فيها أكثر من ٢٥ نسخة تفسير موثّقة بدقة.
///
/// نجلب فهرس النُسخ أول مرة لتحديد المعرّف (slug) الصحيح لكل من: الميسر،
/// ابن كثير، السعدي (بدل ترميزها يدويًا، تحسبًا لأي تغيير مستقبلي)، ثم نجلب
/// تفسير كل آية على حدة (الصيغة الموثّقة رسميًا: slug/surah/ayah.json)
/// بالتوازي، ونتجاهل أي آية يفشل تحميلها بدل ما يوقف الشاشة كاملة.
class TafsirApiService {
  static const String _baseUrl = 'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir';
  static const String _boxName = 'tafsir_cache_box_v2';
  static const String _editionsKey = 'tafsir_editions_v2';
  static String _surahKey(String edition, int surah) => 'tafsir_${edition}_$surah';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  // كلمات مفتاحية (اسم النسخة كما يظهر بفهرس editions.json) للتعرّف على
  // النُسخ الثلاث المطلوبة، بحث مرن يشمل عربي وإنجليزي.
  static const Map<String, List<String>> _wantedTafsirs = {
    'التفسير الميسر': ['ميسر', 'muyassar'],
    'تفسير ابن كثير': ['كثير', 'kathir', 'katheer'],
    'تفسير السعدي': ['سعدي', 'سعدى', 'saddi', 'saadi', 'sadi'],
  };

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<List<TafsirEdition>> getAvailableEditions() async {
    final cached = _box.get(_editionsKey) as String?;
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list.map((e) => TafsirEdition(identifier: e['identifier'], name: e['name'])).toList();
    }

    final response = await _dio.get('/editions.json');
    final all = response.data as List;

    final found = <TafsirEdition>[];
    for (final entry in _wantedTafsirs.entries) {
      final keywords = entry.value;
      final match = all.firstWhere(
        (e) {
          final name = (e['name'] as String? ?? '').toLowerCase();
          final slug = (e['slug'] as String? ?? '').toLowerCase();
          final language = (e['language'] as String? ?? '').toLowerCase();
          if (language != 'arabic' && language.isNotEmpty) return false;
          return keywords.any((kw) => name.contains(kw.toLowerCase()) || slug.contains(kw.toLowerCase()));
        },
        orElse: () => null,
      );
      if (match == null) continue;
      found.add(TafsirEdition(identifier: match['slug'] as String, name: entry.key));
    }

    if (found.isNotEmpty) {
      await _box.put(
        _editionsKey,
        jsonEncode(found.map((e) => {'identifier': e.identifier, 'name': e.name}).toList()),
      );
    }
    return found;
  }

  /// يجلب تفسير كل آيات سورة معيّنة، آية آية بالتوازي (الصيغة الموثّقة:
  /// {slug}/{surah}/{ayah}.json)، ويتجاهل أي آية تفشل بدل ما يكسر الشاشة.
  static Future<List<TafsirAyah>> getSurahTafsir(
    String editionIdentifier,
    int surahNumber,
    int ayahCount,
  ) async {
    final key = _surahKey(editionIdentifier, surahNumber);
    final cached = _box.get(key) as String?;
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list.map((e) => TafsirAyah(numberInSurah: e['n'], text: e['t'])).toList();
    }

    final futures = List.generate(
      ayahCount,
      (i) => _fetchOneAyah(editionIdentifier, surahNumber, i + 1),
    );
    final results = await Future.wait(futures);
    final ayahs = results.whereType<TafsirAyah>().toList();

    if (ayahs.isNotEmpty) {
      await _box.put(key, jsonEncode(ayahs.map((a) => {'n': a.numberInSurah, 't': a.text}).toList()));
    }
    return ayahs;
  }

  static Future<TafsirAyah?> _fetchOneAyah(String slug, int surah, int ayah) async {
    try {
      final response = await _dio.get('/$slug/$surah/$ayah.json');
      final data = response.data;
      if (data is! Map) return null;

      // بحث مرن عن حقل النص (أسماء الحقول قد تختلف قليلًا بين النُسخ).
      final text = (data['text'] ?? data['content'] ?? data['tafsir'] ?? data['arabicText']) as String?;
      if (text == null || text.trim().isEmpty) return null;

      return TafsirAyah(numberInSurah: ayah, text: text.trim());
    } catch (_) {
      return null;
    }
  }
}
