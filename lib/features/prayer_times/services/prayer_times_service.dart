import 'package:adhan_dart/adhan_dart.dart';
import '../models/prayer_time_model.dart';
import 'location_service.dart';

/// يحسب أوقات الصلاة الفعلية لليوم بالاعتماد على إحداثيات المستخدم.
/// طريقة الحساب الافتراضية: رابطة العالم الإسلامي (MuslimWorldLeague) — يمكن
/// تغييرها لاحقًا من الإعدادات (مثلاً أم القرى للمستخدمين في الخليج).
class PrayerTimesCalculationService {
  static DailyPrayerTimes calculate(AppLocation location, {DateTime? forDate}) {
    final coordinates = Coordinates(location.latitude, location.longitude);

    final params = CalculationMethodParameters.muslimWorldLeague();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: forDate ?? DateTime.now(),
      calculationParameters: params,
    );

    return DailyPrayerTimes(
      fajr: (prayerTimes.fajr ?? DateTime.now()).toLocal(),
      sunrise: (prayerTimes.sunrise ?? DateTime.now()).toLocal(),
      dhuhr: (prayerTimes.dhuhr ?? DateTime.now()).toLocal(),
      asr: (prayerTimes.asr ?? DateTime.now()).toLocal(),
      maghrib: (prayerTimes.maghrib ?? DateTime.now()).toLocal(),
      isha: (prayerTimes.isha ?? DateTime.now()).toLocal(),
    );
  }

  /// اتجاه القبلة (بالدرجات من الشمال) لإحداثيات معينة — يُستخدم كقيمة احتياطية
  /// إذا لم يتوفر حساس بوصلة في الجهاز (flutter_qiblah.androidDeviceSensorSupport() == false).
  static double qiblaBearing(AppLocation location) {
    final coordinates = Coordinates(location.latitude, location.longitude);
    return Qibla.qibla(coordinates);
  }
}
