/// Platform-agnostic interface for a foreground service that keeps the app's
/// process (and its socket) alive while backgrounded. On Android that's a
/// foreground service + persistent notification; on iOS it needs VoIP/PushKit.
///
/// **Your app** implements it (under `lib/logic/foreground/`, wrapping
/// flutter_foreground_task) and registers it with your DI.
abstract class ForegroundService {
  /// Initialize platform plugins + notification channels. Idempotent — safe to
  /// call from `main.dart` on every cold start.
  Future<void> initialize();

  /// Start the foreground service + its persistent notification. No-op if
  /// already running. Pass the title/text already-translated (the service
  /// stays locale-agnostic).
  Future<void> start({
    required String notificationTitle,
    required String notificationText,
  });

  /// Tear the foreground service down. No-op if not running.
  Future<void> stop();
}
