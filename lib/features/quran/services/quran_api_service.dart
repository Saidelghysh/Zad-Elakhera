import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/surah_model.dart';

/// يجلب نص القرآن الكريم (الرسم العثماني القياسي) من واجهة Al Quran Cloud
/// المجانية (بدون مفتاح اشتراك: https://alquran.cloud/api)، ويخزّن النتائج
/// محليًا (Hive) بحيث تُقرأ لاحقًا بدون إنترنت بعد أول تحميل لكل سورة.
class QuranApiService {
  static const String _baseUrl = 'https://api.alquran.cloud/v1';
  static const String _boxName = 'quran_cache_box';
  static const String _surahListKey = 'surah_list';
  static String _surahKey(int number) => 'surah_$number';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  /// قائمة السور الـ ١١٤ (بيانات وصفية فقط: الاسم، عدد الآيات...).
  static Future<List<SurahInfo>> getSurahList() async {
    final cached = _box.get(_surahListKey) as String?;
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list.map((e) => SurahInfo.fromJson(e as Map<String, dynamic>)).toList();
    }

    final response = await _dio.get('/surah');
    final data = response.data['data'] as List;
    final surahs = data.map((e) => SurahInfo.fromJson(e as Map<String, dynamic>)).toList();

    await _box.put(_surahListKey, jsonEncode(surahs.map((s) => s.toJson()).toList()));
    return surahs;
  }

  /// آيات سورة معيّنة بالرسم العثماني (edition: quran-uthmani).
  static Future<List<Ayah>> getSurahAyahs(int surahNumber) async {
    final cached = _box.get(_surahKey(surahNumber)) as String?;
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      return list.map((e) => Ayah.fromJson(e as Map<String, dynamic>)).toList();
    }

    final response = await _dio.get('/surah/$surahNumber/quran-uthmani');
    final ayahsJson = response.data['data']['ayahs'] as List;
    final ayahs = ayahsJson.map((e) => Ayah.fromJson(e as Map<String, dynamic>)).toList();

    await _box.put(_surahKey(surahNumber), jsonEncode(ayahs.map((a) => a.toJson()).toList()));
    return ayahs;
  }

  // آخر موضع قراءة (سورة + رقم آية) لعرضه في "آخر قراءة" بالشاشة الرئيسية لاحقًا.
  static Future<void> saveLastRead(int surahNumber, int ayahNumberInSurah) async {
    await _box.put('last_read_surah', surahNumber);
    await _box.put('last_read_ayah', ayahNumberInSurah);
  }

  static (int, int)? getLastRead() {
    final surah = _box.get('last_read_surah') as int?;
    final ayah = _box.get('last_read_ayah') as int?;
    if (surah == null || ayah == null) return null;
    return (surah, ayah);
  }
}
