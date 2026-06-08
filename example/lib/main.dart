import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_core/my_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:permission_handler/permission_handler.dart';

import 'localization/app_keys.dart';
import 'localization/app_locales.dart';
import 'services/foreground_service_impl.dart';
import 'services/geocoder_geocoding_service.dart';
import 'services/geolocator_location_service.dart';
import 'services/local_notification_service.dart';
import 'services/system_sound_service.dart';
import 'shared/app_dialog.dart';
import 'shared/image_picker_field.dart';
import 'shared/status_card.dart';
import 'theme/app_colors.dart';

/// Replace with a real key to exercise Search (Places) + Route (Directions).
const String kGoogleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Everything is wired through FlutterCore.init: core builds the generic +
  // maps services from config; you pass the platform impls of the abstract
  // contracts (location/geocoding/notification/sound/foreground). They all
  // come back on the CoreContext.
  final core = await FlutterCore.init(
    config: const CoreConfig(
      appName: 'Flutter Core Example',
      prefix: 'example',
      baseApiUrl: 'https://example.com',
      lightColors: LightColors(),
      darkColors: DarkColors(),
      locales: [EnUs(), ArAr()],
      googleMapsApiKey: kGoogleMapsApiKey,
    ),
    services: CoreService.values.toSet(), // enable everything
    locationService: GeolocatorLocationService(),
    geocodingService: GeocoderGeocodingService(),
    notificationService: LocalNotificationService(),
    soundService: SystemSoundService(),
    foregroundService: ForegroundServiceImpl(),
    enableNetworkLogging: kDebugMode,
  );

  // Initialize the impls that need it (core stores them; it doesn't call init).
  await AppInfo.init();
  await core.notificationService!.initialize();
  await core.soundService!.initialize();
  await core.foregroundService!.initialize();

  runApp(ExampleApp(core: core));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key, required this.core});
  final CoreContext core;

  @override
  Widget build(BuildContext context) {
    final locale = core.localeController!;
    final theme = core.themeController!;
    return StreamBuilder<Locale>(
      stream: locale.changes,
      initialData: locale.currentLocale,
      builder: (context, localeSnap) {
        return StreamBuilder<ThemeMode>(
          stream: theme.changes,
          initialData: theme.themeMode,
          builder: (context, _) {
            return MaterialApp(
              title: core.config.appName,
              debugShowCheckedModeBanner: false,
              themeMode: theme.themeMode,
              theme: theme.lightTheme,
              darkTheme: theme.darkTheme,
              locale: localeSnap.data,
              supportedLocales: core.config.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: HomePage(core: core),
            );
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.core});
  final CoreContext core;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _result = '';
  bool _resultError = false;
  File? _picked;

  CoreContext get core => widget.core;

  /// Runs [action], showing its result (or error) in the StatusCard.
  Future<void> _run(String label, Future<String> Function() action) async {
    setState(() {
      _result = '$label…';
      _resultError = false;
    });
    try {
      final r = await action();
      setState(() => _result = '$label → $r');
    } catch (e) {
      setState(() {
        _result = '$label → $e';
        _resultError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = core.localeController!;
    final theme = core.themeController!;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('home_title')),
        actions: [
          IconButton(
            tooltip: context.tr(AppKeys.switchTheme),
            onPressed: theme.switchTheme,
            icon: const Icon(Icons.brightness_6_outlined),
          ),
          IconButton(
            tooltip: context.tr(AppKeys.switchLanguage),
            onPressed: locale.switchToNextLanguage,
            icon: const Icon(Icons.translate),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            context.tr('home_greeting'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          StatusCard(
            isError: _resultError,
            title: _resultError
                ? context.tr(AppKeys.dialogErrorTitle)
                : context.tr(AppKeys.dialogSuccessTitle),
            message: _result,
          ),
          const SizedBox(height: 8),

          _section('Localization & Theme'),
          _btn(
            Icons.brightness_6_outlined,
            context.tr(AppKeys.switchTheme),
            theme.switchTheme,
          ),
          _btn(
            Icons.translate,
            '${context.tr(AppKeys.switchLanguage)} (${locale.currentLanguageName})',
            locale.switchToNextLanguage,
          ),

          _section('Permissions'),
          _btn(Icons.verified_user_outlined, 'Request all permissions', () {
            _run('Permissions', () async {
              final res = await [
                Permission.locationWhenInUse,
                Permission.notification,
                Permission.camera,
              ].request();
              return res.entries
                  .map(
                    (e) =>
                        '${e.key.toString().split('.').last}=${e.value.name}',
                  )
                  .join(', ');
            });
          }),

          _section('Network'),
          _btn(Icons.cloud_outlined, 'GET ${core.config.baseApiUrl}', () {
            _run('Network', () async {
              final r = await core.apiClient!.get('/', requiresAuth: false);
              return 'status=${r.statusCode} success=${r.success}';
            });
          }),

          _section('Storage'),
          _btn(Icons.vpn_key_outlined, 'Save + read token', () {
            _run('Token', () async {
              await core.tokenStorage!.write('demo-token-123');
              return await core.tokenStorage!.read() ?? 'null';
            });
          }),
          _btn(Icons.data_object, 'Save + read JSON', () {
            _run('JSON', () async {
              await core.keyValueStorage!.writeJson('profile', {
                'id': 7,
                'name': 'Ada',
              });
              final j = await core.keyValueStorage!.readJson('profile');
              return j.toString();
            });
          }),

          _section('Device & App'),
          _btn(Icons.phone_android, 'Device info', () {
            _run('Device', () async {
              final d = await core.deviceInfoService!.getDeviceInfo();
              return '${d.platform} • ${d.deviceModel} • v${AppInfo.full}';
            });
          }),

          _section('Location & Maps'),
          _btn(Icons.my_location, 'Current position', () {
            _run('Location', () async {
              await core.locationService!.requestPermission();
              final p = await core.locationService!.getCurrentPosition();
              return '${p.latitude.toStringAsFixed(4)}, '
                  '${p.longitude.toStringAsFixed(4)}';
            });
          }),
          _btn(Icons.place_outlined, 'Reverse geocode (Baghdad)', () {
            _run('Geocode', () async {
              final a = await core.geocodingService!.reverseGeocode(
                latitude: 33.3152,
                longitude: 44.3661,
                localeCode: locale.currentLanguageCode,
              );
              return a.formatted.isEmpty ? 'unknown' : a.formatted;
            });
          }),
          _btn(Icons.search, 'Search places ("Baghd")', () {
            _run('Search', () async {
              final preds = await core.searchService!.searchLocations('Baghd');
              return preds.isEmpty
                  ? '0 results (set kGoogleMapsApiKey)'
                  : '${preds.length}: ${preds.first.mainText}';
            });
          }),
          _btn(Icons.route_outlined, 'Build route polyline', () {
            _run('Route', () async {
              final polys = await core.routeService!.buildPolylines(const [
                LatLng(33.3152, 44.3661),
                LatLng(33.3406, 44.4009),
              ]);
              return '${polys.length} polyline(s)';
            });
          }),

          _section('Notifications, Sound & Foreground'),
          _btn(Icons.notifications_active_outlined, 'Show trip notification', () {
            final title = context.tr(AppKeys.appName);
            _run('Notification', () async {
              await core.notificationService!.requestPermissions();
              await core.notificationService!.showTripUpdateNotification(
                tripId: '42',
                title: title,
                body: 'Your driver is arriving.',
              );
              return 'posted';
            });
          }),
          _btn(
            Icons.volume_up_outlined,
            'Play sound cue',
            () => _run('Sound', () async {
              await core.soundService!.playTripRequestedCue();
              return 'played';
            }),
          ),
          _btn(Icons.play_circle_outline, 'Start foreground service', () {
            final fgTitle = context.tr(AppKeys.appName);
            _run('Foreground', () async {
              await core.foregroundService!.start(
                notificationTitle: fgTitle,
                notificationText: 'Listening for trips…',
              );
              return 'started';
            });
          }),
          _btn(
            Icons.stop_circle_outlined,
            'Stop foreground service',
            () => _run('Foreground', () async {
              await core.foregroundService!.stop();
              return 'stopped';
            }),
          ),

          _section('Widgets & Validation'),
          _btn(Icons.info_outline, 'App message dialog', () {
            showAppMessageDialog(
              context,
              type: AppMessageType.success,
              message: context.tr('home_greeting'),
            );
          }),
          _btn(Icons.rule, 'Validate email (ValidationError → key)', () {
            // Core returns a neutral ValidationError; the app maps it to its
            // own key via the `.key` extension, then translates it.
            final err = Validators.validateEmail('not-an-email');
            setState(() {
              _resultError = err != null;
              _result =
                  'Validate → ${err == null ? 'valid' : context.tr(err.key)}';
            });
          }),
          const SizedBox(height: 8),
          ImagePickerField(
            label: 'ImagePickerField',
            value: _picked,
            onPicked: (f) => setState(() {
              _picked = f;
              _result = 'Image → ${f.path.split(Platform.pathSeparator).last}';
              _resultError = false;
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 6),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );

  Widget _btn(IconData icon, String label, VoidCallback onPressed) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(label),
      ),
    ),
  );
}
