# Wiring `flutter_core` to Bloc / GetX / Provider

`FlutterCore.init` returns a `CoreContext` with framework-agnostic controllers:

- `LocaleController` — `currentLocale`, `changeLocale`, `switchToNextLanguage`,
  `Stream<Locale> get changes`
- `ThemeController` — `isDarkMode`, `themeMode`, `lightTheme`/`darkTheme`
  (`ThemeData`), `switchTheme`, `setDarkMode`, `Stream<ThemeMode> get changes`

`main.dart` here uses plain `StreamBuilder` (no SM dependency). The same
controllers drop into any state manager — bind to the `changes` stream for
rebuilds, call the methods to mutate, and read `lightTheme`/`darkTheme` for
`MaterialApp`. Persistence (locale/theme) is handled by core via the
`KeyValueStorage` (shared_preferences) it uses internally — no SM-specific
persistence needed.

```dart
final core = await FlutterCore.init(config: ..., services: {...});
```

## Bloc (flutter_bloc)

```dart
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._c) : super(_c.themeMode) {
    _sub = _c.changes.listen(emit);
  }
  final ThemeController _c;
  late final StreamSubscription<ThemeMode> _sub;
  void toggle() => _c.switchTheme();
  ThemeData get light => _c.lightTheme;
  ThemeData get dark => _c.darkTheme;
  @override
  Future<void> close() { _sub.cancel(); return super.close(); }
}

// getIt.registerSingleton(core.themeController!);
// BlocProvider(create: (_) => ThemeCubit(getIt()));
// BlocBuilder<ThemeCubit, ThemeMode>(builder: ...)
```

## GetX

```dart
class ThemeBinding extends GetxController {
  ThemeBinding(this._c);
  final ThemeController _c;
  final mode = Rx<ThemeMode>(ThemeMode.system);
  @override
  void onInit() {
    mode.value = _c.themeMode;
    _c.changes.listen((m) => mode.value = m);
    super.onInit();
  }
  void toggle() => _c.switchTheme();
}

// Get.put(core.themeController!); Get.put(ThemeBinding(Get.find()));
// Obx(() => MaterialApp(themeMode: binding.mode.value, ...))
```

## Provider

```dart
// Expose the change stream; read core.themeController for the ThemeData.
StreamProvider<ThemeMode>(
  create: (_) => core.themeController!.changes,
  initialData: core.themeController!.themeMode,
  child: MyApp(),
);
// read:   context.watch<ThemeMode>()
// mutate: core.themeController!.switchTheme();
```

`LocaleController` follows the exact same shape (`Stream<Locale> get changes`).
