import 'dart:async';

/// Reads smart-card / tag serials. Abstracted so a bloc subscribes to a plain
/// `Stream<String>` and never touches a plugin, and tests can feed a fake
/// stream.
///
/// The shipped implementation is [ManualOnlyNfcService]: it reports NFC
/// unavailable and emits nothing, so a screen falls back to manual serial entry
/// (a first-class path — some devices have no NFC, and cards get damaged).
/// Wiring a real reader (e.g. `nfc_manager`) is a drop-in replacement:
/// implement [startSession] to begin polling and push each tag's serial onto
/// [tags]; consumers need no changes.
abstract class NfcService {
  /// Whether this device can scan NFC right now.
  Future<bool> isAvailable();

  /// Tag serials as they are read. Broadcast so consumers can (re)subscribe.
  Stream<String> get tags;

  /// Begin polling for tags. No-op when NFC is unavailable.
  Future<void> startSession();

  /// Stop polling and release the reader.
  Future<void> stopSession();

  /// Release resources.
  Future<void> dispose();
}

/// Default implementation: no NFC, manual entry only. Keeps an app buildable and
/// usable without a device-specific plugin.
class ManualOnlyNfcService implements NfcService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Stream<String> get tags => _controller.stream;

  @override
  Future<void> startSession() async {}

  @override
  Future<void> stopSession() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
