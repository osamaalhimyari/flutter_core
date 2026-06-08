import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

/// Severity of an [AppMessageDialog] — drives the icon, accent color, and the
/// default (translated) title.
enum AppMessageType { error, success, info }

/// App-wide replacement for SnackBars: a modal dialog with a translated title,
/// the [message], and a single dismiss button.
Future<void> showAppMessageDialog(
  BuildContext context, {
  required String message,
  AppMessageType type = AppMessageType.info,
  String? title,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AppMessageDialog(
      message: message,
      type: type,
      title: title,
      onDismiss: () => Navigator.of(ctx).pop(),
    ),
  );
}

class AppMessageDialog extends StatelessWidget {
  const AppMessageDialog({
    super.key,
    required this.message,
    required this.onDismiss,
    this.type = AppMessageType.info,
    this.title,
  });

  final String message;
  final AppMessageType type;
  final String? title;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (IconData icon, Color accent) = switch (type) {
      AppMessageType.error => (Icons.error_outline, theme.colorScheme.error),
      AppMessageType.success => (
        Icons.check_circle_outline,
        theme.colorsModel.success,
      ),
      AppMessageType.info => (Icons.info_outline, theme.colorScheme.primary),
    };

    return AlertDialog(
      icon: Icon(icon, color: accent, size: 32),
      title: Text(
        title ?? context.tr(_defaultTitleKey),
        textAlign: TextAlign.center,
      ),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: onDismiss,
          child: Text(context.tr(CoreKeys.dialogOk)),
        ),
      ],
    );
  }

  String get _defaultTitleKey => switch (type) {
    AppMessageType.error => CoreKeys.dialogErrorTitle,
    AppMessageType.success => CoreKeys.dialogSuccessTitle,
    AppMessageType.info => CoreKeys.dialogNoticeTitle,
  };
}
