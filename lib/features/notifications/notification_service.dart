import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../prayer_times/models/prayer_time_model.dart';

/// خدمة جدولة إشعارات دخول وقت الصلاة + تنبيه قبل الصلاة بعدة دقائق
/// ("اقتربت صلاة ..."). تستخدم flutter_local_notifications + timezone.
///
/// ملاحظة: الجدولة تغطي أوقات اليوم الحالي فقط، وتُعاد تلقائيًا كل مرة
/// يُحسب فيها جدول الصلاة من جديد (عند فتح التطبيق أو تحديث الموقع)،
/// لذا يُفضّل فتح التطبيق يوميًا للحفاظ على تحديث الجدول.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      // لو ما قدر يحدد المنطقة الزمنية بالاسم، يبقى على UTC كخيار آمن
      // بدل ما ينهار — الفرق هنا بالعرض بس، الجدولة نفسها تعتمد على
      // فروقات التوقيت المحلي المحسوبة مسبقًا من DateTime.now().
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? false;
  }

  /// يجدول إشعارات اليوم الحالي: تنبيه قبل كل صلاة بـ [reminderMinutes] دقيقة،
  /// وإشعار عند دخول الوقت نفسه. يمسح أي جدولة سابقة أولًا لتفادي التكرار.
  static Future<void> scheduleForToday(DailyPrayerTimes times, {required int reminderMinutes}) async {
    await init();
    await _plugin.cancelAll();

    final entries = times.asList().where((e) => e.name != 'الشروق');
    int id = 0;

    for (final entry in entries) {
      final now = DateTime.now();

      // إشعار "دخل وقت الصلاة"
      if (entry.time.isAfter(now)) {
        await _scheduleOne(
          id: id++,
          title: 'حان الآن وقت صلاة ${entry.name}',
          body: 'زاد الآخرة — صلِّ في وقتها 🕌',
          time: entry.time,
        );
      }

      // تنبيه "اقتربت صلاة ..." قبل الوقت بعدة دقائق
      final reminderTime = entry.time.subtract(Duration(minutes: reminderMinutes));
      if (reminderTime.isAfter(now)) {
        await _scheduleOne(
          id: id++,
          title: 'اقتربت صلاة ${entry.name}',
          body: 'باقي $reminderMinutes دقائق على أذان ${entry.name}',
          time: reminderTime,
        );
      }
    }
  }

  static Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_times_channel',
      'مواقيت الصلاة',
      channelDescription: 'تنبيهات دخول وقت الصلاة والتذكير قبلها',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(time, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // لو فشلت الجدولة الدقيقة لأي سبب (مثلًا صلاحية التنبيهات الدقيقة
      // مرفوضة على بعض الأجهزة)، نتجاهل هذا الإشعار بدل ما نكسر التطبيق.
    }
  }

  static Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}
