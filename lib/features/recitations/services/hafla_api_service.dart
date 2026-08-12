import 'package:dio/dio.dart';

/// مقطع صوتي واحد من تسجيلات "الحفلات" الخارجية النادرة.
class HaflaTrack {
  final String title;
  final String url;
  const HaflaTrack({required this.title, required this.url});
}

/// يجلب قائمة الملفات الصوتية الحقيقية من أرشيف الإنترنت (archive.org)
/// وقت التشغيل مباشرة عبر واجهة البيانات الوصفية الرسمية للأرشيف
/// (archive.org/metadata/{identifier})، بحيث يبني التطبيق نفسه روابط
/// التشغيل من الأسماء الحقيقية للملفات (مهما كانت معقدة برموز أو تشكيل)
/// بدل محاولة كتابتها يدويًا وتعريضها لخطر الروابط المكسورة.
class HaflaApiService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 25),
  ));

  static Future<List<HaflaTrack>> getTracks(String identifier) async {
    final response = await _dio.get('https://archive.org/metadata/$identifier');
    final files = response.data['files'] as List;

    final mp3Files = files.where((f) {
      final format = (f['format'] as String? ?? '').toLowerCase();
      final name = (f['name'] as String? ?? '').toLowerCase();
      return format.contains('mp3') || name.endsWith('.mp3');
    }).toList();

    return mp3Files.map((f) {
      final rawName = f['name'] as String;
      final title = (f['title'] as String?)?.trim().isNotEmpty == true
          ? (f['title'] as String).trim()
          : rawName.replaceAll('.mp3', '');
      return HaflaTrack(
        title: title,
        url: 'https://archive.org/download/$identifier/${Uri.encodeComponent(rawName)}',
      );
    }).toList();
  }
}
