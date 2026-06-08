import 'dart:ui' show Locale;

/// Read/write contract for the app language. `LocaleController` implements it
/// (and adds a change `Stream`). Consumers depend on this, not on any
/// state-management type, so it works under Bloc, GetX or Provider.
///
/// Uses only `dart:ui`'s [Locale] (no Flutter material/widgets).
abstract class LocaleService {
  Locale get currentLocale;
  String get currentLanguageCode;
  String get currentLanguageName;
  List<Locale> get supportedLocales;

  void changeLocale(String languageCode);
  void switchToNextLanguage();

  String getLanguageName(String code);
  List<String> getAvailableLanguages();
}
