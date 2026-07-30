import 'package:geolocator/geolocator.dart';

/// نتيجة موقع بسيطة تحمل الإحداثيات وحالة الدقة (حقيقي أو احتياطي).
class AppLocation {
  final double latitude;
  final double longitude;
  final bool isFallback;

  const AppLocation({
    required this.latitude,
    required this.longitude,
    this.isFallback = false,
  });
}

/// يُستخدم عند تعطيل خدمة الموقع أو رفض الإذن، بحيث لا تنكسر الشاشة أبدًا.
class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);
}

class LocationService {
  // إحداثيات مكة المكرمة — تُستخدم كقيمة احتياطية فقط عند الحاجة لعرض شيء،
  // لكن الأصل هو طلب الإذن الفعلي من المستخدم أولًا.
  static const double _meccaLat = 21.4225;
  static const double _meccaLng = 39.8262;

  /// يطلب إذن الموقع إن لم يكن ممنوحًا، ثم يعيد الموقع الحالي.
  /// يرمي [LocationPermissionDeniedException] إذا رفض المستخدم الإذن نهائيًا،
  /// بحيث تقرر الواجهة (Screen) ماذا تعرض للمستخدم (مثلًا زر "فتح الإعدادات").
  static Future<AppLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationPermissionDeniedException('خدمة الموقع غير مفعّلة على الجهاز.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw LocationPermissionDeniedException('تم رفض إذن الوصول إلى الموقع.');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );

    return AppLocation(latitude: position.latitude, longitude: position.longitude);
  }

  /// موقع احتياطي (مكة) يُستخدم فقط لعرض تجربة توضيحية عند رفض الإذن،
  /// مع تنبيه واضح للمستخدم أن هذه ليست أوقات صلاته الفعلية.
  static const AppLocation meccaFallback = AppLocation(
    latitude: _meccaLat,
    longitude: _meccaLng,
    isFallback: true,
  );
}
