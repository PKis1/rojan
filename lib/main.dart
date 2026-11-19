import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_state.dart';
import 'l10n.dart';
import 'notifications.dart';
import 'ui/onboarding.dart';
import 'ui/shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifier.instance.init();
  final state = AppState();
  await state.load();
  runApp(RojanApp(state: state));
}

class RojanApp extends StatelessWidget {
  final AppState state;
  const RojanApp({super.key, required this.state});

  ThemeData _theme(Brightness b) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorSchemeSeed: const Color(0xFF4F46E5),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.notoSansArabicTextTheme(base.textTheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: tr(state.lang, 'appName'),
        locale: localeFor(state.lang),
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: ThemeMode.light,
        home: state.onboarded
            ? Shell(state: state)
            : OnboardingScreen(state: state),
      ),
    );
  }
}
