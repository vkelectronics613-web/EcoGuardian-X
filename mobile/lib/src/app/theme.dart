import 'package:flutter/material.dart';

class EcoGuardianTheme {
  static const neon = Color(0xFF36FFB6);
  static const cyan = Color(0xFF28D8FF);
  static const danger = Color(0xFFFF3B65);
  static const warning = Color(0xFFFFD166);
  static const panel = Color(0xCC111820);
  static const background = Color(0xFF05070A);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: neon,
      brightness: Brightness.dark,
      surface: const Color(0xFF0B1117),
      primary: neon,
      secondary: cyan,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xEE080D12),
        indicatorColor: neon.withOpacity(.16),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}
