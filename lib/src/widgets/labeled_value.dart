import 'package:flutter/material.dart';

/// A label → value row used on detail and receipt screens. [emphasize] renders
/// the value larger/bold (totals, invoice numbers). Direction-agnostic so it
/// mirrors correctly in RTL.
class LabeledValue extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  final Widget? trailing;

  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (trailing != null)
            trailing!
          else
            Text(
              value,
              textAlign: TextAlign.end,
              style: emphasize
                  ? theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)
                  : theme.textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }
}

/// A surface card wrapper with consistent padding + rounded corners.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}
