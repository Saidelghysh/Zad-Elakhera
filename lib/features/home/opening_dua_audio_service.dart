import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../quran/services/quran_api_service.dart';

/// يشغّل صوت آية "رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا" (سورة الإسراء:
/// ٢٤) بصوت الشيخ العفاسي عند فتح التطبيق — نفس الآية اللي يدعو بها المسلم
/// لوالديه، ومناسبة تمامًا لروح هذا التطبيق (صدقة جارية عن الوالد).
///
/// نحسب رقم الآية المطلق بالمصحف (يلزم بناء الرابط الصوتي) تلقائيًا من
/// نفس مصدر بيانات القرآن اللي نستخدمه أصلًا (بدل ترميزه يدويًا)، ونخزّنه
/// محليًا حتى ما نعيد الحساب كل مرة.
class OpeningDuaAudioService {
  static const String _boxName = 'opening_dua_box';
  static const String _absoluteNumberKey = 'ayah_17_24_absolute_number';

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<int?> _getAbsoluteAyahNumber() async {
    final cached = _box.get(_absoluteNumberKey) as int?;
    if (cached != null) return cached;

    try {
      final ayahs = await QuranApiService.getSurahAyahs(17); // سورة الإسراء
      final target = ayahs.firstWhere((a) => a.numberInSurah == 24);
      await _box.put(_absoluteNumberKey, target.number);
      return target.number;
    } catch (_) {
      return null;
    }
  }

  /// يشغّل الآية مرة واحدة (صوت العفاسي، جودة ١٢٨). يفشل بصمت لو تعذّر
  /// الاتصال بالإنترنت، بدل ما يعطّل فتح التطبيق.
  static Future<void> playOnce() async {
    try {
      final absoluteNumber = await _getAbsoluteAyahNumber();
      if (absoluteNumber == null) return;

      final url = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$absoluteNumber.mp3';
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {
      // تجاهل بصمت — الصوت ميزة إضافية، ما ينبغي يوقف التطبيق لو فشل.
    }
  }
}
