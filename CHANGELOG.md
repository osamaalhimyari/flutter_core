## 0.3.0

Shared core for `driver_app_flutter` / `rider_app_flutter`. Material-aware
(builds `ThemeData`) with **no state-management lock-in** and **no baked-in
content** (colors/fonts/languages come from your app).

* `FlutterCore.init(config, services, ...)` returns a `CoreContext`
  (DI-agnostic) — wire its controllers into Bloc / GetX / Provider.
  `FlutterCore.config` for global access. `CoreService` enum opts into `localization`, `theme`, `network`,
  `storage`, `deviceInfo` (any subset).
* Framework-agnostic, stream-based `LocaleController` / `ThemeController`
  (implement `LocaleService` / `ThemeService`); persist via shared_preferences.
* Theme: `AppTheme.build(AppColors, font, isDark)` → `ThemeData`, `ColorsModel`
  extension. `AppColors` is implemented by your app (no shipped palette).
* Localization: `CoreLocale` (extendable, per-app translations + fonts),
  `AppTranslation` engine, `AppLocalizations` + `context.tr`, `CoreKeys`.
* Storage: `TokenStorage` (`SecureTokenStorage` / `InMemoryTokenStorage`) and
  `KeyValueStorage` (`SharedPrefsStorage` / `InMemoryKeyValueStorage`) with
  string/bool/**JSON** (`readJson`/`writeJson`).
* Network: `ApiClient` + `DioApiClient` (base URL/timeouts from config),
  `ApiResponse`.
* Device/app info: `DeviceInfoService`, `AppInfo`.
* Entities: `GeoPosition`, `GeoAddress`, `LocationPermissionStatus`,
  `SearchPrediction`.
* Domain service contracts (app implements + registers): `LocationService`,
  `GeocodingService`, `NotificationService`, `SoundService`,
  `ForegroundService`.
* Concrete maps services: `RouteService`, `SearchService` (Google Maps/Places).
* Errors/domain: `Failure` (+subtypes), `ServerException`, `CacheException`,
  `ServerErrorKeys`, `UseCase`/`NoParams`, `Validators`.
* Shared widgets: `showAppMessageDialog`, `showAppBottomSheet`, `StatusCard`,
  `ImagePickerField`.
* `example/` — runnable Flutter app wiring it all with plain `StreamBuilder`;
  `example/ADAPTERS.md` shows Bloc / GetX / Provider.
