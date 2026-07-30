import 'package:hive_flutter/hive_flutter.dart';

/// خدمة حفظ عداد التسبيح والهدف المخصص وإحصائيات بسيطة.
class TasbeehService {
  static const String boxName = 'tasbeeh_box';
  static const String countKey = 'current_count';
  static const String targetKey = 'target_count';
  static const String totalKey = 'lifetime_total';

  static Box get _box => Hive.box(boxName);

  static Future<void> init() async {
    await Hive.openBox(boxName);
  }

  static int getCount() => _box.get(countKey, defaultValue: 0) as int;
  static int getTarget() => _box.get(targetKey, defaultValue: 33) as int;
  static int getLifetimeTotal() => _box.get(totalKey, defaultValue: 0) as int;

  static Future<int> increment() async {
    final newCount = getCount() + 1;
    await _box.put(countKey, newCount);
    await _box.put(totalKey, getLifetimeTotal() + 1);
    return newCount;
  }

  static Future<void> reset() async {
    await _box.put(countKey, 0);
  }

  static Future<void> setTarget(int target) async {
    await _box.put(targetKey, target);
  }
}
