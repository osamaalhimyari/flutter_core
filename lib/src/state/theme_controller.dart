import 'dart:async';

import 'package:flutter/material.dart';

import '../config/core_config.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import '../storage/key_value_storage.dart';

/// Framework-agnostic theme controller implementing [ThemeService].
///
/// No bloc — it holds the dark/light flag, builds [ThemeData] from
/// `CoreConfig` colors (font picked per current language via [LocaleService]),
/// and broadcasts changes on [changes]. Adapt to Bloc / GetX / Provider by
/// listening to [changes]. The flag is persisted via the injected
/// [KeyValueStorage] (shared_preferences in production).
class ThemeController implements ThemeService {
  /// Key used to persist the dark-mode flag.
  static const String storageKey = 'core.theme.dark';

  final CoreConfig _config;
  final LocaleService _localeService;
  final KeyValueStorage? _storage;
  final StreamController<ThemeMode> _changes =
      StreamController<ThemeMode>.broadcast();

  bool _dark;

  ThemeController({
    required CoreConfig config,
    required LocaleService localeService,
    KeyValueStorage? storage,
    bool initialDark = false,
  }) : _config = config,
       _localeService = localeService,
       _storage = storage,
       _dark = initialDark;

  /// Emits the new [ThemeMode] whenever the theme changes.
  Stream<ThemeMode> get changes => _changes.stream;

  @override
  bool get isDarkMode => _dark;

  @override
  ThemeMode get themeMode => _dark ? ThemeMode.dark : ThemeMode.light;

  @override
  ThemeData get lightTheme => AppTheme.build(_config.lightColors, _font, false);

  @override
  ThemeData get darkTheme => AppTheme.build(_config.darkColors, _font, true);

  @override
  void switchTheme() => setDarkMode(!_dark);

  @override
  void setDarkMode(bool value) {
    if (value == _dark) return;
    _dark = value;
    _storage?.writeBool(storageKey, value);
    _changes.add(themeMode);
  }

  String? get _font =>
      _config.fontFamilyFor(_localeService.currentLanguageCode);

  /// Close the broadcast stream. Call from your app's teardown.
  Future<void> dispose() => _changes.close();
}
