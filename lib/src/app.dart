import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/src/views/screens/bottom_nav_bar.dart';

import 'core/constants/string_const.dart';
import 'core/themes/theme_data.dart';
import 'core/utils/app_state_notifier.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(builder: (context, appState, child) {
      return MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeConfig.themeSeed,
        // darkTheme: ThemeConfig.darkTheme,
        // themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const MainPage(),
      );
    });
  }
}
