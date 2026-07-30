import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/dua_walidi/dua_counter_service.dart';
import 'features/tasbeeh/tasbeeh_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // اتجاه عمودي فقط — يليق بتطبيق قرآن/أذكار.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة قاعدة البيانات المحلية (Hive) لتخزين عدادات الدعاء والتسبيح
  // والمفضلة وآخر موضع قراءة، بدون حاجة إلى اتصال إنترنت.
  await Hive.initFlutter();
  await DuaCounterService.init();
  await TasbeehService.init();

  // TODO: تهيئة Firebase هنا عند إضافة:
  // - Firebase.initializeApp()
  // - FirebaseAuth (تسجيل دخول اختياري)
  // - Firestore (مزامنة عداد الدعوات عالميًا + لوحة التحكم الإدارية)
  // - Firebase Messaging (إشعارات الأذان والتذكيرات)

  runApp(const ProviderScope(child: ZadAlakhiraApp()));
}

class ZadAlakhiraApp extends StatelessWidget {
  const ZadAlakhiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'زاد الآخرة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
