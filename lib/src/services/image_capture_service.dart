import 'package:image_picker/image_picker.dart';

/// Captures a photo. Abstracted so a bloc depends on a plain `Future<String?>`
/// (a file path, or null if cancelled) and tests can fake it without a camera.
abstract class ImageCaptureService {
  /// Open the camera and return the captured file path, or null if cancelled.
  Future<String?> capturePhoto({int imageQuality = 70, double maxWidth = 1600});
}

class ImageCaptureServiceImpl implements ImageCaptureService {
  final ImagePicker _picker;

  ImageCaptureServiceImpl([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  @override
  Future<String?> capturePhoto({
    int imageQuality = 70,
    double maxWidth = 1600,
  }) async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
    );
    return file?.path;
  }
}
