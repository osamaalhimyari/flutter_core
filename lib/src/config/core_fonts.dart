/// Optional global font mapping, resolved per language code. Core ships **no**
/// font names — you supply them from your project (and declare the font assets
/// in your app's `pubspec.yaml`).
///
/// Prefer setting `CoreLocale.fontFamily` per language; this is a convenience
/// for when you want one default (+ a few per-language overrides) instead.
///
/// ```dart
/// CoreFonts(defaultFamily: 'Ubuntu', perLanguage: {'ar': 'Cairo'})
/// ```
class CoreFonts {
  /// Family used when a language has no specific override. `null` = let the
  /// platform pick the system font.
  final String? defaultFamily;

  /// `languageCode` → font family.
  final Map<String, String> perLanguage;

  const CoreFonts({this.defaultFamily, this.perLanguage = const {}});

  /// The family for [languageCode], falling back to [defaultFamily]
  /// (which may itself be `null`).
  String? familyFor(String languageCode) =>
      perLanguage[languageCode] ?? defaultFamily;
}
