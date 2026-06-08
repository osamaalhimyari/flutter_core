import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// [ForegroundService] backed by `flutter_foreground_task`. Requires the
/// Android `<service>` + permissions in AndroidManifest.xml (already added).
class ForegroundServiceImpl implements ForegroundService {
  bool _inited = false;

  @override
  Future<void> initialize() async {
    if (_inited) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'core_example_fg',
        channelName: 'Foreground Service',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
    _inited = true;
  }

  @override
  Future<void> start({
    required String notificationTitle,
    required String notificationText,
  }) async {
    await initialize();
    if (await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: notificationTitle,
      notificationText: notificationText,
    );
  }

  @override
  Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}
