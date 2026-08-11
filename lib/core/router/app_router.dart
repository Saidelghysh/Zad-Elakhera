import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../../features/recitations/recitations_screen.dart';
import '../../features/recitations/reciter_surahs_screen.dart';
import '../../features/recitations/models/reciter_model.dart';
import '../../features/tafsir/tafsir_screen.dart';
import '../../features/tafsir/tafsir_detail_screen.dart';
import '../../features/tajweed/tajweed_screen.dart';
import '../../features/learn_salah/learn_salah_screen.dart';

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

    // التلاوات — تشغيل صوتي حقيقي (mp3quran.net) لأربعة قراء مشهورين.
    GoRoute(path: '/recitations', builder: (context, state) => const RecitationsScreen()),
    GoRoute(
      path: '/recitations/:id',
      builder: (context, state) {
        final reciter = state.extra as Reciter;
        return ReciterSurahsScreen(reciter: reciter);
      },
    ),

    // التفسير — الميسر/ابن كثير/السعدي، عبر نفس مصدر نص القرآن.
    GoRoute(path: '/tafsir', builder: (context, state) => const TafsirScreen()),
    GoRoute(
      path: '/tafsir/:number',
      builder: (context, state) {
        final number = int.parse(state.pathParameters['number']!);
        final info = state.extra as SurahInfo?;
        return TafsirDetailScreen(surahNumber: number, surahInfo: info);
      },
    ),

    // أحكام التجويد وتعلم الصلاة — محتوى تعليمي نصي حقيقي.
    GoRoute(path: '/tajweed', builder: (context, state) => const TajweedScreen()),
    GoRoute(path: '/learn-salah', builder: (context, state) => const LearnSalahScreen()),
  ],
);
