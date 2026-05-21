import 'package:flutter/material.dart';

import '../features/home/shell_screen.dart';
import '../features/onboarding/connect_robot_screen.dart';
import 'theme.dart';

class EcoGuardianApp extends StatelessWidget {
  const EcoGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoGuardian X',
      themeMode: ThemeMode.dark,
      darkTheme: EcoGuardianTheme.dark(),
      routes: {
        '/': (_) => const ConnectRobotScreen(),
        '/home': (_) => const ShellScreen(),
      },
    );
  }
}
