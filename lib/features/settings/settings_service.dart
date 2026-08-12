import 'package:hive_flutter/hive_flutter.dart';

/// خدمة حفظ إعدادات المستخدم محليًا: طريقة حساب أوقات الصلاة، المذهب،
/// وتفضيل تنبيهات الأذان (تفعيل فعلي للإشعارات يحتاج مكتبة إضافية لاحقًا).
class SettingsService {
  static const String boxName = 'settings_box';
  static const String calcMethodKey = 'calculation_method';
  static const String madhabKey = 'madhab';
  static const String athanNotifKey = 'athan_notifications_enabled';
  static const String adhanVoiceKey = 'adhan_voice_id';
  static const String reminderMinutesKey = 'reminder_minutes_before';
  static const String openingDuaAudioKey = 'opening_dua_audio_enabled';

  static Box get _box => Hive.box(boxName);

  static Future<void> init() async {
    await Hive.openBox(boxName);
  }

  // 'muslim_world_league' | 'umm_al_qura' | 'egyptian' | 'karachi'
  static String getCalculationMethod() =>
      _box.get(calcMethodKey, defaultValue: 'muslim_world_league') as String;

  static Future<void> setCalculationMethod(String value) async {
    await _box.put(calcMethodKey, value);
  }

  // 'shafi' | 'hanafi'
  static String getMadhab() => _box.get(madhabKey, defaultValue: 'shafi') as String;

  static Future<void> setMadhab(String value) async {
    await _box.put(madhabKey, value);
  }

  static bool getAthanNotificationsEnabled() =>
      _box.get(athanNotifKey, defaultValue: false) as bool;

  static Future<void> setAthanNotificationsEnabled(bool value) async {
    await _box.put(athanNotifKey, value);
  }

  static String getAdhanVoiceId() => _box.get(adhanVoiceKey, defaultValue: 'a9') as String;

  static Future<void> setAdhanVoiceId(String id) async {
    await _box.put(adhanVoiceKey, id);
  }

  static int getReminderMinutes() => _box.get(reminderMinutesKey, defaultValue: 10) as int;

  static Future<void> setReminderMinutes(int minutes) async {
    await _box.put(reminderMinutesKey, minutes);
  }

  static bool getOpeningDuaAudioEnabled() =>
      _box.get(openingDuaAudioKey, defaultValue: true) as bool;

  static Future<void> setOpeningDuaAudioEnabled(bool value) async {
    await _box.put(openingDuaAudioKey, value);
  }
}
