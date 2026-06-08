import 'package:flutter/material.dart';

/// Drop-in replacement for `showModalBottomSheet` that floats the sheet as a
/// rounded card with a custom drag handle, lifted above a floating bottom-nav.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showDragHandle = true,
  double bottomReserve = 16,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final inset = MediaQuery.of(ctx).viewPadding.bottom;
      final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;
      final reserve = viewInsets > 0 ? viewInsets : bottomReserve + inset;
      return Padding(
        padding: EdgeInsets.only(bottom: reserve, left: 12, right: 12),
        child: Material(
          color: theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDragHandle)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.bottomSheetTheme.dragHandleColor ??
                          theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Flexible(child: builder(ctx)),
            ],
          ),
        ),
      );
    },
  );
}
