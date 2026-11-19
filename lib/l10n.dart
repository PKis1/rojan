import 'package:flutter/material.dart';

/// Supported app languages: Kurdish (Sorani), English, Arabic.
const supportedLangs = ['ku', 'en', 'ar'];

const langNames = {'ku': 'کوردی', 'en': 'English', 'ar': 'العربية'};

Locale localeFor(String lang) =>
    lang == 'en' ? const Locale('en') : const Locale('ar');

/// Translate [key] into [lang]. Use `{n}` style placeholders via [args].
String tr(String lang, String key, [Map<String, String> args = const {}]) {
  var s = _strings[lang]?[key] ?? _strings['en']![key] ?? key;
  args.forEach((k, v) => s = s.replaceAll('{$k}', v));
  return s;
}

List<String> monthNames(String lang) => tr(lang, 'months').split(',');

const Map<String, Map<String, String>> _strings = {
  'ku': {
    'appName': 'ڕۆژان',
    'skip': 'تێپەڕاندن',
    'next': 'دواتر',
    'back': 'پێشوو',
    'start': 'دەست پێبکە',
    'onb0t': 'بەخێربێیت بۆ ڕۆژان',
    'onb0b': 'سەرەتا زمان و ناوەکەت هەڵبژێرە.',
    'chooseLang': 'زمان',
    'nameLabel': 'ناوت',
    'onb1t': 'شەوانە پلان دابنێ',
    'onb1b':
        'هەموو شەوێک بیرت دەخەمەوە کە پلانی ڕۆژی دواتر دابنێیت. لە تابی «پلان» ئەرکەکانی سبەی بنووسە و کاتیان دیاری بکە.',
    'onb2t': 'بیرخستنەوەی ڕۆژانە',
    'onb2b':
        'بەیانیان ئەرکەکانی ئەمڕۆت بیردەخەمەوە، و لە کاتی هەر ئەرکێکیش ئاگادارکردنەوە دێت.',
    'onb3t': 'هەڵسەنگاندنی مانگانە',
    'onb3b':
        'هەموو داتاکانت کۆدەکرێنەوە و لە کۆتایی مانگدا ڕاپۆرتێکی ورد دەبینیت: ڕێژەی تەواوکردن، باشترین ڕۆژ و بەردەوامی.',
    'onb4t': 'هاندان و پێشنیار',
    'onb4b':
        'ڕۆژانە وتەیەکی هاندەر دەبینیت، و بۆ کاتە بەتاڵەکانت پێشنیاری سوودبەخش پیشان دەدرێت.',
    'hello': 'سڵاو {n}',
    'helloNoName': 'سڵاو',
    'tabToday': 'ئەمڕۆ',
    'tabPlan': 'پلان',
    'tabStats': 'ئامار',
    'tabSettings': 'ڕێکخستن',
    'todayTasks': 'ئەرکەکانی ئەمڕۆ',
    'noTasksToday':
        'هیچ ئەرکێکت بۆ ئەمڕۆ نییە. لە تابی «پلان» ئەرک زیاد بکە.',
    'progress': 'پێشکەوتنی ئەمڕۆ',
    'planTitle': 'پلانی سبەی',
    'planSub': 'ئێستا ئەرکەکانی ڕۆژی دواتر دابنێ.',
    'taskHint': 'ئەرکێک بنووسە...',
    'setTime': 'کات',
    'add': 'زیادکردن',
    'noTasksTomorrow': 'هێشتا ئەرکێکت بۆ سبەی دانەناوە.',
    'quoteTitle': 'وتەی ئەمڕۆ',
    'freeTitle': 'بۆ کاتی بەتاڵ',
    'newIdea': 'پێشنیارێکی تر',
    'statsTitle': 'هەڵسەنگاندنی مانگانە',
    'tasksTotal': 'کۆی ئەرک',
    'tasksDone': 'تەواوکراو',
    'rate': 'ڕێژەی تەواوکردن',
    'bestDay': 'باشترین ڕۆژ',
    'streak': 'بەردەوامی (ڕۆژ)',
    'last7': 'حەوت ڕۆژی ڕابردوو',
    'noData': 'هیچ داتایەک بۆ ئەم مانگە نییە.',
    'evalGreat': 'نایابە! ئەم مانگە زۆر بەردەوام بویت. بەردەوام بە.',
    'evalGood':
        'باشە! هەنگاوەکانت دروستن. ئەگەر ئەرکەکان کەمێک سووک بکەیت زیاتر تەواو دەبن.',
    'evalLow':
        'مەترسە، دەستپێکردنەوە هەمیشە ئاسانە. مانگی داهاتوو ئەرکی کەمتر و ڕاستەقینەتر دابنێ.',
    'settingsTitle': 'ڕێکخستنەکان',
    'language': 'زمان',
    'changeName': 'ناوت',
    'notifications': 'ئاگادارکردنەوەکان',
    'nightReminder': 'بیرخستنەوەی شەوانە (پلانی سبەی)',
    'morningReminder': 'بیرخستنەوەی بەیانیان',
    'replayTutorial': 'دووبارە پیشاندانی فێرکاری',
    'nightNotifTitle': 'کاتی پلانی سبەیە 🌙',
    'nightNotifBody': 'چەند خولەکێک تەرخان بکە و ئەرکەکانی سبەی دابنێ.',
    'morningNotifTitle': 'بەیانیت باش ☀️',
    'morningNotifBody': 'ئەرکەکانی ئەمڕۆت ئامادەن، با دەست پێبکەین!',
    'taskNotifTitle': 'کاتی ئەرکەکەیە',
    'reviewTitle': 'ڕاپۆرتی مانگی ڕابردوو',
    'close': 'داخستن',
    'permDenied':
        'ڕێگەپێدانی ئاگادارکردنەوە نەدراوە. لە ڕێکخستنەکانی مۆبایل چالاکی بکە.',
    'months':
        'کانوونی دووەم,شوبات,ئازار,نیسان,ئایار,حوزەیران,تەمموز,ئاب,ئەیلوول,تشرینی یەکەم,تشرینی دووەم,کانوونی یەکەم',
  },
  'en': {
    'appName': 'Rojan',
    'skip': 'Skip',
    'next': 'Next',
    'back': 'Back',
    'start': 'Get started',
    'onb0t': 'Welcome to Rojan',
    'onb0b': 'First, choose your language and your name.',
    'chooseLang': 'Language',
    'nameLabel': 'Your name',
    'onb1t': 'Plan every night',
    'onb1b':
        'Every night you get a reminder to plan tomorrow. Open the Plan tab, write tomorrow\'s tasks and optionally set a time for each.',
    'onb2t': 'Daily reminders',
    'onb2b':
        'Each morning you are reminded of today\'s tasks, and tasks with a time notify you when it is due.',
    'onb3t': 'Monthly review',
    'onb3b':
        'Your data is collected and you get a clear report at month end: completion rate, best day and streak.',
    'onb4t': 'Motivation & ideas',
    'onb4b':
        'See a motivational quote every day, plus useful ideas for your free time.',
    'hello': 'Hello {n}',
    'helloNoName': 'Hello',
    'tabToday': 'Today',
    'tabPlan': 'Plan',
    'tabStats': 'Stats',
    'tabSettings': 'Settings',
    'todayTasks': 'Today\'s tasks',
    'noTasksToday': 'No tasks for today. Add some in the Plan tab.',
    'progress': 'Today\'s progress',
    'planTitle': 'Plan for tomorrow',
    'planSub': 'Set up the tasks for the next day now.',
    'taskHint': 'Write a task...',
    'setTime': 'Time',
    'add': 'Add',
    'noTasksTomorrow': 'You have not planned anything for tomorrow yet.',
    'quoteTitle': 'Quote of the day',
    'freeTitle': 'For your free time',
    'newIdea': 'Another idea',
    'statsTitle': 'Monthly review',
    'tasksTotal': 'Total tasks',
    'tasksDone': 'Completed',
    'rate': 'Completion rate',
    'bestDay': 'Best day',
    'streak': 'Streak (days)',
    'last7': 'Last 7 days',
    'noData': 'No data for this month.',
    'evalGreat': 'Excellent! You were very consistent this month. Keep going.',
    'evalGood':
        'Good! You are on the right track. Slightly lighter days will help you finish more.',
    'evalLow':
        'No worries, starting again is always easy. Plan fewer, more realistic tasks next month.',
    'settingsTitle': 'Settings',
    'language': 'Language',
    'changeName': 'Your name',
    'notifications': 'Notifications',
    'nightReminder': 'Night reminder (plan tomorrow)',
    'morningReminder': 'Morning reminder',
    'replayTutorial': 'Show tutorial again',
    'nightNotifTitle': 'Time to plan tomorrow 🌙',
    'nightNotifBody': 'Take a few minutes and set up tomorrow\'s tasks.',
    'morningNotifTitle': 'Good morning ☀️',
    'morningNotifBody': 'Today\'s tasks are ready. Let\'s begin!',
    'taskNotifTitle': 'Task time',
    'reviewTitle': 'Last month\'s report',
    'close': 'Close',
    'permDenied':
        'Notification permission was denied. Enable it in your phone settings.',
    'months':
        'January,February,March,April,May,June,July,August,September,October,November,December',
  },
  'ar': {
    'appName': 'روژان',
    'skip': 'تخطي',
    'next': 'التالي',
    'back': 'السابق',
    'start': 'ابدأ',
    'onb0t': 'مرحباً بك في روژان',
    'onb0b': 'اختر لغتك واسمك أولاً.',
    'chooseLang': 'اللغة',
    'nameLabel': 'اسمك',
    'onb1t': 'خطّط كل ليلة',
    'onb1b':
        'كل ليلة ستصلك رسالة تذكير لتخطيط اليوم التالي. افتح تبويب «خطة» واكتب مهام الغد وحدد وقتاً لكل مهمة إن أردت.',
    'onb2t': 'تذكيرات يومية',
    'onb2b':
        'في الصباح نذكّرك بمهام اليوم، وتصلك إشعارات في موعد المهام التي حددت لها وقتاً.',
    'onb3t': 'التقييم الشهري',
    'onb3b':
        'تُجمع بياناتك ويصلك في نهاية الشهر تقرير واضح: نسبة الإنجاز وأفضل يوم والاستمرارية.',
    'onb4t': 'تحفيز واقتراحات',
    'onb4b': 'ستجد كل يوم عبارة تحفيزية، واقتراحات مفيدة لأوقات فراغك.',
    'hello': 'مرحباً {n}',
    'helloNoName': 'مرحباً',
    'tabToday': 'اليوم',
    'tabPlan': 'خطة',
    'tabStats': 'إحصاءات',
    'tabSettings': 'الإعدادات',
    'todayTasks': 'مهام اليوم',
    'noTasksToday': 'لا توجد مهام لليوم. أضف مهاماً من تبويب «خطة».',
    'progress': 'تقدّم اليوم',
    'planTitle': 'خطة الغد',
    'planSub': 'حدّد مهام اليوم التالي الآن.',
    'taskHint': 'اكتب مهمة...',
    'setTime': 'الوقت',
    'add': 'إضافة',
    'noTasksTomorrow': 'لم تخطّط لأي شيء للغد بعد.',
    'quoteTitle': 'عبارة اليوم',
    'freeTitle': 'لوقت فراغك',
    'newIdea': 'اقتراح آخر',
    'statsTitle': 'التقييم الشهري',
    'tasksTotal': 'إجمالي المهام',
    'tasksDone': 'المنجزة',
    'rate': 'نسبة الإنجاز',
    'bestDay': 'أفضل يوم',
    'streak': 'الاستمرارية (أيام)',
    'last7': 'آخر 7 أيام',
    'noData': 'لا توجد بيانات لهذا الشهر.',
    'evalGreat': 'ممتاز! كنت منتظماً جداً هذا الشهر. واصل.',
    'evalGood':
        'جيد! أنت على الطريق الصحيح. تخفيف المهام قليلاً سيساعدك على إنجاز المزيد.',
    'evalLow':
        'لا تقلق، البدء من جديد سهل دائماً. ضع مهاماً أقل وأكثر واقعية الشهر القادم.',
    'settingsTitle': 'الإعدادات',
    'language': 'اللغة',
    'changeName': 'اسمك',
    'notifications': 'الإشعارات',
    'nightReminder': 'تذكير الليل (خطة الغد)',
    'morningReminder': 'تذكير الصباح',
    'replayTutorial': 'عرض الشرح مرة أخرى',
    'nightNotifTitle': 'حان وقت تخطيط الغد 🌙',
    'nightNotifBody': 'خصّص بضع دقائق لتحديد مهام الغد.',
    'morningNotifTitle': 'صباح الخير ☀️',
    'morningNotifBody': 'مهام اليوم جاهزة، هيا نبدأ!',
    'taskNotifTitle': 'حان موعد المهمة',
    'reviewTitle': 'تقرير الشهر الماضي',
    'close': 'إغلاق',
    'permDenied': 'تم رفض إذن الإشعارات. فعّله من إعدادات الهاتف.',
    'months':
        'كانون الثاني,شباط,آذار,نيسان,أيار,حزيران,تموز,آب,أيلول,تشرين الأول,تشرين الثاني,كانون الأول',
  },
};
