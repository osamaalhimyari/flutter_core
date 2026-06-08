import 'package:flutter/material.dart';

/// Contract for theme selection + the built [ThemeData]. `ThemeController`
/// implements it (and adds a change `Stream`). Consumers depend on this, not on
/// any state-management type, so it works under Bloc, GetX or Provider.
abstract class ThemeService {
  bool get isDarkMode;
  ThemeMode get themeMode;

  /// Rebuilt every call so the font can change with the locale.
  ThemeData get lightTheme;
  ThemeData get darkTheme;

  void switchTheme();
  void setDarkMode(bool value);
}
