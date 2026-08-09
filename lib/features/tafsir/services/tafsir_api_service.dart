import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tafsir_model.dart';

/// يجلب نصوص التفسير من واجهة Al Quran Cloud (نفس مصدر نص القرآن)، ويكتشف
/// معرّفات نُسخ التفسير المطلوبة تلقائيًا (بدل ترميزها يدويًا، لأنها قد
/// تختلف قليلًا)، ثم يخزّن النتائج محليًا لقراءة بدون إنترنت لاحقًا.
class TafsirApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _boxName = 'tafsir_cache_box';
  static const String _editionsKey = 'tafsir_editions_v1';
  static String _surahKey(String edition, int surah) => 'tafsir_${edition}_$surah';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  // كلمات مفتاحية (عربي + إنجليزي) ندوّر عليها ضمن أسماء نسخ التفسير —
  // بعض أسماء النسخ بالواجهة تجي بالإنجليزي حتى لو المحتوى نفسه عربي.
  static const Map<String, List<String>> _wantedTafsirs = {
    'التفسير الميسر': ['ميسر', 'muyassar'],
    'تفسير ابن كثير': ['كثير', 'kathir', 'katheer'],
    'تفسير السعدي': ['سعدي', 'سعدى', 'saadi', 'sadi', "sa'di"],
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

    final response = await _dio.get('/edition', queryParameters: {
      'format': 'text',
      'type': 'tafsir',
      'language': 'ar',
    });
    final all = response.data['data'] as List;

    final found = <TafsirEdition>[];
    for (final entry in _wantedTafsirs.entries) {
      final keywords = entry.value;
      final match = all.firstWhere(
        (e) {
          final name = (e['name'] as String? ?? '').toLowerCase();
          final englishName = (e['englishName'] as String? ?? '').toLowerCase();
          return keywords.any((kw) => name.contains(kw.toLowerCase()) || englishName.contains(kw.toLowerCase()));
        },
        orElse: () => null,
      );
      if (match == null) continue;
      found.add(TafsirEdition(identifier: match['identifier'] as String, name: entry.key));
    }

    if (found.isNotEmpty) {
      await _box.put(
        _editionsKey,
        jsonEncode(found.map((e) => {'identifier': e.identifier, 'name': e.name}).toList()),
      );
    }
    return found;
  }

  static Future<List<TafsirAyah>> getSurahTafsir(String editionIdentifier, int surahNumber) async {
    final key = _surahKey(editionIdentifier, surahNumber);
    final cached = _box.get(key) as String?;
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list.map((e) => TafsirAyah(numberInSurah: e['n'], text: e['t'])).toList();
    }

    final response = await _dio.get('/surah/$surahNumber/$editionIdentifier');
    final ayahsJson = response.data['data']['ayahs'] as List;
    final ayahs = ayahsJson
        .map((e) => TafsirAyah(numberInSurah: e['numberInSurah'] as int, text: e['text'] as String))
        .toList();

    await _box.put(key, jsonEncode(ayahs.map((a) => {'n': a.numberInSurah, 't': a.text}).toList()));
    return ayahs;
  }
}
