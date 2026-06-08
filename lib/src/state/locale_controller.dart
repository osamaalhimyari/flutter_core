import 'dart:async';
import 'dart:ui' show Locale;

import '../config/core_config.dart';
import '../services/locale_service.dart';
import '../storage/key_value_storage.dart';

/// Framework-agnostic language controller implementing [LocaleService].
///
/// No Flutter material, no bloc — it just holds the current language and
/// broadcasts changes on [changes]. Adapt it to your state management:
///   * **Bloc:** a Cubit that `emit`s from `changes`.
///   * **GetX:** `Get.put(controller)` and `StreamBuilder`/`.obs` bridge.
///   * **Provider:** a `StreamProvider`/`ChangeNotifier` wrapper.
///
/// Supported languages + display names come from `CoreConfig.locales`.
/// Selection is persisted via the injected [KeyValueStorage] (if any).
class LocaleController implements LocaleService {
  /// Key used to persist the selected language code.
  static const String storageKey = 'core.locale';

  final CoreConfig _config;
  final KeyValueStorage? _storage;
  final StreamController<Locale> _changes = StreamController<Locale>.broadcast();

  late String _current;

  LocaleController({
    required CoreConfig config,
    KeyValueStorage? storage,
    String? initialLanguageCode,
  }) : _config = config,
       _storage = storage {
    final supported = getAvailableLanguages();
    if (initialLanguageCode != null && supported.contains(initialLanguageCode)) {
      _current = initialLanguageCode;
    } else {
      _current = supported.isNotEmpty ? supported.first : 'en';
    }
  }

  /// Emits the new [Locale] whenever the language changes.
  Stream<Locale> get changes => _changes.stream;

  // ---- LocaleService — read side --------------------------------------

  @override
  Locale get currentLocale => Locale(_current);

  @override
  String get currentLanguageCode => _current;

  @override
  String get currentLanguageName => getLanguageName(_current);

  @override
  List<Locale> get supportedLocales => _config.supportedLocales;

  @override
  String getLanguageName(String code) => _config.languageName(code);

  @override
  List<String> getAvailableLanguages() =>
      _config.locales.map((l) => l.languageCode).toList(growable: false);

  // ---- LocaleService — write side -------------------------------------

  @override
  void changeLocale(String languageCode) {
    final supported = getAvailableLanguages();
    if (supported.isEmpty) return;
    final next = supported.contains(languageCode)
        ? languageCode
        : supported.first;
    if (next == _current) return;
    _current = next;
    _storage?.writeString(storageKey, next);
    _changes.add(Locale(next));
  }

  @override
  void switchToNextLanguage() {
    final supported = getAvailableLanguages();
    if (supported.isEmpty) return;
    final index = supported.indexOf(_current);
    changeLocale(supported[(index + 1) % supported.length]);
  }

  /// Close the broadcast stream. Call from your app's teardown.
  Future<void> dispose() => _changes.close();
}
