import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prayer_time_model.dart';
import '../services/location_service.dart';
import '../services/prayer_times_service.dart';

/// حالة أوقات الصلاة: البيانات + هل هي مبنية على موقع حقيقي أم احتياطي (مكة).
class PrayerTimesState {
  final DailyPrayerTimes times;
  final bool isFallbackLocation;

  const PrayerTimesState({required this.times, required this.isFallbackLocation});
}

/// مزوّد (Provider) يجلب موقع المستخدم الحقيقي ويحسب أوقات الصلاة الفعلية لليوم.
/// عند رفض إذن الموقع: يعيد أوقاتًا محسوبة على إحداثيات مكة المكرمة مع علم
/// [isFallbackLocation] = true، لتعرض الواجهة تنبيهًا واضحًا للمستخدم بدل الانهيار.
final prayerTimesProvider = FutureProvider.autoDispose<PrayerTimesState>((ref) async {
  try {
    final location = await LocationService.getCurrentLocation();
    final times = PrayerTimesCalculationService.calculate(location);
    return PrayerTimesState(times: times, isFallbackLocation: false);
  } on LocationPermissionDeniedException {
    final times = PrayerTimesCalculationService.calculate(LocationService.meccaFallback);
    return PrayerTimesState(times: times, isFallbackLocation: true);
  }
});

/// نبضة كل ثانية لإعادة حساب العد التنازلي للصلاة القادمة بدون إعادة جلب الموقع.
final prayerTimesTickProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});
