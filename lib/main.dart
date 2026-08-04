import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/dua_walidi/dua_counter_service.dart';
import 'features/tasbeeh/tasbeeh_service.dart';

Future<void> main() async {
  // يجعل رسائل الخطأ تظهر بوضوح على الشاشة حتى في وضع Release
  // (بدل شاشة بيضاء فاضية بدون أي تفاصيل عن سبب المشكلة).
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF04060D),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Text(
              'حدث خطأ:\n\n${details.exceptionAsString()}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await Hive.initFlutter();
    await DuaCounterService.init();
    await TasbeehService.init();

    runApp(const ProviderScope(child: ZadAlakhiraApp()));
  }, (error, stack) {
    // لو صار خطأ قبل حتى ما يفتح أي شاشة، نعرضه بدل ما يطلع بياض فاضي.
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF04060D),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Text(
                  'حدث خطأ عند بدء التشغيل:\n\n$error',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  });
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
