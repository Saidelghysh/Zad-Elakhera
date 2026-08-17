# زاد الآخرة — Zad Al-Akhira

> صدقة جارية على روح الحاج عبدالحميد إبراهيم الغايش رحمه الله.

تطبيق إسلامي فاخر مبني بـ Flutter، بتصميم "Modern Islamic Luxury" (أسود ملكي + كحلي عميق + ذهبي فاخر
+ Glassmorphism)، مستوحى من Muslim Pro Premium و Quran Majeed Premium وواجهات Apple.

---

## ✅ ما تم بناؤه فعليًا في هذه النسخة (كود Flutter كامل وشغّال)

| الوحدة | الحالة |
|---|---|
| نظام الثيم (ألوان/خطوط/Glassmorphism) | ✅ كامل |
| Splash Screen (fade-in + جزيئات ذهبية) | ✅ كامل |
| Home Screen (بطاقة الترحيب + عداد الصلاة + شبكة القوائم + بانر الدعاء + تذكير عشوائي) | ✅ كامل |
| دعاء لوالدي (النص + زر "دعوت الآن" + عداد محفوظ محليًا عبر Hive) | ✅ كامل |
| السبحة الرقمية (عداد ذهبي + اهتزاز + أهداف مخصصة + حفظ محلي) | ✅ كامل |
| الأذكار (تبويبات فئات + عداد تكرار لكل ذكر + مشاركة/مفضلة UI) | ✅ كامل (بيانات أذكار الصباح نموذجية، الباقي بنفس البنية) |
| أوقات الصلاة (موقع حقيقي عبر Geolocator + حساب فعلي عبر adhan_dart + عداد تنازلي حي) | ✅ مربوطة بالكامل ببيانات حقيقية |
| القبلة (بوصلة حقيقية عبر حساس المغناطيسية — flutter_qiblah) | ✅ مربوطة بالكامل بالحساس الفعلي |
| التوجيه (go_router) + الحالة (Riverpod) + التخزين المحلي (Hive) | ✅ مُهيّأ ومربوط بالكامل |

## 🔜 وحدات تحتاج مصادر بيانات خارجية (البنية جاهزة، placeholder شغّال حاليًا)

هذه الوحدات تحتاج محتوى كبير (نص القرآن، ملفات صوتية، كتب تفسير) لا يمكن توليدها بدون مصدر حقيقي:

