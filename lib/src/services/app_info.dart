import 'package:package_info_plus/package_info_plus.dart';

/// One-time read of the app's version + build number, cached for the process.
/// Call [AppInfo.init] from `main()` (after `Core.init` or any time before the
/// first read).
class AppInfo {
  AppInfo._();

  static String _version = '';
  static String _buildNumber = '';

  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    _version = info.version;
    _buildNumber = info.buildNumber;
  }

  /// Marketing version, e.g. `1.0.0`.
  static String get version => _version;

  /// Build number, e.g. `1`.
  static String get buildNumber => _buildNumber;

  /// Combined `version+build`, e.g. `1.0.0+1`.
  static String get full =>
      _buildNumber.isEmpty ? _version : '$_version+$_buildNumber';
}
