import 'package:flutter/material.dart';

/// App palette. Cobalt accent, orange "BOT" stamp, green "HUMAN" stamp.
class Pal {
  const Pal({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.accent,
    required this.onAccent,
    required this.bot,
    required this.human,
  });

  final Color bg, surface, ink, muted, line, accent, onAccent, bot, human;

  static const light = Pal(
    bg: Color(0xFFE9ECF4),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF141830),
    muted: Color(0xFF5A6079),
    line: Color(0xFFCDD2E2),
    accent: Color(0xFF2F49F5),
    onAccent: Color(0xFFFFFFFF),
    bot: Color(0xFFE8531C),
    human: Color(0xFF0F8A5F),
  );

  static const dark = Pal(
    bg: Color(0xFF0E1120),
    surface: Color(0xFF191D33),
    ink: Color(0xFFEDEFF8),
    muted: Color(0xFF9AA0BC),
    line: Color(0xFF2C3150),
    accent: Color(0xFF7C8CFF),
    onAccent: Color(0xFF0E1120),
    bot: Color(0xFFFF8650),
    human: Color(0xFF4ED3A0),
  );

  static Pal of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

ThemeData buildTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? Pal.dark : Pal.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: brightness,
  ).copyWith(
    primary: p.accent,
    onPrimary: p.onAccent,
    surface: p.surface,
    onSurface: p.ink,
  );
  final radius = BorderRadius.circular(14);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.line, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.line, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.accent, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: p.ink,
        side: BorderSide(color: p.ink, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
