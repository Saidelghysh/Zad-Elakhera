/// بيانات سورة (بيانات وصفية: رقمها، اسمها، عدد آياتها، مكان نزولها).
class SurahInfo {
  final int number;
  final String name; // العربي، مثل "سورة البقرة"
  final String englishName;
  final String englishNameTranslation;
  final String revelationType; // "Meccan" | "Medinan"
  final int numberOfAyahs;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  factory SurahInfo.fromJson(Map<String, dynamic> json) {
    return SurahInfo(
      number: json['number'] as int,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      revelationType: json['revelationType'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'name': name,
        'englishName': englishName,
        'englishNameTranslation': englishNameTranslation,
        'revelationType': revelationType,
        'numberOfAyahs': numberOfAyahs,
      };

  bool get isMeccan => revelationType == 'Meccan';
}

/// آية واحدة من نص المصحف (رسم عثماني قياسي).
class Ayah {
  final int number; // الرقم المطلق في المصحف كامل (1-6236)
  final String text;
  final int numberInSurah;
  final int juz;

  const Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] as int,
      text: json['text'] as String,
      numberInSurah: json['numberInSurah'] as int,
      juz: json['juz'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'text': text,
        'numberInSurah': numberInSurah,
        'juz': juz,
      };
}
