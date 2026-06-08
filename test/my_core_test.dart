import 'package:flutter/material.dart';
import 'package:my_core/my_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// App-supplied palette (core ships none). One seed color per palette so we can
/// prove config colors flow through to the built ThemeData.
class _SolidColors implements AppColors {
  final Color c;
  const _SolidColors(this.c);
  @override
  Color get primary => c;
  @override
  Color get onPrimary => c;
  @override
  Color get secondary => c;
  @override
  Color get scaffoldBackground => c;
  @override
  Color get surface => c;
  @override
  Color get surfaceVariant => c;
  @override
  Color get textPrimary => c;
  @override
  Color get textSecondary => c;
  @override
  Color get textHint => c;
  @override
  Color get inputFill => c;
  @override
  Color get border => c;
  @override
  Color get success => c;
  @override
  Color get info => c;
  @override
  Color get warning => c;
  @override
  Color get error => c;
}

/// App-side locale defined the recommended way: extend CoreLocale.
class _EnUs extends CoreLocale {
  const _EnUs()
    : super(
        languageCode: 'en',
        countryCode: 'US',
        displayName: 'English',
        fontFamily: 'Ubuntu',
        translations: const {
          'app_name': 'Test App EN',
          'confirm': 'Confirm',
          'custom_key': 'Custom EN',
        },
      );
}

class _ArAr extends CoreLocale {
  const _ArAr()
    : super(
        languageCode: 'ar',
        countryCode: 'AR',
        displayName: 'العربية',
        fontFamily: 'Cairo',
        translations: const {'confirm': 'تأكيد', 'custom_key': 'مخصص'},
      );
}

/// A trivial [SoundService] impl, to test that a provided domain service is
/// surfaced on the [CoreContext].
class _FakeSound implements SoundService {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> playTripRequestedCue() async {}
  @override
  Future<void> playTripAcceptedCue() async {}
  @override
  Future<void> playTripFinishedCue() async {}
  @override
  Future<void> playNotificationCue() async {}
  @override
  Future<void> dispose() async {}
}

const _config = CoreConfig(
  appName: 'Test App',
  prefix: 'test',
  baseApiUrl: 'http://example.test',
  lightColors: _SolidColors(Color(0xFF111111)),
  darkColors: _SolidColors(Color(0xFF222222)),
  locales: [_EnUs(), _ArAr()],
);

/// Build core with in-memory storage so tests never touch platform plugins.
Future<CoreContext> _initInMemory({
  Set<CoreService>? services,
  KeyValueStorage? kv,
}) => FlutterCore.init(
  config: _config,
  services: services,
  keyValueStorage: kv ?? InMemoryKeyValueStorage(),
  tokenStorage: InMemoryTokenStorage(),
);

