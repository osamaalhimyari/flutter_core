import 'package:example/shared/app_dialog.dart';
import 'package:example/shared/status_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'localization/app_locales.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Core owns theme/locale/storage now; it persists locale+theme via
  // shared_preferences by default. We only supply app-specific config: our
  // colors (implementing AppColors) and our languages (extending CoreLocale).
  final core = await Core.init(
    config: const CoreConfig(
      appName: 'Flutter Core Example',
      prefix: 'example',
      baseApiUrl: 'https://example.com',
      lightColors: LightColors(),
      darkColors: DarkColors(),
      locales: [EnUs(), ArAr()],
    ),
    services: const {
      CoreService.localization,
      CoreService.theme,
      CoreService.network,
      CoreService.storage,
      CoreService.deviceInfo,
    },
    enableNetworkLogging: kDebugMode,
  );

  await AppInfo.init();
  runApp(ExampleApp(core: core));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key, required this.core});
  final CoreContext core;

  @override
  Widget build(BuildContext context) {
    final locale = core.localeController!;
    final theme = core.themeController!;

    // Rebuild on language/theme changes via the controllers' streams. The same
    // streams plug into a Bloc Cubit / GetxController / ChangeNotifier — see
    // ADAPTERS.md.
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
              // ThemeData comes from the core controller.
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

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.core});
  final CoreContext core;

  @override
  Widget build(BuildContext context) {
    final locale = core.localeController!;
    final theme = core.themeController!;
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('home_title'))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.tr('home_greeting'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: theme.switchTheme,
              icon: const Icon(Icons.brightness_6_outlined),
              label: Text(context.tr(CoreKeys.switchTheme)),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: locale.switchToNextLanguage,
              icon: const Icon(Icons.translate),
              label: Text(
                '${context.tr(CoreKeys.switchLanguage)} '
                '(${locale.currentLanguageName})',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => showAppMessageDialog(
                context,
                type: AppMessageType.success,
                message: context.tr(CoreKeys.confirm),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(context.tr(CoreKeys.dialogOk)),
            ),
            // Validators live in core; the widget translates the returned key.
            StatusCard(
              isError: true,
              title: context.tr(CoreKeys.dialogErrorTitle),
              message: context.tr(Validators.validateEmail('not-an-email')!),
            ),
            const Spacer(),
            Text(
              'v${AppInfo.full}  •  ${core.config.baseApiUrl}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
