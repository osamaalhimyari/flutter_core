import 'package:shared_preferences/shared_preferences.dart';

import 'config/core_config.dart';
import 'config/core_service.dart';
import 'localization/app_translation.dart';
import 'network/api_client.dart';
import 'network/dio_api_client.dart';
import 'services/device_info_service.dart';
import 'state/locale_controller.dart';
import 'state/theme_controller.dart';
import 'storage/key_value_storage.dart';
import 'storage/token_storage.dart';

/// What `Core.init` builds and hands back. Take the pieces you enabled and
/// register them with **your** state management / DI:
///
/// ```dart
/// final core = await Core.init(config: cfg, services: {...});
/// // Bloc + get_it:  getIt.registerSingleton(core.themeController!);
/// // GetX:           Get.put(core.themeController!);
/// // Provider:       Provider.value(value: core.themeController!);
/// ```
class CoreContext {
  final CoreConfig config;
  final LocaleController? localeController;
  final ThemeController? themeController;
  final ApiClient? apiClient;
  final TokenStorage? tokenStorage;
  final KeyValueStorage? keyValueStorage;
  final DeviceInfoService? deviceInfoService;

  const CoreContext({
    required this.config,
    this.localeController,
    this.themeController,
    this.apiClient,
    this.tokenStorage,
    this.keyValueStorage,
    this.deviceInfoService,
  });
}

/// The entry point for the core package. Material-aware (builds `ThemeData`)
/// but with no state-management lock-in.
///
/// Call [init] once from `main()`; it installs the [CoreConfig], builds the
/// requested [CoreService]s, and returns a [CoreContext] for you to wire into
/// Bloc / GetX / Provider. Read the config anywhere via [config].
class FlutterCore {
  FlutterCore._();

  static CoreConfig? _config;

  /// The active configuration. Throws if [init] hasn't run yet.
  static CoreConfig get config =>
      _config ??
      (throw StateError(
        'FlutterCore.init() has not been called. Call FlutterCore.init(...) in main() '
        'before reading FlutterCore.config.',
      ));

  static bool get isInitialized => _config != null;

  /// Install [config], build [services], and return a [CoreContext].
  ///
  /// - [services] defaults to every [CoreService]. Pass a subset to build only
  ///   what an app needs. Enabling [CoreService.theme] auto-enables
  ///   [CoreService.localization] (the theme picks a font per language).
  /// - [tokenStorage] / [keyValueStorage]: override the defaults
  ///   ([SecureTokenStorage] / [SharedPrefsStorage]). Locale + theme are
  ///   persisted through [keyValueStorage].
  /// - [onUnauthorized] is invoked when an authenticated request gets a 401.
  /// - [enableNetworkLogging] toggles Dio request/response logging.
  static Future<CoreContext> init({
    required CoreConfig config,
    Set<CoreService>? services,
    TokenStorage? tokenStorage,
    KeyValueStorage? keyValueStorage,
    void Function()? onUnauthorized,
    bool enableNetworkLogging = false,
  }) async {
    _config = config;
    AppTranslation.init(config.translationKeys);

    final enabled = {...(services ?? CoreService.values.toSet())};
    if (enabled.contains(CoreService.theme)) {
      enabled.add(CoreService.localization);
    }

    final needsControllers =
        enabled.contains(CoreService.localization) ||
        enabled.contains(CoreService.theme);
    final needsStorage = enabled.contains(CoreService.storage);
    final needsNetwork = enabled.contains(CoreService.network);

    // ---- Storage (defaults: shared_preferences + secure storage) ----
    KeyValueStorage? kv;
    if (needsStorage || needsControllers) {
      kv =
          keyValueStorage ??
          SharedPrefsStorage(await SharedPreferences.getInstance());
    }
    TokenStorage? ts;
    if (needsStorage || needsNetwork) {
      ts = tokenStorage ?? SecureTokenStorage();
    }

    // ---- Controllers (persist via kv) ----
    LocaleController? localeController;
    if (enabled.contains(CoreService.localization)) {
      final initial = await kv?.readString(LocaleController.storageKey);
      localeController = LocaleController(
        config: config,
        storage: kv,
        initialLanguageCode: initial,
      );
    }

    ThemeController? themeController;
    if (enabled.contains(CoreService.theme) && localeController != null) {
      final initialDark =
          await kv?.readBool(ThemeController.storageKey) ?? false;
      themeController = ThemeController(
        config: config,
        localeService: localeController,
        storage: kv,
        initialDark: initialDark,
      );
    }

    // ---- Network ----
    ApiClient? apiClient;
    if (needsNetwork) {
      apiClient = DioApiClient(
        tokenStorage: ts!,
        baseUrl: config.baseApiUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        enableLogging: enableNetworkLogging,
        onUnauthorized: onUnauthorized,
      );
    }

    // ---- Device info ----
    final deviceInfo = enabled.contains(CoreService.deviceInfo)
        ? DeviceInfoService()
        : null;

    return CoreContext(
      config: config,
      localeController: localeController,
      themeController: themeController,
      apiClient: apiClient,
      tokenStorage: (needsStorage || needsNetwork) ? ts : null,
      keyValueStorage: needsStorage ? kv : null,
      deviceInfoService: deviceInfo,
    );
  }

  /// Clear the stored config + translations. Intended for tests.
  static void reset() {
    _config = null;
    AppTranslation.init(const {});
  }
}
