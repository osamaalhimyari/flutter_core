import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_core/flutter_core.dart';
import 'app_bottom_sheet.dart';

/// Tappable card that picks an image from camera/gallery and previews it.
/// Labels come from [CoreKeys] via `context.tr`.
class ImagePickerField extends StatelessWidget {
  final String? label;
  final File? value;
  final ValueChanged<File> onPicked;
  final double height;
  final IconData placeholderIcon;

  const ImagePickerField({
    super.key,
    this.label,
    required this.value,
    required this.onPicked,
    this.height = 160,
    this.placeholderIcon = Icons.add_a_photo_outlined,
  });

  Future<void> _pick(BuildContext context) async {
    final source = await showAppBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(ctx.tr(CoreKeys.imageTakePhoto)),
            onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(ctx.tr(CoreKeys.imageFromGallery)),
            onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked != null) onPicked(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
              image: value == null
                  ? null
                  : DecorationImage(
                      image: FileImage(value!),
                      fit: BoxFit.cover,
                    ),
            ),
            child: value == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          placeholderIcon,
                          size: 32,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr(CoreKeys.imageTapToAdd),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
