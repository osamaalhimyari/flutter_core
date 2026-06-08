import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';

/// [SoundService] using the platform's system sound + haptics. A real app would
/// back this with `audioplayers` and bundled cue assets; this keeps the example
/// asset-free while still exercising the contract.
class SystemSoundService implements SoundService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> playTripRequestedCue() => _cue();

  @override
  Future<void> playTripAcceptedCue() => _cue();

  @override
  Future<void> playTripFinishedCue() => _cue();

  @override
  Future<void> playNotificationCue() => _cue();

  @override
  Future<void> dispose() async {}

  Future<void> _cue() async {
    await SystemSound.play(SystemSoundType.alert);
    await HapticFeedback.mediumImpact();
  }
}
