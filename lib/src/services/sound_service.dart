/// Plays short, fire-and-forget audio cues. **Your app** implements it (under
/// `lib/logic/audio/`, wrapping audioplayers) and registers it with your DI.
///
/// These cue names mirror the rider trip flow; adjust per app — core only owns
/// the contract.
abstract class SoundService {
  /// Bring up audio player resources. Safe to call more than once.
  Future<void> initialize();

  /// Play the "trip request sent" cue.
  Future<void> playTripRequestedCue();

  /// Play after a driver accepts the trip.
  Future<void> playTripAcceptedCue();

  /// Play when the trip is completed.
  Future<void> playTripFinishedCue();

  /// Generic in-app notification cue (foreground), e.g. trip cancelled.
  Future<void> playNotificationCue();

  /// Release native resources. Called from app shutdown.
  Future<void> dispose();
}
