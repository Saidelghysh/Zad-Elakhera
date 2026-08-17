import 'package:dio/dio.dart';

class HaflaTrack {
  final String title;
  final String url;
  const HaflaTrack({required this.title, required this.url});
}

class HaflaApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
    ),
  );

  static Future<List<HaflaTrack>> getTracks(String identifier) async {
    final response = await _dio.get('https://archive.org/metadata/$identifier');
    final data = response.data;
    if (data is! Map || data['files'] is! List) {
      throw Exception('مصدر التسجيل لم يرجع قائمة الملفات.');
    }

    final files = data['files'] as List;
    final result = <HaflaTrack>[];
    final seen = <String>{};

    for (final item in files) {
      if (item is! Map) continue;
      final format = (item['format'] as String? ?? '').toLowerCase();
      final rawName = (item['name'] as String? ?? '').trim();
      if (rawName.isEmpty || seen.contains(rawName)) continue;

      final isMp3 = format.contains('mp3') || rawName.toLowerCase().endsWith('.mp3');
      final isJunk = rawName.startsWith('__') || rawName.contains('/__');
      if (!isMp3 || isJunk) continue;

      final titleFromApi = (item['title'] as String?)?.trim();
      final title = titleFromApi == null || titleFromApi.isEmpty
          ? rawName.split('/').last.replaceFirst(RegExp(r'\.mp3$', caseSensitive: false), '')
          : titleFromApi;

      final encodedPath = rawName.split('/').map(Uri.encodeComponent).join('/');
      result.add(HaflaTrack(
        title: title,
        url: 'https://archive.org/download/$identifier/$encodedPath',
      ));
      seen.add(rawName);
    }

    result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return result;
  }
}
