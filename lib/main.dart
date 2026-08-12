import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/dua_walidi/dua_counter_service.dart';
import 'features/home/opening_dua_audio_service.dart';
import 'features/quran/services/quran_api_service.dart';
import 'features/recitations/services/recitations_api_service.dart';
import 'features/settings/settings_service.dart';
import 'features/tafsir/services/tafsir_api_service.dart';
import 'features/tasbeeh/tasbeeh_service.dart';

/// شاشة خطأ موحّدة تعرض نص الاستثناء + مكان حدوثه بالضبط (stack trace) —
/// عشان أي خطأ مستقبلي يتحدد مكانه من أول صورة، بدل تخمين على عدة مراحل.
Widget _errorScreen(String title, String exception, StackTrace? stack) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: const Color(0xFF04060D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold),
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 10),
                Text(
                  exception,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  textDirection: TextDirection.ltr,
                ),
                if (stack != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    '— مكان الخطأ بالتفصيل —',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                    textDirection: TextDirection.ltr,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stack.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> main() async {
  // يجعل أي خطأ أثناء بناء أي شاشة (widget) يظهر بالتفصيل (مع مكانه بالضبط)
  // على الشاشة نفسها حتى في وضع Release، بدل شاشة بيضاء فاضية أو رسالة ناقصة.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return _errorScreen('حدث خطأ أثناء بناء الشاشة:', details.exceptionAsString(), details.stack);
  };

  // يلتقط أي خطأ يصير داخل إطار عمل Flutter نفسه (مو بس أثناء بناء شاشة).
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
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
    await SettingsService.init();
    await QuranApiService.init();
    await RecitationsApiService.init();
    await TafsirApiService.init();
    await OpeningDuaAudioService.init();

    runApp(const ProviderScope(child: ZadAlakhiraApp()));
  }, (error, stack) {
    // لو صار خطأ قبل حتى ما يفتح أي شاشة (مثلاً أثناء تهيئة Hive)، نعرضه بالتفصيل.
    runApp(_errorScreen('حدث خطأ عند بدء التشغيل:', error.toString(), stack));
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
