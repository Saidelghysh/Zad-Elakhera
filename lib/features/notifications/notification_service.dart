import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../prayer_times/models/prayer_time_model.dart';

/// خدمة جدولة إشعارات دخول وقت الصلاة (بصوت أذان حقيقي حسب الصوت المختار
/// بالإعدادات) + تنبيه "اقتربت صلاة ..." قبل الوقت بعدة دقائق (بصوت تنبيه
/// عادي). تستخدم flutter_local_notifications + timezone.
///
/// كل استدعاء لمكوّن الإشعارات الأصلي (Android) محاط بمعالجة أخطاء كاملة —
/// ميزة الإشعارات إضافية وما ينبغي أي خلل فيها يوقف التطبيق كامل.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
      } catch (_) {
        // لو ما قدر يحدد المنطقة الزمنية بالاسم، يبقى على UTC كخيار آمن.
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _plugin.initialize(initSettings);
      _initialized = true;
    } catch (_) {
      // لو فشلت التهيئة لأي سبب، نتجاهل بصمت — الإشعارات ميزة إضافية.
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// يرسل إشعار تجريبي بصوت الأذان المختار خلال ١٠ ثوانٍ — للتأكد الفوري
  /// إن الإشعارات والصوت شغّالين فعليًا قبل ما تعتمد على الجدولة اليومية.
  static Future<void> sendTestNotification(String adhanVoiceId) async {
    await init();
    await requestPermission();
    await _scheduleOne(
      id: 9999,
      title: 'اختبار إشعار الأذان',
      body: 'لو سمعت هذا وصوت الأذان، الإعداد شغّال تمام ✅',
      time: DateTime.now().add(const Duration(seconds: 10)),
      adhanVoiceId: adhanVoiceId,
    );
  }

  /// يجدول إشعارات اليوم الحالي: تنبيه قبل كل صلاة بـ [reminderMinutes] دقيقة
  /// (بصوت تنبيه عادي)، وإشعار عند دخول الوقت نفسه (بصوت أذان [adhanVoiceId]
  /// الحقيقي المختار بالإعدادات). يمسح أي جدولة سابقة أولًا لتفادي التكرار.
  static Future<void> scheduleForToday(
    DailyPrayerTimes times, {
    required int reminderMinutes,
    required String adhanVoiceId,
  }) async {
    await init();
    if (!_initialized) return;

    try {
      await _plugin.cancelAll();
    } catch (_) {
      // لو فشل المسح (خطأ معروف بالمكتبة أحيانًا)، نكمل الجدولة الجديدة
      // فوقها بدل ما نوقف كل شي — الإشعارات القديمة هتُستبدل بنفس المعرّفات.
    }

    final entries = times.asList().where((e) => e.name != 'الشروق');
    int id = 0;

    for (final entry in entries) {
      final now = DateTime.now();

      // إشعار "دخل وقت الصلاة" — بصوت الأذان الحقيقي المختار.
      if (entry.time.isAfter(now)) {
        await _scheduleOne(
          id: id++,
          title: 'حان الآن وقت صلاة ${entry.name}',
          body: 'زاد الآخرة — صلِّ في وقتها 🕌',
          time: entry.time,
          adhanVoiceId: adhanVoiceId,
        );
      }

      // تنبيه "اقتربت صلاة ..." قبل الوقت — بصوت تنبيه عادي (مو الأذان كامل).
      final reminderTime = entry.time.subtract(Duration(minutes: reminderMinutes));
      if (reminderTime.isAfter(now)) {
        await _scheduleOne(
          id: id++,
          title: 'اقتربت صلاة ${entry.name}',
          body: 'باقي $reminderMinutes دقائق على أذان ${entry.name}',
          time: reminderTime,
          adhanVoiceId: null,
        );
      }
    }
  }

  static Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String? adhanVoiceId,
  }) async {
    try {
      // نستخدم قناة مختلفة لكل صوت أذان مختار (Android يقفل صوت القناة عند
      // إنشائها لأول مرة ولا يقبل تغييره لاحقًا لنفس المعرّف)، بحيث لما
      // يغيّر المستخدم صوت الأذان بالإعدادات، تُنشأ قناة جديدة بالصوت الجديد.
      final channelId = adhanVoiceId != null ? 'prayer_azan_channel_$adhanVoiceId' : 'prayer_reminder_channel';
      final channelName = adhanVoiceId != null ? 'أذان الصلاة' : 'تذكير قبل الصلاة';

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: adhanVoiceId != null ? 'إشعار دخول وقت الصلاة بصوت الأذان' : 'تنبيه قبل دخول وقت الصلاة',
        importance: Importance.high,
        priority: Priority.high,
        sound: adhanVoiceId != null ? RawResourceAndroidNotificationSound('azan_$adhanVoiceId') : null,
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
      final details = NotificationDetails(android: androidDetails);

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(time, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // لو فشلت جدولة إشعار واحد لأي سبب، نتجاهله بدل ما نكسر التطبيق.
    }
  }

  static Future<void> cancelAll() async {
    await init();
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {
      // نتجاهل بصمت.
    }
  }
}
