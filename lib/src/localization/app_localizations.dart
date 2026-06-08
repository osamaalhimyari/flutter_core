import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app_translation.dart';

/// Flutter-native localization, fed by [AppTranslation] (which `Core.init`
/// populates from `CoreConfig.locales`). Usage in widgets:
///
///     Text(context.tr('confirm'))   // your app's key
///     Text(context.tr(MyAppKeys.signIn))
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String tr(String key) => AppTranslation.translate(key, locale.languageCode);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final codes = AppTranslation.keys.keys
        .map((k) => k.split('_').first)
        .toSet();
    return codes.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Sugar: `context.tr('sign_in')`
extension TranslateExt on BuildContext {
  String tr(String key) => AppLocalizations.of(this).tr(key);
}
