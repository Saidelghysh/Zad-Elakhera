import 'package:adhan_dart/adhan_dart.dart';
import '../../settings/settings_service.dart';
import '../models/prayer_time_model.dart';
import 'location_service.dart';

/// يحسب أوقات الصلاة الفعلية لليوم بالاعتماد على إحداثيات المستخدم،
/// وطريقة الحساب + المذهب المحفوظين في الإعدادات (SettingsService).
class PrayerTimesCalculationService {
  static CalculationParameters _resolveMethod() {
    switch (SettingsService.getCalculationMethod()) {
      case 'umm_al_qura':
        return CalculationMethodParameters.ummAlQura();
      case 'egyptian':
        return CalculationMethodParameters.egyptian();
      case 'karachi':
        return CalculationMethodParameters.karachi();
      case 'muslim_world_league':
      default:
        return CalculationMethodParameters.muslimWorldLeague();
    }
  }

  static DailyPrayerTimes calculate(AppLocation location, {DateTime? forDate}) {
    final coordinates = Coordinates(location.latitude, location.longitude);

    final params = _resolveMethod();
    params.madhab = SettingsService.getMadhab() == 'hanafi' ? Madhab.hanafi : Madhab.shafi;

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

  /// اتجاه القبلة (بالدرجات من الشمال) لإحداثيات معينة.
  static double qiblaBearing(AppLocation location) {
    final coordinates = Coordinates(location.latitude, location.longitude);
    return Qibla.qibla(coordinates);
  }
}
