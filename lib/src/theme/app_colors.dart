import 'dart:ui' show Color;

/// Semantic color contract. **Your app** implements it (one class for light,
/// one for dark) and passes the instances to `CoreConfig(lightColors: ...,
/// darkColors: ...)`. Core ships no palette of its own — every color comes
/// from your project.
///
/// This uses only `dart:ui`'s [Color] (no Flutter material). The Flutter
/// layer turns these into a `ThemeData` (see `example/lib/theme/app_theme.dart`).
///
/// ```dart
/// class LightColors implements AppColors {
///   @override Color get primary => const Color(0xFF1E3A5F);
///   @override Color get onPrimary => const Color(0xFFFAFAF7);
///   // ...implement the rest
/// }
/// ```
abstract class AppColors {
  Color get primary;
  Color get onPrimary;
  Color get secondary;
  Color get scaffoldBackground;
  Color get surface;
  Color get surfaceVariant; // for layered cards / subtle wells
  Color get textPrimary;
  Color get textSecondary;
  Color get textHint;
  Color get inputFill;
  Color get border;
  Color get success;
  Color get info;
  Color get warning;
  Color get error;
}