void main() {
  setUp(FlutterCore.reset);

  group('FlutterCore.init — service opt-in (returns a CoreContext, no DI)', () {
    test('builds every config-driven service', () async {
      final core = await _initInMemory(
        services: const {
          CoreService.localization,
          CoreService.theme,
          CoreService.network,
          CoreService.storage,
          CoreService.deviceInfo,
          CoreService.route,
          CoreService.search,
        },
      );
      expect(core.localeController, isNotNull);
      expect(core.themeController, isNotNull);
      expect(core.apiClient, isNotNull);
      expect(core.tokenStorage, isNotNull);
      expect(core.keyValueStorage, isNotNull);
      expect(core.deviceInfoService, isNotNull);
      expect(core.routeService, isNotNull);
      expect(core.searchService, isNotNull);
    });

    test('builds only the requested subset', () async {
      final core = await _initInMemory(services: const {CoreService.network});
      expect(core.apiClient, isNotNull);
      expect(core.tokenStorage, isNotNull); // network needs it
      expect(core.localeController, isNull);
      expect(core.themeController, isNull);
      expect(core.keyValueStorage, isNull);
      expect(core.deviceInfoService, isNull);
      expect(core.routeService, isNull);
    });

    test('a domain service enabled without its impl throws', () async {
      await expectLater(
        FlutterCore.init(
          config: _config,
          services: const {CoreService.sound},
        ),
        throwsArgumentError,
      );
    });

    test('a provided domain impl is surfaced on the context', () async {
      final core = await FlutterCore.init(
        config: _config,
        services: const {CoreService.sound},
        soundService: _FakeSound(),
      );
      expect(core.soundService, isNotNull);
    });

    test('enabling theme auto-enables localization', () async {
      final core = await _initInMemory(services: const {CoreService.theme});
      expect(core.themeController, isNotNull);
      expect(core.localeController, isNotNull);
    });

    test('FlutterCore.config is exposed after init', () async {
      await _initInMemory(services: const {CoreService.network});
      expect(FlutterCore.isInitialized, isTrue);
      expect(FlutterCore.config.appName, 'Test App');
      expect(
        FlutterCore.config.socketBaseUrl,
        'http://example.test',
      ); // defaults
    });
  });

  group('LocaleController (framework-agnostic, stream-based)', () {
    test('changes + persist + emit', () async {
      final kv = InMemoryKeyValueStorage();
      final core = await _initInMemory(
        services: const {CoreService.localization},
        kv: kv,
      );
      final c = core.localeController!;
      expect(c.currentLanguageCode, 'en');
      expect(c.currentLanguageName, 'English');

      final emitted = expectLater(c.changes, emits(const Locale('ar')));
      c.changeLocale('ar');
      await emitted;

      expect(c.currentLanguageCode, 'ar');
      expect(await kv.readString(LocaleController.storageKey), 'ar');
    });

    test('restores the persisted locale on next init', () async {
      final kv = InMemoryKeyValueStorage();
      await kv.writeString(LocaleController.storageKey, 'ar');
      final core = await _initInMemory(
        services: const {CoreService.localization},
        kv: kv,
      );
      expect(core.localeController!.currentLanguageCode, 'ar');
    });
  });

  group('ThemeController (builds ThemeData; persists)', () {
    test('lightTheme/darkTheme use config colors', () async {
      final core = await _initInMemory(services: const {CoreService.theme});
      final t = core.themeController!;
      expect(t.lightTheme.colorScheme.primary, const Color(0xFF111111));
      expect(t.darkTheme.colorScheme.primary, const Color(0xFF222222));
      expect(t.lightTheme.colorsModel.success, const Color(0xFF111111));
    });

    test('toggles, persists, and restores', () async {
      final kv = InMemoryKeyValueStorage();
      var core = await _initInMemory(
        services: const {CoreService.theme},
        kv: kv,
      );
      expect(core.themeController!.isDarkMode, isFalse);

      final emitted = expectLater(
        core.themeController!.changes,
        emits(ThemeMode.dark),
      );
      core.themeController!.switchTheme();
      await emitted;
      expect(await kv.readBool(ThemeController.storageKey), isTrue);

      FlutterCore.reset();
      core = await _initInMemory(services: const {CoreService.theme}, kv: kv);
      expect(core.themeController!.isDarkMode, isTrue);
    });
  });

  group('KeyValueStorage JSON', () {
    test('writeJson / readJson round-trips', () async {
      final kv = InMemoryKeyValueStorage();
      await kv.writeJson('profile', {'id': 7, 'name': 'Ada'});
      final out = await kv.readJson('profile');
      expect(out, {'id': 7, 'name': 'Ada'});
      expect(await kv.readJson('missing'), isNull);
    });
  });

  group('Translations come entirely from config (no static base)', () {
    setUp(() => AppTranslation.init(_config.translationKeys));

    test('app translations resolve per language', () {
      expect(AppTranslation.translate('app_name', 'en'), 'Test App EN');
      expect(AppTranslation.translate('confirm', 'en'), 'Confirm');
      expect(AppTranslation.translate('confirm', 'ar'), 'تأكيد');
      expect(AppTranslation.translate('custom_key', 'ar'), 'مخصص');
    });

    test('unknown key returns the key itself', () {
      expect(
        AppTranslation.translate('does_not_exist', 'en'),
        'does_not_exist',
      );
    });

    test('unknown language falls back to English', () {
      expect(AppTranslation.translate('confirm', 'fr'), 'Confirm');
    });
  });

  group('Validators (pure — return ValidationError, not key strings)', () {
    test('email / password', () {
      expect(Validators.validateEmail(''), ValidationError.emailRequired);
      expect(Validators.validateEmail('nope'), ValidationError.emailInvalid);
      expect(Validators.validateEmail('a@b.co'), isNull);
      expect(
        Validators.validatePassword('short'),
        ValidationError.passwordMinLength,
      );
    });
  });

  group('CoreLocale subclass', () {
    test('exposes key + locale from super()', () {
      const en = _EnUs();
      expect(en.key, 'en_US');
      expect(en.locale.languageCode, 'en');
      expect(en.displayName, 'English');
      expect(en.fontFamily, 'Ubuntu');
    });
  });
}
