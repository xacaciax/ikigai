import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ikigai_advisor/src/advisor_chat/chat_view.dart';

import '../theme/app_theme.dart';
import 'intro_carousel/intro_carousel.dart';
import 'settings/settings_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });
  final SettingsController settingsController;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          initialRoute: '/intro',
          routes: {
            '/intro': (context) => CarouselPage(),
            '/chat': (context) => ChatView(),
          },
          restorationScopeId: 'ikigaiAdvisor',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: buildThemeData(),
        );
      },
    );
  }
}
