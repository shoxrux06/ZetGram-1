import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/speech.dart';
import 'state/study_store.dart';
import 'ui/home_page.dart';
import 'ui/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  runApp(DevLugatApp(store: StudyStore(prefs), speech: Speech()));
}

class DevLugatApp extends StatelessWidget {
  const DevLugatApp({super.key, required this.store, required this.speech});

  final StudyStore store;
  final Speech speech;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        title: 'Dev Lug‘at',
        debugShowCheckedModeBanner: false,
        themeMode: store.themeMode,
        theme: buildTheme(Palette.light, Brightness.light),
        darkTheme: buildTheme(Palette.dark, Brightness.dark),
        builder: (context, child) {
          final dark = Theme.of(context).brightness == Brightness.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
            child: child!,
          );
        },
        home: HomePage(store: store, speech: speech),
      ),
    );
  }
}
