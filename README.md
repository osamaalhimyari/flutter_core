# flutter_core

Shared core for the **im2m taxi apps** (`driver_app_flutter` & `rider_app_flutter`).
One package holds everything the two apps share — config, theme, localization,
network, storage, device info, domain service contracts, entities, and shared
widgets — with the parts that differ (app name, base URL, colors, languages,
endpoints…) turned into **configuration** you pass once via `CoreConfig` +
`FlutterCore.init`.

Two deliberate design choices:

- **Material-aware, but no state-management lock-in.** Core builds `ThemeData`
  and ships widgets, but it does **not** depend on bloc/get_it. `FlutterCore.init`
  returns a `CoreContext`; you wire its stream-based controllers into **Bloc,
  GetX, or Provider** (see [`example/ADAPTERS.md`](example/ADAPTERS.md)).
- **No baked-in content.** Colors, fonts, languages and translations all come
  from your project. Core ships the *contracts* and *engine*, not a palette or
  a language.

---

## What's inside

Every service flows through `FlutterCore.init` and comes back on the
`CoreContext`. There are two kinds, both listed in the `CoreService` enum:

**Built by core** from `CoreConfig` (no impl needed):

| `CoreService` | On `CoreContext` |
|---------------|------------------|
| `localization` | `LocaleController` (stream + `LocaleService`) |
| `theme` | `ThemeController` (stream + `ThemeService`, builds `ThemeData`) |
| `network` | `ApiClient` (`DioApiClient`) |
| `storage` | `KeyValueStorage` (shared_prefs, **JSON-capable**) + `TokenStorage` (secure) |
| `deviceInfo` | `DeviceInfoService` |
| `route` | `RouteService` (Directions polylines; uses `googleMapsApiKey`) |
| `search` | `SearchService` (Places autocomplete; uses `googleMapsApiKey`) |

**Provided by you** — abstract contracts core can't construct; pass your impl
to `FlutterCore.init(...)` and it's surfaced on the context:

| `CoreService` | Pass to `init` | On `CoreContext` |
|---------------|----------------|------------------|
| `location` | `locationService:` | `LocationService` |
| `geocoding` | `geocodingService:` | `GeocodingService` |
| `notification` | `notificationService:` | `NotificationService` |
| `sound` | `soundService:` | `SoundService` |
| `foreground` | `foregroundService:` | `ForegroundService` |

You implement: `AppColors` (light+dark), locale classes that `extend CoreLocale`,
and the 5 domain contracts above.

| Also exported (no init needed) | |
|--------------------------------|--|
| Theme | `AppTheme.build`, `ColorsModel`, `Theme.of(c).colorsModel` |
| Localization | `AppLocalizations` + `context.tr`, `AppTranslation` (your app owns the keys) |
| Errors / domain | `Failure`(+subtypes), `ServerException`, `ServerErrorKeys`, `UseCase`, `Validators`, `Either` |
| Entities | `GeoPosition`, `GeoAddress`, `LocationPermissionStatus`, `SearchPrediction` |
| Widgets (in `example/`) | `showAppMessageDialog`, `showAppBottomSheet`, `StatusCard`, `ImagePickerField` |
| App info | `AppInfo` (call `AppInfo.init()`) |

---

## Install

```yaml
dependencies:
  flutter_core:
    path: ../../packages/flutter_core
```

