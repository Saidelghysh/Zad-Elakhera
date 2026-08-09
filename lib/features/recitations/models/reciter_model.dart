/// قارئ + رابط الخادم الأساسي لملفات سوره الصوتية (mp3quran.net).
class Reciter {
  final int id;
  final String name;
  final String serverBaseUrl; // ينتهي بشرطة مائلة، مثال: https://server8.mp3quran.net/afs/
  final String category; // 'modern' | 'classic'

  const Reciter({
    required this.id,
    required this.name,
    required this.serverBaseUrl,
    this.category = 'modern',
  });

  /// رابط ملف سورة معيّنة بصوت هذا القارئ (ترقيم السورة بثلاث خانات، مثل 001.mp3).
  String surahUrl(int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    return '$serverBaseUrl$padded.mp3';
  }
}
