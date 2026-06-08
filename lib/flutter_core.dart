/// Shared core for the im2m taxi apps (driver & rider).
///
/// Material-aware (it builds `ThemeData`) but with **no state-management
/// lock-in**: `Core.init` returns a [CoreContext] with framework-agnostic
/// controllers (stream-based) you wire into Bloc, GetX, or Provider.
///
/// ```dart
/// final core = await Core.init(
///   config: CoreConfig(
///     appName: 'Taxi Driver',
///     prefix: 'driver',
///     baseApiUrl: 'http://167.99.136.218:4000',
///     lightColors: const LightColors(), // your AppColors impl
///     darkColors: const DarkColors(),
///     locales: const [EnUs(), ArAr()],  // your CoreLocale subclasses
///   ),
///   services: const {CoreService.localization, CoreService.theme, CoreService.network},
/// );
/// // MaterialApp(theme: core.themeController!.lightTheme, ...)
/// // then bind core.localeController!.changes / core.themeController!.changes
/// // to Bloc / GetX / Provider (see example/ADAPTERS.md).
/// ```
/// See `README.md` for full integration instructions.
library;

// ---- Entry point + configuration ----
export 'src/core.dart'; // Core, CoreContext
export 'src/config/core_config.dart';
export 'src/config/core_service.dart';
export 'src/config/core_locale.dart';
export 'src/config/core_fonts.dart';

// ---- Theme (ThemeData) + color contract ----
export 'src/theme/app_colors.dart';
export 'src/theme/app_theme.dart'; // AppTheme, ColorsModel, AppThemeGetter

// ---- Localization (engine + delegate + keys) ----
export 'src/localization/app_translation.dart';
export 'src/localization/app_localizations.dart'; // AppLocalizations, context.tr
export 'src/localization/core_keys.dart';

// ---- Network ----
export 'src/network/api_client.dart';
export 'src/network/api_response.dart';
export 'src/network/dio_api_client.dart';

// ---- Storage (token + key/value + JSON; secure / shared_prefs / in-memory) --
export 'src/storage/token_storage.dart';
export 'src/storage/key_value_storage.dart';

// ---- Domain entities (pure Dart) ----
export 'src/models/geo_position.dart';
export 'src/models/geo_address.dart';
export 'src/models/location_permission_status.dart';
export 'src/models/search_prediction.dart';

// ---- Service contracts + framework-agnostic controllers ----
export 'src/services/locale_service.dart';
export 'src/services/theme_service.dart';
export 'src/services/device_info_service.dart';
export 'src/services/app_info.dart';
export 'src/state/locale_controller.dart';
export 'src/state/theme_controller.dart';

// ---- Domain service contracts (your app implements + registers these) ----
export 'src/services/location_service.dart';
export 'src/services/geocoding_service.dart';
export 'src/services/notification_service.dart';
export 'src/services/sound_service.dart';
export 'src/services/foreground_service.dart';

// ---- Concrete maps services (Google Maps / Places) ----
export 'src/services/route_service.dart';
export 'src/services/search_service.dart';

// ---- Errors / use cases / utils ----
export 'src/errors/exceptions.dart';
export 'src/errors/failures.dart';
export 'src/errors/server_error_keys.dart';
export 'src/usecase/usecase.dart';
export 'src/utils/validators.dart';

// ---- Convenience re-exports (functional error handling used by UseCase) ----
export 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;
