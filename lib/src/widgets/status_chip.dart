import 'package:flutter/material.dart';

import '../theme/app_theme.dart'; // AppThemeGetter → ThemeData.colorsModel

/// Tone selects the semantic color for a [StatusChip].
enum ChipTone { neutral, success, info, warning, error }

/// Small colored pill for a status/category (e.g. payment status, a flag).
/// Bloc-free. Pulls success/info/warning from `ThemeData.colorsModel` and
/// error/outline from the standard `ColorScheme`.
class StatusChip extends StatelessWidget {
  final String label;
  final ChipTone tone;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.tone = ChipTone.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorsModel;
    final scheme = theme.colorScheme;

    final Color base = switch (tone) {
      ChipTone.success => colors.success,
      ChipTone.info => colors.info,
      ChipTone.warning => colors.warning,
      ChipTone.error => scheme.error,
      ChipTone.neutral => scheme.outline,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: base.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: base),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: base,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
