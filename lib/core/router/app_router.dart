import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/coming_soon_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/prayer_times/prayer_times_screen.dart';
import '../../features/qibla/qibla_screen.dart';
import '../../features/azkar/azkar_screen.dart';
import '../../features/tasbeeh/tasbeeh_screen.dart';
import '../../features/dua_walidi/dua_walidi_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/quran/quran_screen.dart';
import '../../features/quran/surah_detail_screen.dart';
import '../../features/quran/models/surah_model.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/prayer-times', builder: (context, state) => const PrayerTimesScreen()),
    GoRoute(path: '/qibla', builder: (context, state) => const QiblaScreen()),
    GoRoute(path: '/azkar', builder: (context, state) => const AzkarScreen()),
    GoRoute(path: '/tasbeeh', builder: (context, state) => const TasbeehScreen()),
    GoRoute(path: '/dua-walidi', builder: (context, state) => const DuaWalidiScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),

    // القرآن الكريم — نص عثماني حقيقي عبر Al Quran Cloud API، مع تخزين محلي للقراءة بدون إنترنت.
    GoRoute(path: '/quran', builder: (context, state) => const QuranScreen()),
    GoRoute(
      path: '/quran/:number',
      builder: (context, state) {
        final number = int.parse(state.pathParameters['number']!);
        final info = state.extra as SurahInfo?;
        return SurahDetailScreen(surahNumber: number, surahInfo: info);
      },
    ),

    // وحدات تحتاج مصدر بيانات خارجي (صوتيات/تفسير/محتوى تعليمي) — بنية جاهزة، بيانات تُوصل لاحقًا.
    GoRoute(
    GoRoute(
      path: '/recitations',
      builder: (context, state) => const ComingSoonScreen(
        title: 'التلاوات',
        icon: Icons.headphones_rounded,
        note: 'مشغّل صوتي جاهز (تشغيل/تحميل/سرعة/مؤقت نوم) — يحتاج روابط ملفات التلاوات.',
      ),
    ),
    GoRoute(
      path: '/tafsir',
      builder: (context, state) => const ComingSoonScreen(
        title: 'التفسير',
        icon: Icons.auto_stories_rounded,
        note: 'عرض التفسير الميسر وابن كثير والسعدي تحت كل آية — يحتاج ربط قاعدة بيانات التفسير.',
      ),
    ),
    GoRoute(
      path: '/tajweed',
      builder: (context, state) => const ComingSoonScreen(
        title: 'أحكام التجويد',
        icon: Icons.record_voice_over_rounded,
        note: 'دروس تفاعلية بأمثلة صوتية ومرئية — تحتاج محتوى تعليمي وملفات صوتية.',
      ),
    ),
    GoRoute(
      path: '/learn-salah',
      builder: (context, state) => const ComingSoonScreen(
        title: 'تعلم الصلاة',
        icon: Icons.accessibility_new_rounded,
        note: 'دليل خطوة بخطوة بالصور والصوت والفيديو — يحتاج أصول وسائط.',
      ),
    ),
  ],
);
