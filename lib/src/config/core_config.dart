import 'dart:ui' show Locale;

import '../theme/app_colors.dart';
import 'core_fonts.dart';
import 'core_locale.dart';

/// Everything that varies between apps (or between environments) lives here.
/// Build one and hand it to `Core.init(config: ...)`. Read it anywhere via
/// `Core.config`.
///
/// Core ships no static content — colors, fonts, languages and translations
/// are all supplied here by your project. This replaces the apps' scattered
/// `AppConfig`, `AppConstants`, the static `AppTranslation.keys`, the
/// hard-coded palette in `AppTheme`, and the font-per-language `switch` in
/// `ThemeCubit`.
class CoreConfig {
  // ---- Identity --------------------------------------------------------

  /// Shown as `MaterialApp.title` and available via `Core.config.appName`.
  final String appName;

  /// Per-app namespace (`driver` / `rider`) — handy for socket rooms,
  /// analytics, storage prefixes, etc.
  final String prefix;

  // ---- Network / endpoints --------------------------------------------

  /// Base URL for the REST API (Dio `baseUrl`).
  final String baseApiUrl;

  /// Base URL for the realtime socket. Defaults to [baseApiUrl].
  final String? _socketBaseUrl;
  String get socketBaseUrl => _socketBaseUrl ?? baseApiUrl;

  final Duration connectTimeout;
  final Duration receiveTimeout;

  /// Optional named endpoint paths, e.g. `{'login': '/api/auth/login'}`.
  /// Look up with [endpoint]. Features can still hard-code paths; this is for
  /// the ones you want centralized.
  final Map<String, String> endpoints;

  /// Google Maps/Places key used by the built-in `RouteService` /
  /// `SearchService` (when [CoreService.route] / [CoreService.search] are
  /// enabled). Leave null if you don't use them.
  final String? googleMapsApiKey;

  // ---- Theme / colors / fonts -----------------------------------------

  /// Your light/dark palettes — implement [AppColors] in your app.
  final AppColors lightColors;
  final AppColors darkColors;

  /// Optional global font mapping. Prefer `CoreLocale.fontFamily` per language.
  final CoreFonts fonts;

  // ---- Localization ----------------------------------------------------

  /// Supported languages + their translations. Everything here comes from
  /// your project (see [CoreLocale]).
  final List<CoreLocale> locales;

  // ---- Misc ------------------------------------------------------------

  /// WebRTC ICE servers (STUN/TURN), if the app uses calling. Default `[]`.
  final List<Map<String, dynamic>> iceServers;

  /// Free-form flags & secrets that don't deserve a typed field yet —
  /// e.g. `{'useFakeTrips': false, 'googleMapsApiKey': '...'}`.
  /// Read with [flag].
  final Map<String, Object?> extras;

  const CoreConfig({
    required this.appName,
    required this.prefix,
    required this.baseApiUrl,
    required this.locales,
    required this.lightColors,
    required this.darkColors,
    String? socketBaseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.endpoints = const {},
    this.googleMapsApiKey,
    this.fonts = const CoreFonts(),
    this.iceServers = const [],
    this.extras = const {},
  }) : _socketBaseUrl = socketBaseUrl;

  // ---- Derived ---------------------------------------------------------

  /// The translation table (`{languageCode}_{COUNTRY}` → key → value) built
  /// straight from [locales]. Fed to `AppTranslation.init`.
  Map<String, Map<String, String>> get translationKeys {
    final result = <String, Map<String, String>>{};
    for (final l in locales) {
      result[l.key] = Map<String, String>.from(l.translations);
    }
    return result;
  }

  /// Locales for `MaterialApp.supportedLocales`.
  List<Locale> get supportedLocales =>
      locales.map((l) => l.locale).toList(growable: false);

  /// The [CoreLocale] for [languageCode], or `null` if unsupported.
  CoreLocale? localeFor(String languageCode) {
    for (final l in locales) {
      if (l.languageCode == languageCode) return l;
    }
    return null;
  }

  /// Display name for [code] (e.g. `English`), falling back to the code.
  String languageName(String code) => localeFor(code)?.displayName ?? code;

  /// Font family for [languageCode]: the locale's own override, else the
  /// [fonts] mapping. `null` means "use the system font".
  String? fontFamilyFor(String languageCode) =>
      localeFor(languageCode)?.fontFamily ?? fonts.familyFor(languageCode);

  /// A named endpoint path. Throws if [name] isn't in [endpoints].
  String endpoint(String name) {
    final path = endpoints[name];
    if (path == null) {
      throw ArgumentError('No endpoint named "$name" in CoreConfig.endpoints');
    }
    return path;
  }

  /// A typed flag/secret from [extras], or `null` if absent / wrong type.
  T? flag<T>(String key) => extras[key] is T ? extras[key] as T : null;
}
