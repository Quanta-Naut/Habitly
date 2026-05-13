import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class HabitTrackerApp extends StatefulWidget {
  const HabitTrackerApp({super.key});

  @override
  State<HabitTrackerApp> createState() => _HabitTrackerAppState();
}

class _HabitTrackerAppState extends State<HabitTrackerApp> {
  @override
  void initState() {
    super.initState();
    ThemeController.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Habitly',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: const AppShell(),
        );
      },
    );
  }
}
