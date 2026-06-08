import 'dart:ui' show Locale;

/// One supported language + its translations.
///
/// Replaces the old static pair of `AppTranslation.keys` + the
/// `AppConstants.languageNames` map: each [CoreLocale] carries its own
/// display name, font, and translations, and the supported-locale list is
/// simply `CoreConfig.locales`. Core ships no languages of its own — every
/// value here comes from your project.
///
/// Use it inline, or — the recommended pattern — **extend** it so each
/// language is a self-contained class in your app:
///
/// ```dart
/// class EnUs extends CoreLocale {
///   const EnUs()
///       : super(
///           languageCode: 'en',
///           countryCode: 'US',
///           displayName: 'English',
///           fontFamily: 'Ubuntu',
///           translations: _en,
///         );
/// }
///
/// // CoreConfig(locales: const [EnUs(), ArAr()])
/// ```
class CoreLocale {
  /// ISO language code, e.g. `en`, `ar`.
  final String languageCode;

  /// ISO country code, e.g. `US`, `AR`. Used to build the `en_US` style key.
  final String countryCode;

  /// Human-readable name shown in the language switcher, e.g. `English`,
  /// `العربية`.
  final String displayName;

  /// Optional per-locale font family override. Takes precedence over
  /// `CoreConfig.fonts` when set.
  final String? fontFamily;

  /// App-specific key → translated string for this language. Merged over
  /// the core base translations for the same language code.
  final Map<String, String> translations;

  const CoreLocale({
    required this.languageCode,
    required this.countryCode,
    required this.displayName,
    this.fontFamily,
    this.translations = const {},
  });

  /// `{languageCode}_{COUNTRY}` — the key shape `AppTranslation` uses
  /// (e.g. `en_US`, `ar_AR`).
  String get key => '${languageCode}_${countryCode.toUpperCase()}';

  /// A Flutter [Locale] for `MaterialApp.supportedLocales`.
  Locale get locale => Locale(languageCode);
}
