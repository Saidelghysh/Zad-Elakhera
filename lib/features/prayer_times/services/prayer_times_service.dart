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

    // نُطبّع التاريخ لمنتصف الليل المحلي (بدون وقت اليوم الحالي) — الحساب
    // الفلكي يحتاج فقط اليوم/الشهر/السنة، وتمرير وقت اليوم الحالي كان يسبب
    // انزياحًا خاطئًا في بعض المناطق الزمنية ويُظهر عدّادًا صفريًا (00:00:00).
    final baseDate = forDate ?? DateTime.now();
    final normalizedDate = DateTime(baseDate.year, baseDate.month, baseDate.day);

    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: normalizedDate,
      calculationParameters: params,
    );

    return DailyPrayerTimes(
      fajr: prayerTimes.fajr.toLocal(),
      sunrise: prayerTimes.sunrise.toLocal(),
      dhuhr: prayerTimes.dhuhr.toLocal(),
      asr: prayerTimes.asr.toLocal(),
      maghrib: prayerTimes.maghrib.toLocal(),
      isha: prayerTimes.isha.toLocal(),
    );
  }

  /// اتجاه القبلة (بالدرجات من الشمال) لإحداثيات معينة.
  static double qiblaBearing(AppLocation location) {
    final coordinates = Coordinates(location.latitude, location.longitude);
    return Qibla.qibla(coordinates);
  }
}
