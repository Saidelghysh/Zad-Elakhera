import 'package:hive_flutter/hive_flutter.dart';

/// خدمة تخزين عداد الدعوات محليًا (Hive) بحيث يبقى محفوظًا بين فتحات التطبيق،
/// ومهيأ لاحقًا للمزامنة مع Firebase Firestore ليكون عداد إجمالي لكل المستخدمين.
class DuaCounterService {
  static const String boxName = 'dua_box';
  static const String key = 'total_dua_count';

  static Box get _box => Hive.box(boxName);

  static Future<void> init() async {
    await Hive.openBox(boxName);
    // قيمة ابتدائية توضيحية (تُستبدل بقيمة حقيقية قادمة من Firestore عند الربط).
    if (!_box.containsKey(key)) {
      await _box.put(key, 124583);
    }
  }

  static int getCount() => _box.get(key, defaultValue: 0) as int;

  static Future<int> increment() async {
    final newValue = getCount() + 1;
    await _box.put(key, newValue);
    return newValue;
  }
}
