class PrayerTimeEntry {
  final String name;
  final DateTime time;
  final String icon; // material icon name key, resolved in UI layer

  const PrayerTimeEntry({required this.name, required this.time, required this.icon});
}

/// نموذج توضيحي لأوقات الصلاة اليومية.
/// الربط الحقيقي: يُستبدل هذا بحساب فعلي عبر حزمة `adhan` باستخدام
/// إحداثيات الموقع (Geolocator) وطريقة حساب مناسبة (أم القرى، رابطة العالم الإسلامي، إلخ).
class DailyPrayerTimes {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const DailyPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  List<PrayerTimeEntry> asList() => [
        PrayerTimeEntry(name: 'الفجر', time: fajr, icon: 'fajr'),
        PrayerTimeEntry(name: 'الشروق', time: sunrise, icon: 'sunrise'),
        PrayerTimeEntry(name: 'الظهر', time: dhuhr, icon: 'dhuhr'),
        PrayerTimeEntry(name: 'العصر', time: asr, icon: 'asr'),
        PrayerTimeEntry(name: 'المغرب', time: maghrib, icon: 'maghrib'),
        PrayerTimeEntry(name: 'العشاء', time: isha, icon: 'isha'),
      ];

  /// يحسب أقرب صلاة قادمة والوقت المتبقي لها.
  (String, Duration) nextPrayer() {
    final now = DateTime.now();
    for (final p in asList().where((e) => e.name != 'الشروق')) {
      if (p.time.isAfter(now)) {
        return (p.name, p.time.difference(now));
      }
    }
    // بعد العشاء: القادمة فجر الغد
    final tomorrowFajr = fajr.add(const Duration(days: 1));
    return ('الفجر', tomorrowFajr.difference(now));
  }
}
