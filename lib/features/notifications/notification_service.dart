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
      // لا نعتمد على اسم المنطقة الزمنية للجهاز (زي "Africa/Cairo") لأن
      // كثير من الأجهزة ترجعه بصيغة مختصرة (زي "EET") ما يتعرف عليها
      // مصدر بيانات المناطق الزمنية، فيرجع صامتًا لتوقيت غرينتش (UTC)
      // ويسبب فارق ساعتين-ثلاثة بكل إشعار مجدول بدون أي خطأ ظاهر.
      // البديل الآمن: نحسب فرق التوقيت الفعلي (UTC Offset) مباشرة من
      // الجهاز، ونبني عليه منطقة زمنية ثابتة مضمونة الصحة دائمًا.
      final offset = DateTime.now().timeZoneOffset;
      final wholeHours = offset.inMinutes / 60;
      final roundedHours = wholeHours.round();
      // ملاحظة مهمة: مناطق "Etc/GMT" بمعيار IANA معكوسة الإشارة عمدًا
      // (Etc/GMT-3 تعني فعليًا UTC+3، وEtc/GMT+3 تعني UTC-3) — هذا معيار
      // قديم موروث ومو خطأ، فنطبّقه بالعكس هنا قصدًا ليطابق التوقيت الصحيح.
      final sign = roundedHours < 0 ? '+' : '-';
      tz.setLocalLocation(tz.getLocation('Etc/GMT$sign${roundedHours.abs()}'));

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
      if (alreadyGranted != true) {
        final granted = await androidPlugin?.requestNotificationsPermission();
        if (granted != true) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// إذن "التنبيهات الدقيقة" (Exact Alarms) — منفصل تمامًا عن إذن الإشعارات
  /// العادي، ومطلوب بأندرويد ١٢ فأعلى عشان الإشعار يوصل بالوقت المحدد
  /// بالضبط بدل ما يتأخر لدقائق (أو ما يوصل أصلًا) بسبب توفير الطاقة.
  static Future<bool> _hasExactAlarmPermission() async {
    try {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final canSchedule = await androidPlugin?.canScheduleExactNotifications();
      return canSchedule ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestExactAlarmPermission() async {
    try {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestExactAlarmsPermission();
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

    var hasExact = await _hasExactAlarmPermission();
    if (!hasExact) {
      await requestExactAlarmPermission();
      hasExact = await _hasExactAlarmPermission();
    }

    final error = await _scheduleOne(
      id: 9999,
      title: 'اختبار إشعار الأذان',
      body: 'لو سمعت هذا وصوت الأذان، الإعداد شغّال تمام ✅',
      time: DateTime.now().add(const Duration(seconds: 10)),
      adhanVoiceId: adhanVoiceId,
      useExact: hasExact,
    );

    final note = hasExact ? null : 'تنبيه: إذن "التنبيهات الدقيقة" غير ممنوح — قد يتأخر الإشعار قليلًا.';
    return ScheduleResult(
      scheduledCount: error == null ? 1 : 0,
      permissionGranted: true,
      lastError: error ?? note,
    );
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

    var hasExact = await _hasExactAlarmPermission();
    if (!hasExact) {
      await requestExactAlarmPermission();
      hasExact = await _hasExactAlarmPermission();
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
          useExact: hasExact,
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
          useExact: hasExact,
        );
        if (err == null) {
          scheduled++;
        } else {
          lastError = err;
        }
      }
    }

    final note = hasExact ? null : 'تنبيه: إذن "التنبيهات الدقيقة" غير ممنوح من إعدادات الجهاز — الإشعارات قد تتأخر.';
    return ScheduleResult(scheduledCount: scheduled, permissionGranted: true, lastError: lastError ?? note);
  }

  /// يجدول إشعار واحد، ويعيد null عند النجاح أو رسالة الخطأ عند الفشل.
  static Future<String?> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String? adhanVoiceId,
    required bool useExact,
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
        androidScheduleMode: useExact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle,
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
