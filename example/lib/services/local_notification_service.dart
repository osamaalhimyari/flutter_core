import 'package:my_core/my_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// [NotificationService] backed by `flutter_local_notifications`.
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  IncomingCallActionHandler? _callHandler;
  bool _inited = false;

  static const _tripChannelId = 'core_example_trip';
  static const _callChannelId = 'core_example_call';
  static const _tripNotifId = 1001;
  static const _callNotifId = 1002;

  @override
  Future<void> initialize() async {
    if (_inited) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onResponse,
    );
    _inited = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await android?.requestNotificationsPermission();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return androidGranted ?? iosGranted ?? true;
  }

  @override
  Future<void> showTripUpdateNotification({
    required String tripId,
    required String title,
    required String body,
  }) async {
    await initialize();
    await _plugin.show(
      _tripNotifId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _tripChannelId,
          'Trip updates',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'trip:$tripId',
    );
  }

  @override
  Future<void> cancelTripUpdateNotification() => _plugin.cancel(_tripNotifId);

  @override
  Future<void> showIncomingCallNotification({
    required int tripId,
    required String peerName,
  }) async {
    await initialize();
    await _plugin.show(
      _callNotifId,
      'Incoming call',
      peerName,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _callChannelId,
          'Calls',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.call,
          fullScreenIntent: true,
          actions: [
            AndroidNotificationAction('answer', 'Answer'),
            AndroidNotificationAction('decline', 'Decline'),
          ],
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'call:$tripId',
    );
  }

  @override
  Future<void> cancelIncomingCallNotification() => _plugin.cancel(_callNotifId);

  @override
  void setIncomingCallActionHandler(IncomingCallActionHandler? handler) =>
      _callHandler = handler;

  void _onResponse(NotificationResponse r) {
    final payload = r.payload;
    if (payload == null || !payload.startsWith('call:')) return;
    final tripId = int.tryParse(payload.substring(5));
    if (tripId == null) return;
    final action = switch (r.actionId) {
      'answer' => IncomingCallNotificationAction.answer,
      'decline' => IncomingCallNotificationAction.decline,
      _ => null,
    };
    if (action != null) _callHandler?.call(tripId, action);
  }
}