- **القرآن الكريم**: يحتاج نص المصحف (مثلًا من [Quran.com API](https://quran.api-docs.io) أو ملف JSON محلي مرخّص).
- **التلاوات**: يحتاج روابط تلاوات صوتية فعلية (العفاسي، السديس، الشيخ الماجد، الغامدي) — عبر
  [everyayah.com](https://everyayah.com) أو استضافة خاصة بكم على Firebase Storage.
- **التفسير**: يحتاج نصوص التفسير الميسر/السعدي/ابن كثير (متوفرة عبر مكتبات نصوص إسلامية مفتوحة).
- **أحكام التجويد وتعلم الصلاة**: يحتاجان محتوى تعليمي (صور/فيديو/صوت) من إعدادكم.

كل هذه الشاشات موجودة الآن كـ `ComingSoonScreen` بنفس الهوية البصرية، وجاهزة لاستبدال المحتوى الوهمي
بالبيانات الحقيقية بمجرد توفّرها.

---

## 🏗️ بنية المشروع (Feature-based Clean Architecture)

```
lib/
  core/
    theme/          # الألوان، الخطوط، ThemeData
    router/         # go_router
    widgets/         # عناصر مشتركة (GlassCard, GoldDivider, ArchCrescentLogo, ComingSoonScreen)
  features/
    splash/
    home/
      widgets/       # PrayerHeroCard, HomeMenuGrid, DuaBanner
    prayer_times/
      models/
    qibla/
    azkar/
      data/
    tasbeeh/
    dua_walidi/
  main.dart
```

---

## ⚙️ التقنيات المستخدمة (كما في المواصفات)

- **Flutter** (أحدث إصدار مستقر)
- **Riverpod** لإدارة الحالة
- **go_router** للتنقل
- **Hive** للتخزين المحلي (عدادات، مفضلة، آخر قراءة)
- **google_fonts** (Cairo للواجهة، Amiri للنصوص القرآنية/الشرعية)
- **adhan** لحساب أوقات الصلاة (يحتاج ربط الموقع الجغرافي)
- **flutter_qiblah** + **geolocator** لاتجاه القبلة
- **just_audio** + **audio_service** للتلاوات (تشغيل خلفي، قوائم تشغيل)
- **flutter_local_notifications** لإشعارات الأذان والتذكيرات اليومية
- **animate_do** + **lottie** للحركات الفاخرة
- **vibration** لردود الفعل اللمسية في السبحة

## 🔥 Firebase (لوحة التحكم الإدارية) — الخطوة التالية

المواصفات تطلب لوحة تحكم Firebase Admin لإدارة الأذكار/المقالات/التذكيرات/الملفات الصوتية/الإشعارات/
المستخدمين/الإحصائيات. هذا يحتاج:

1. إنشاء مشروع Firebase وتفعيل: Authentication, Firestore, Storage, Cloud Messaging.
2. إضافة `firebase_core`, `cloud_firestore`, `firebase_storage`, `firebase_messaging` إلى `pubspec.yaml`.
3. بناء لوحة تحكم منفصلة (يُفضّل Flutter Web أو React) تتصل بنفس مشروع Firebase.
4. استبدال `DuaCounterService` الحالي (Hive محلي) بمزامنة Firestore، بحيث يكون عداد الدعوات
   **إجماليًا لكل المستخدمين** فعليًا وليس محليًا فقط.

---

## 📍 ربط أوقات الصلاة والقبلة بالبيانات الحقيقية (تم تنفيذه)

- **أوقات الصلاة**: `lib/features/prayer_times/services/location_service.dart` يطلب إذن الموقع
  عبر `geolocator`، ثم `prayer_times_service.dart` يحسب الأوقات الفعلية عبر `adhan_dart`
  (طريقة رابطة العالم الإسلامي، مذهب شافعي افتراضيًا — قابل للتغيير من `CalculationMethod`
  و `Madhab` في نفس الملف). يُدار كل هذا عبر `providers/prayer_times_provider.dart` (Riverpod)
  ويُستهلك في كل من `home_screen.dart` و `prayer_times_screen.dart`.
- **حالة رفض الإذن**: بدل انهيار الشاشة، يعرض التطبيق أوقات مكة المكرمة مع تنبيه واضح
  أنها ليست موقع المستخدم الفعلي، وزر "إعادة المحاولة" + زر "فتح إعدادات التطبيق".
- **القبلة**: `qibla_screen.dart` يستخدم `FlutterQiblah.qiblahStream` مباشرة من حساس
  المغناطيسية بالجهاز، مع فحص مسبق لدعم الحساس (`androidDeviceSensorSupport`) وحالة GPS
  والإذن (`checkLocationStatus` / `requestPermissions`)، وتتغيّر إبرة البوصلة للون الأخضر
  تلقائيًا عند محاذاة الجهاز فعليًا مع اتجاه القبلة.

## 🚀 التشغيل

```bash
flutter pub get
flutter create .   # لتوليد مجلدي android/ و ios/ (غير مُولّدين في هذه الحزمة النصية)
flutter run
```

### الأذونات المطلوبة (بعد تشغيل `flutter create .`)

**Android** — أضف داخل `android/app/src/main/AndroidManifest.xml` (خارج تاغ `<application>`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

**iOS** — أضف داخل `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>نحتاج موقعك لحساب أوقات الصلاة واتجاه القبلة بدقة من مكانك.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>نحتاج موقعك لحساب أوقات الصلاة واتجاه القبلة بدقة من مكانك.</string>
```

> ملاحظة: حزمة `flutter_qiblah` لا تعمل على محاكي iOS (iOS Simulator) — البوصلة تحتاج
> حساس مغناطيسي حقيقي، لذا يجب اختبارها على جهاز iOS فعلي.

---

## 📄 الترخيص والصور

- الشعار في السبلاش والشاشات مرسوم بالكامل بالكود (CustomPainter) — بدون أي صور خارجية أو محتوى محمي.
- عند إضافة صور فوتوغرافية (مساجد، أشخاص، خلفيات) في الشاشات القادمة، تأكدوا من استخدام صور
  مرخّصة لكم أو من بنوك صور حرة الاستخدام تجاريًا.

---

جزاكم الله خيرًا، ونسأل الله أن يتقبل هذا العمل صدقة جارية عن الحاج عبدالحميد إبراهيم الغايش رحمه الله. 🤍

## نسخة النشر 1.1.0

تم تجهيز المشروع في هذه النسخة ليكون مسار الرفع والنشر أوضح:

- واجهة رئيسية أقرب للهوية المرجعية: كحلي/أسود + ذهبي، تحية، بطاقة الصلاة، بث مباشر، شبكة الخدمات، وبطاقة الصدقة الجارية.
- مكتبة صوتية منظمة إلى: البث المباشر، التلاوات، الحفلات الخارجية، الابتهالات والتواشيح، والأمسيات الدينية.
- الحفلات الخارجية لا تفتح المتصفح للاستماع: التطبيق يقرأ ملفات MP3 الفعلية من Internet Archive ويشغلها داخل التطبيق، مع بحث ومشغل مصغر وزر للمصدر الأصلي.
- البث المباشر يحاول جلب محطة القاهرة من API، ثم يستخدم مصدرًا احتياطيًا إذا تعذر المصدر الأول.
- أيقونة تطبيق جديدة بنفس الهوية الداكنة والذهبية.
- GitHub Actions يولّد مشروع Android، يشغل `flutter analyze` و`flutter test`، ثم يبني APK وAAB.

### Google Play signing

البناء التلقائي ينتج AAB للاختبار. للنشر الفعلي على Google Play يجب إضافة مفتاح الرفع الدائم إلى GitHub Secrets قبل تشغيل Workflow:

- `ZAD_KEYSTORE_BASE64`
- `ZAD_KEYSTORE_PASSWORD`
- `ZAD_KEY_ALIAS`
- `ZAD_KEY_PASSWORD`

لا تضع ملف keystore أو كلمات المرور داخل المستودع العام.
