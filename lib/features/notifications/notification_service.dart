import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../prayer_times/models/prayer_time_model.dart';

/// نتيجة عملية الجدولة — تفاصيل حقيقية بدل نجاح/فشل صامت، عشان تقدر تعرف
/// بالضبط وش صار (كم إشعار انجدول، وهل الإذن ممنوح، وآخر خطأ لو صار).
class ScheduleResult {
  final int scheduledCount;
  final bool permissionGranted;
  final String? lastError;

  const ScheduleResult({
    required this.scheduledCount,
    required this.permissionGranted,
    this.lastError,
  });
}

/// خدمة جدولة إشعارات دخول وقت الصلاة (بصوت أذان حقيقي حسب الصوت المختار
/// بالإعدادات) + تنبيه "اقتربت صلاة ..." قبل الوقت بعدة دقائق (بصوت تنبيه
/// عادي). تستخدم flutter_local_notifications + timezone.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<bool> init() async {
    if (_initialized) return true;
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
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      // أولًا نتحقق هل الإذن ممنوح أصلًا (بعض الأجهزة تمنحه تلقائيًا).
      final alreadyGranted = await androidPlugin?.areNotificationsEnabled();
      if (alreadyGranted == true) return true;

      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// عدد الإشعارات المجدولة فعليًا حاليًا لدى نظام أندرويد — أداة تحقق
  /// حقيقية بدل الاعتماد على افتراض إن الجدولة نجحت.
  static Future<int> getPendingCount() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.length;
    } catch (_) {
      return -1; // -1 تعني تعذّر الفحص نفسه
    }
  }

  /// يرسل إشعار تجريبي بصوت الأذان المختار خلال ١٠ ثوانٍ.
  static Future<ScheduleResult> sendTestNotification(String adhanVoiceId) async {
    final initOk = await init();
    if (!initOk) {
      return const ScheduleResult(scheduledCount: 0, permissionGranted: false, lastError: 'تعذّرت تهيئة نظام الإشعارات على هذا الجهاز.');
    }
    final granted = await requestPermission();
    if (!granted) {
      return const ScheduleResult(
        scheduledCount: 0,
        permissionGranted: false,
        lastError: 'إذن الإشعارات مرفوض. فعّله يدويًا من إعدادات الجهاز → التطبيقات → زاد الآخرة → الإشعارات.',
      );
    }

    final error = await _scheduleOne(
      id: 9999,
      title: 'اختبار إشعار الأذان',
      body: 'لو سمعت هذا وصوت الأذان، الإعداد شغّال تمام ✅',
      time: DateTime.now().add(const Duration(seconds: 10)),
      adhanVoiceId: adhanVoiceId,
    );

    return ScheduleResult(scheduledCount: error == null ? 1 : 0, permissionGranted: true, lastError: error);
  }

  /// يجدول إشعارات اليوم الحالي، ويعيد نتيجة حقيقية (كم إشعار انجدول فعلًا).
  static Future<ScheduleResult> scheduleForToday(
    DailyPrayerTimes times, {
    required int reminderMinutes,
    required String adhanVoiceId,
  }) async {
    final initOk = await init();
    if (!initOk) {
      return const ScheduleResult(scheduledCount: 0, permissionGranted: false, lastError: 'تعذّرت تهيئة نظام الإشعارات على هذا الجهاز.');
    }

    final granted = await requestPermission();
    if (!granted) {
      return const ScheduleResult(
        scheduledCount: 0,
        permissionGranted: false,
        lastError: 'إذن الإشعارات مرفوض. فعّله يدويًا من إعدادات الجهاز → التطبيقات → زاد الآخرة → الإشعارات.',
      );
    }

    try {
      await _plugin.cancelAll();
    } catch (_) {
      // نكمل الجدولة الجديدة فوقها حتى لو فشل المسح.
    }

    final entries = times.asList().where((e) => e.name != 'الشروق');
    int id = 0;
    int scheduled = 0;
    String? lastError;

    for (final entry in entries) {
      final now = DateTime.now();

      if (entry.time.isAfter(now)) {
        final err = await _scheduleOne(
          id: id++,
          title: 'حان الآن وقت صلاة ${entry.name}',
          body: 'زاد الآخرة — صلِّ في وقتها 🕌',
          time: entry.time,
          adhanVoiceId: adhanVoiceId,
        );
        if (err == null) {
          scheduled++;
        } else {
          lastError = err;
        }
      }

      final reminderTime = entry.time.subtract(Duration(minutes: reminderMinutes));
      if (reminderTime.isAfter(now)) {
        final err = await _scheduleOne(
          id: id++,
          title: 'اقتربت صلاة ${entry.name}',
          body: 'باقي $reminderMinutes دقائق على أذان ${entry.name}',
          time: reminderTime,
          adhanVoiceId: null,
        );
        if (err == null) {
          scheduled++;
        } else {
          lastError = err;
        }
      }
    }

    return ScheduleResult(scheduledCount: scheduled, permissionGranted: true, lastError: lastError);
  }

  /// يجدول إشعار واحد، ويعيد null عند النجاح أو رسالة الخطأ عند الفشل.
  static Future<String?> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String? adhanVoiceId,
  }) async {
    try {
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
      return null;
    } catch (e) {
      return e.toString();
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
