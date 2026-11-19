# ڕۆژان (Rojan) – پلانەری شەوانە

بەرنامەی Flutter بۆ ئەندرۆید، بە کوردی (سۆرانی) / English / العربية.

## تایبەتمەندییەکان
- بیرخستنەوەی شەوانە بۆ دانانی پلانی سبەی (کاتەکەی دەگۆڕدرێت)
- بیرخستنەوەی بەیانیان بۆ ئەرکەکانی ئەمڕۆ + ئاگادارکردنەوە لە کاتی هەر ئەرکێک
- هەڵسەنگاندنی مانگانە (ڕێژە، باشترین ڕۆژ، بەردەوامی) + ڕاپۆرتی خۆکار لە یەکەم کردنەوەی مانگی نوێ
- وتەی هاندەری ڕۆژانە و پێشنیار بۆ کاتی بەتاڵ
- فێرکاری سەرەتا (Onboarding) و دووبارە پیشاندانی لە ڕێکخستنەکان
- هەموو داتاکان لەسەر مۆبایلەکەی خۆت دەمێنێتەوە، ئینتەرنێت پێویست نییە
- دارک مۆد خۆکار، RTL بۆ کوردی و عەرەبی

## دەستکاریکردنی وتە و پێشنیارەکان
`lib/data.dart` – هەر دێڕێک زیاد بکەیت خۆی لە بەرنامەکەدا دەردەکەوێت.
وەرگێڕانەکان: `lib/l10n.dart`.

## ڕێگای ١: بەبێ کۆمپیوتەر (GitHub Actions)
1. لە github.com ئەکاونتێک بکەرەوە و repository ی نوێ دروست بکە.
2. هەموو فایلەکانی ئەم پڕۆژەیە (لەگەڵ فۆڵدەری `.github`) بیانخە ناو repository.
3. بچۆ بۆ تابی **Actions** ← **Build Android APK** ← **Run workflow**.
4. دوای ٥-١٠ خولەک، لە کۆتایی ئەو run ە بچۆ بۆ **Artifacts** و `rojan-apk` دابەزێنە.
5. ZIP ەکە بکەرەوە و `app-release.apk` لەسەر مۆبایلەکە بکە بە Install
   (ئەندرۆید داوای «Install unknown apps» دەکات، ڕێگەی پێبدە).

## ڕێگای ٢: بە کۆمپیوتەر
```bash
# Flutter SDK دابمەزرێنە: https://docs.flutter.dev/get-started/install
cd rojan
flutter create --platforms=android --org com.rojan --project-name rojan .
python3 tool/patch_android.py
flutter pub get
flutter run                      # مۆبایل بە USB بەستراوە و USB debugging چالاک
flutter build apk --release      # APK: build/app/outputs/flutter-apk/app-release.apk
```

## تێبینی
- لە ئەندرۆید ١٣+ دەبێت ڕێگە بە ئاگادارکردنەوە بدەیت (بەرنامەکە خۆی داوای دەکات).
- ئەگەر ئاگادارکردنەوەکان دواکەون، Battery optimization بۆ ڕۆژان بکوژێنەوە (هەندێک مۆبایل وەک Xiaomi/Huawei).
