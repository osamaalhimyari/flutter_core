/// The runtime translation table, populated by `Core.init` from the merged
/// (core base + app) translations on `CoreConfig`.
///
/// Keys follow the `{languageCode}_{COUNTRY}` shape (e.g. `en_US`, `ar_AR`).
/// `LocaleCubit` derives the supported locales from `CoreConfig.locales`, and
/// `AppLocalizations` / `context.tr` look up through [translate].
class AppTranslation {
  AppTranslation._();

  static Map<String, Map<String, String>> _keys = const {};

  /// The merged translation table. Empty until `Core.init` (or [init]) runs.
  static Map<String, Map<String, String>> get keys => _keys;

  /// Install the merged translation table. Called by `Core.init`; exposed so
  /// tests can seed translations without a full init.
  static void init(Map<String, Map<String, String>> merged) {
    _keys = merged;
  }

  /// Returns the translated string for [key] in [languageCode], falling back
  /// to English, then to the first available language, then to the key
  /// itself (the signal that a translation is missing).
  static String translate(String key, String languageCode) {
    if (_keys.isEmpty) return key;

    final match = _keys.entries.firstWhere(
      (e) => e.key.split('_').first == languageCode,
      orElse: () => _keys.entries.firstWhere(
        (e) => e.key.split('_').first == 'en',
        orElse: () => _keys.entries.first,
      ),
    );
    return match.value[key] ?? key;
  }
}
