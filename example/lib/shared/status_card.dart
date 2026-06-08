import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

/// Colored status banner that flips between success/error styling. Shrinks to
/// nothing when [message] is empty. Reads the custom `colorsModel` extension.
class StatusCard extends StatelessWidget {
  final String? title;
  final String? message;
  final bool isError;

  const StatusCard({super.key, this.title, this.message, this.isError = false});

  bool get _visible => message != null && message!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final color = isError ? theme.colorScheme.error : theme.colorsModel.success;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty)
                  Text(
                    title!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  message!,
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