---

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final core = await FlutterCore.init(
    config: const CoreConfig(
      appName: 'Taxi Driver',
      prefix: 'driver',
      baseApiUrl: 'http://167.99.136.218:4000',
      lightColors: LightColors(), // your AppColors impl
      darkColors: DarkColors(),
      locales: [EnUs(), ArAr()],  // your CoreLocale subclasses
      endpoints: {'login': '/api/auth/login'},
      extras: {'useFakeTrips': false, 'googleMapsApiKey': 'AIza...'},
    ),
    services: const {
      CoreService.localization,
      CoreService.theme,
      CoreService.network,
      CoreService.storage,
      CoreService.deviceInfo,
    },
    onUnauthorized: () => /* your global sign-out */,
  );

  await AppInfo.init();
  runApp(MyApp(core: core));
}
```

Drive `MaterialApp` from the controllers (plain `StreamBuilder` shown — swap for
your Bloc/GetX/Provider binding):

```dart
StreamBuilder<Locale>(
  stream: core.localeController!.changes,
  initialData: core.localeController!.currentLocale,
  builder: (_, localeSnap) => StreamBuilder<ThemeMode>(
    stream: core.themeController!.changes,
    initialData: core.themeController!.themeMode,
    builder: (_, __) => MaterialApp(
      title: core.config.appName,
      themeMode: core.themeController!.themeMode,
      theme: core.themeController!.lightTheme,
      darkTheme: core.themeController!.darkTheme,
      locale: localeSnap.data,
      supportedLocales: core.config.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomePage(),
    ),
  ),
);
```

See the runnable [`example/`](example/) app and
[`example/ADAPTERS.md`](example/ADAPTERS.md) for Bloc / GetX / Provider.

---

## Opt into services

Pass a subset to `services:`; omit it to build everything. Take the built
objects off the `CoreContext` and register them with your DI.

```dart
services: const {CoreService.network},                       // just the API client
services: const {CoreService.localization, CoreService.theme},
```

`CoreService.theme` auto-enables `CoreService.localization` (font per language).

---

## Colors

`lightColors`/`darkColors` are **required** — implement `AppColors` in your app:

```dart
class LightColors implements AppColors {
  const LightColors();
  @override Color get primary => const Color(0xFF1E3A5F);
  // ...15 tokens (copy the full palette from example/lib/theme/app_colors.dart)
}
```

Read semantic colors anywhere: `Theme.of(context).colorScheme.primary`,
`Theme.of(context).colorsModel.success`.

---

## Languages & translations

Everything comes from your project. Extend `CoreLocale`, one class per language,
each calling `super(...)`:

```dart
class EnUs extends CoreLocale {
  const EnUs() : super(
    languageCode: 'en', countryCode: 'US', displayName: 'English',
    fontFamily: 'Ubuntu',
    translations: const {
      'confirm': 'Confirm',       // your keys (define them in your own AppKeys)
      'home_title': 'Dashboard',
    },
  );
}
// CoreConfig(locales: const [EnUs(), ArAr()])
```

Core ships **no** key strings — your app owns its keys (e.g. an `AppKeys` class,
see `example/lib/localization/app_keys.dart`). An untranslated key renders
verbatim. Look up with `context.tr(AppKeys.confirm)`. Locale + theme selection
are **persisted via shared_preferences** automatically.

`Validators` return a neutral `ValidationError` enum (not a key string) — map it
to your own message: `context.tr(Validators.validateEmail(x)!.key)` (the `.key`
extension lives in your app — see the example).

---

## Storage (token + key/value + JSON)

`FlutterCore.init` defaults to `SecureTokenStorage` + `SharedPrefsStorage`; pass your
own to override. `KeyValueStorage` stores strings, bools, **and JSON**:

```dart
final kv = core.keyValueStorage!;
await kv.writeJson('profile', {'id': 7, 'name': 'Ada'});
final profile = await kv.readJson('profile');
final token = await core.tokenStorage!.read();
```

---

## Domain services & entities

Core ships **contracts + entities** for the platform services; you implement
them (wrapping geolocator / geocoding / flutter_local_notifications /
audioplayers / flutter_foreground_task) and **hand the impl to
`FlutterCore.init`** — it comes back on the `CoreContext`:

```dart
final core = await FlutterCore.init(
  config: cfg,
  services: const {CoreService.location, CoreService.geocoding,
      CoreService.notification, CoreService.sound, CoreService.foreground,
      CoreService.route, CoreService.search /* + the config-driven ones */},
  locationService: GeolocatorLocationService(),     // your impl
  geocodingService: GeocoderGeocodingService(),
  notificationService: LocalNotificationService(),
  soundService: SystemSoundService(),
  foregroundService: ForegroundServiceImpl(),
);
// core.locationService!, core.routeService!, core.searchService! …
```

Enabling `CoreService.location` (etc.) **without** passing its impl throws a
clear error — core ships the contract, you provide the impl. Entities returned:
`LocationService` → `GeoPosition` / `LocationPermissionStatus`; `GeocodingService`
→ `GeoAddress`; `SearchService` → `SearchPrediction`.

`route` / `search` are built by core from `CoreConfig.googleMapsApiKey` — no impl
needed.

> The notification/sound method names mirror the rider trip/call flow — adjust
> per app; core only owns the contract. See `example/lib/services/` for working
> impls of all five.

---

## Endpoints

`baseApiUrl`/`socketBaseUrl` feed the Dio client; named paths via
`FlutterCore.config.endpoint('login')`. Flags/secrets via `FlutterCore.config.flag<bool>('useFakeTrips')`.

---

## Testing

```bash
cd packages/flutter_core
flutter pub get && flutter analyze && flutter test
# example:
cd example && flutter pub get && flutter analyze
```
