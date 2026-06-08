/// The opt-in services `Core.init` can build into the returned `CoreContext`.
///
/// Pass a subset to `Core.init(services: {...})` to build only what an app
/// needs. Omitting the argument enables all of them. Nothing is registered
/// into any DI container — take the built objects off the `CoreContext` and
/// wire them into get_it / GetX / Provider yourself.
enum CoreService {
  /// Builds a `LocaleController` (framework-agnostic, exposes a change Stream).
  localization,

  /// Builds a `ThemeController` (framework-agnostic; exposes `ThemeData` +
  /// a change Stream). Depends on [localization] for font-per-language —
  /// enabling [theme] auto-enables [localization].
  theme,

  /// Builds an `ApiClient` (a `DioApiClient`) using the configured base URL +
  /// a `TokenStorage`.
  network,

  /// Provisions storage: a `KeyValueStorage` (shared_preferences) used to
  /// persist locale/theme, and a `TokenStorage` (secure). Pass your own impls
  /// to `Core.init` to override the defaults.
  storage,

  /// Builds a `DeviceInfoService`.
  deviceInfo,
}
