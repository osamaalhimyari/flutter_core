/// Action a user can take on the incoming-call notification's buttons.
enum IncomingCallNotificationAction { answer, decline }

/// Signature for the callback registered via
/// [NotificationService.setIncomingCallActionHandler]. Fires when the user
/// taps Answer or Decline on the notification.
typedef IncomingCallActionHandler =
    void Function(int tripId, IncomingCallNotificationAction action);

/// Minimal interface over the platform's local-notification system. **Your
/// app** implements it (under `lib/logic/notifications/`, wrapping
/// flutter_local_notifications) and registers it with your DI.
///
/// These method names mirror the rider app's trip/call flow; adjust per app as
/// needed — core only owns the contract.
abstract class NotificationService {
  /// Initialize platform plugins and request iOS permissions if needed.
  /// Idempotent — safe to call from `main.dart` and again on resume.
  Future<void> initialize();

  /// Ask the user for notification permission. iOS drives the native prompt;
  /// Android 13+ triggers `POST_NOTIFICATIONS`; older Android returns `true`.
  Future<bool> requestPermissions();

  /// Show a heads-up "trip update" notification. [tripId] rides in the payload
  /// so a tap-handler can deep-link back into the trip.
  Future<void> showTripUpdateNotification({
    required String tripId,
    required String title,
    required String body,
  });

  /// Cancel any "trip update" notification previously posted.
  Future<void> cancelTripUpdateNotification();

  /// Post the lock-screen takeover for an incoming voice call (Android:
  /// `category: call` + full-screen intent; iOS: time-sensitive notification).
  /// Action taps are forwarded to [setIncomingCallActionHandler].
  Future<void> showIncomingCallNotification({
    required int tripId,
    required String peerName,
  });

  /// Dismiss the incoming-call notification. Idempotent.
  Future<void> cancelIncomingCallNotification();

  /// Register the Answer/Decline tap callback. `null` clears it (also how a
  /// feature gets wiped on logout). Replaces any previous handler.
  void setIncomingCallActionHandler(IncomingCallActionHandler? handler);
}
