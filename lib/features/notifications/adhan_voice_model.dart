/// صوت أذان (مؤذن) — روابط حقيقية من شبكة Islamic Network (نفس الجهة اللي
/// تقدّم واجهة القرآن اللي نستخدمها، aladhan.com/download-adhans).
class AdhanVoice {
  final String id;
  final String name;
  final String url;

  const AdhanVoice({required this.id, required this.name, required this.url});
}

const List<AdhanVoice> adhanVoices = [
  AdhanVoice(
    id: 'a9',
    name: 'مشاري راشد العفاسي',
    url: 'https://cdn.aladhan.com/audio/adhans/a9.mp3',
  ),
  AdhanVoice(
    id: 'a4',
    name: 'العفاسي (أذان دبي)',
    url: 'https://cdn.aladhan.com/audio/adhans/a4.mp3',
  ),
  AdhanVoice(
    id: 'a11',
    name: 'منصور الزهراني',
    url: 'https://cdn.aladhan.com/audio/adhans/a11-mansour-al-zahrani.mp3',
  ),
  AdhanVoice(
    id: 'a1',
    name: 'أحمد النافس',
    url: 'https://cdn.aladhan.com/audio/adhans/a1.mp3',
  ),
  AdhanVoice(
    id: 'a2',
    name: 'حافظ مصطفى أوزجان (تركيا)',
    url: 'https://cdn.aladhan.com/audio/adhans/a2.mp3',
  ),
];

AdhanVoice adhanVoiceById(String id) {
  return adhanVoices.firstWhere((v) => v.id == id, orElse: () => adhanVoices.first);
}
