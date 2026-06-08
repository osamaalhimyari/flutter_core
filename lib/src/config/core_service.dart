/// The services `FlutterCore.init` wires into the returned `CoreContext`.
///
/// Pass a subset to `FlutterCore.init(services: {...})`; omit it to enable all.
/// Nothing is registered into any DI container — take the built objects off the
/// `CoreContext` and wire them into get_it / GetX / Provider yourself.
///
/// Two kinds:
///  * **Built by core** from `CoreConfig` — no impl needed.
///  * **Provided by you** — abstract platform contracts core can't construct;
///    pass your impl to `FlutterCore.init(...)` (e.g. `locationService:`), or
///    `init` throws telling you which one is missing.
enum CoreService {
  // ---- Built by core from CoreConfig ----
  /// `LocaleController` (framework-agnostic, exposes a change Stream).
  localization,

  /// `ThemeController` (exposes `ThemeData` + a change Stream). Auto-enables
  /// [localization] (font per language).
  theme,

  /// `ApiClient` (a `DioApiClient`) using the configured base URL + a
  /// `TokenStorage`.
  network,

  /// `KeyValueStorage` (shared_preferences) + `TokenStorage` (secure). Used to
  /// persist locale/theme; pass your own impls to override.
  storage,

  /// `DeviceInfoService`.
  deviceInfo,

  /// `RouteService` (Google Directions polylines). Uses
  /// `CoreConfig.googleMapsApiKey`.
  route,

  /// `SearchService` (Google Places autocomplete). Uses
  /// `CoreConfig.googleMapsApiKey`; auto-enables [localization].
  search,

  // ---- Provided by you (pass the impl to FlutterCore.init) ----
  /// Your `LocationService` impl (e.g. geolocator). Pass `locationService:`.
  location,

  /// Your `GeocodingService` impl. Pass `geocodingService:`.
  geocoding,

  /// Your `NotificationService` impl. Pass `notificationService:`.
  notification,

  /// Your `SoundService` impl. Pass `soundService:`.
  sound,

  /// Your `ForegroundService` impl. Pass `foregroundService:`.
  foreground,
}
