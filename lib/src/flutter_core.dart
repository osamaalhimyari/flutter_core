import 'package:shared_preferences/shared_preferences.dart';

import 'config/core_config.dart';
import 'config/core_service.dart';
import 'localization/app_translation.dart';
import 'network/api_client.dart';
import 'network/dio_api_client.dart';
import 'services/device_info_service.dart';
import 'services/foreground_service.dart';
import 'services/geocoding_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/route_service.dart';
import 'services/search_service.dart';
import 'services/sound_service.dart';
import 'state/locale_controller.dart';
import 'state/theme_controller.dart';
import 'storage/key_value_storage.dart';
import 'storage/token_storage.dart';

/// What `FlutterCore.init` builds and hands back. Take the pieces you enabled
/// and register them with **your** state management / DI:
///
/// ```dart
/// final core = await FlutterCore.init(config: cfg, services: {...});
/// // Bloc + get_it:  getIt.registerSingleton(core.themeController!);
/// // GetX:           Get.put(core.themeController!);
/// // Provider:       Provider.value(value: core.themeController!);
/// ```
///
/// Fields are non-null only for the [CoreService]s you enabled. The domain
/// services ([locationService] … [foregroundService]) are whatever impl you
/// passed to [FlutterCore.init].
class CoreContext {
  final CoreConfig config;

  // Built by core.
  final LocaleController? localeController;
  final ThemeController? themeController;
  final ApiClient? apiClient;
  final TokenStorage? tokenStorage;
  final KeyValueStorage? keyValueStorage;
  final DeviceInfoService? deviceInfoService;
  final RouteService? routeService;
  final SearchService? searchService;

  // Provided by you (passed to init), surfaced here for convenience.
  final LocationService? locationService;
  final GeocodingService? geocodingService;
  final NotificationService? notificationService;
  final SoundService? soundService;
  final ForegroundService? foregroundService;

  const CoreContext({
    required this.config,
    this.localeController,
    this.themeController,
    this.apiClient,
    this.tokenStorage,
    this.keyValueStorage,
    this.deviceInfoService,
    this.routeService,
    this.searchService,
    this.locationService,
    this.geocodingService,
    this.notificationService,
    this.soundService,
    this.foregroundService,
  });
}

/// The entry point for the core package. Material-aware (builds `ThemeData`)
/// but with no state-management lock-in.
///
/// Call [init] once from `main()`; it installs the [CoreConfig], wires the
/// requested [CoreService]s, and returns a [CoreContext] for you to register
/// into Bloc / GetX / Provider. Read the config anywhere via [config].
class FlutterCore {
  FlutterCore._();

  static CoreConfig? _config;

  /// The active configuration. Throws if [init] hasn't run yet.
  static CoreConfig get config =>
      _config ??
      (throw StateError(
        'FlutterCore.init() has not been called. Call FlutterCore.init(...) in '
        'main() before reading FlutterCore.config.',
      ));

  static bool get isInitialized => _config != null;

  /// Install [config], wire [services], and return a [CoreContext].
  ///
  /// - [services] defaults to every [CoreService]. Enabling [CoreService.theme]
  ///   or [CoreService.search] auto-enables [CoreService.localization].
  /// - [tokenStorage] / [keyValueStorage] override the storage defaults
  ///   ([SecureTokenStorage] / [SharedPrefsStorage]); locale + theme persist
  ///   through the key-value store.
  /// - The domain impls ([locationService] … [foregroundService]) are required
  ///   when the matching [CoreService] is enabled — core can't construct an
  ///   abstract contract, so you pass the impl and it's surfaced on the context.
  /// - [onUnauthorized] fires on a 401; [enableNetworkLogging] toggles Dio logs.
  static Future<CoreContext> init({
    required CoreConfig config,
    Set<CoreService>? services,
    TokenStorage? tokenStorage,
    KeyValueStorage? keyValueStorage,
    LocationService? locationService,
    GeocodingService? geocodingService,
    NotificationService? notificationService,
    SoundService? soundService,
    ForegroundService? foregroundService,
    void Function()? onUnauthorized,
    bool enableNetworkLogging = false,
  }) async {
    _config = config;
    AppTranslation.init(config.translationKeys);

    final enabled = {...(services ?? CoreService.values.toSet())};
    // theme + search both need a LocaleController (font / query language).
    if (enabled.contains(CoreService.theme) ||
        enabled.contains(CoreService.search)) {
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

    // ---- Maps services (built from the configured key) ----
    final mapsKey = config.googleMapsApiKey ?? '';
    final route = enabled.contains(CoreService.route)
        ? RouteService(apiKey: mapsKey)
        : null;
    final search = (enabled.contains(CoreService.search) &&
            localeController != null)
        ? SearchService(apiKey: mapsKey, localeService: localeController)
        : null;

    // ---- Domain services: you supply the impl when the service is enabled ----
    final location = _require(
      enabled,
      CoreService.location,
      locationService,
      'locationService',
    );
    final geocoding = _require(
      enabled,
      CoreService.geocoding,
      geocodingService,
      'geocodingService',
    );
    final notification = _require(
      enabled,
      CoreService.notification,
      notificationService,
      'notificationService',
    );
    final soundSvc = _require(
      enabled,
      CoreService.sound,
      soundService,
      'soundService',
    );
    final foreground = _require(
      enabled,
      CoreService.foreground,
      foregroundService,
      'foregroundService',
    );

    return CoreContext(
      config: config,
      localeController: localeController,
      themeController: themeController,
      apiClient: apiClient,
      tokenStorage: (needsStorage || needsNetwork) ? ts : null,
      keyValueStorage: needsStorage ? kv : null,
      deviceInfoService: deviceInfo,
      routeService: route,
      searchService: search,
      locationService: location,
      geocodingService: geocoding,
      notificationService: notification,
      soundService: soundSvc,
      foregroundService: foreground,
    );
  }

  /// Returns [impl] when [service] is enabled, throwing a helpful error if the
  /// app forgot to pass it. Returns null when the service isn't enabled.
  static T? _require<T>(
    Set<CoreService> enabled,
    CoreService service,
    T? impl,
    String paramName,
  ) {
    if (!enabled.contains(service)) return null;
    if (impl == null) {
      throw ArgumentError(
        'CoreService.${service.name} is enabled but no $paramName was passed '
        'to FlutterCore.init(). Core ships the contract; you provide the impl.',
      );
    }
    return impl;
  }

  /// Clear the stored config + translations. Intended for tests.
  static void reset() {
    _config = null;
    AppTranslation.init(const {});
  }
}
