import 'package:example/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:my_core/my_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('core AppTheme builds a ThemeData from the app AppColors', (
    tester,
  ) async {
    final theme = AppTheme.build(const LightColors(), 'Ubuntu', false);

    expect(theme.colorScheme.primary, const LightColors().primary);
    // Custom ColorsModel extension resolves.
    expect(theme.colorsModel.success, const LightColors().success);

    await tester.pumpWidget(
      MaterialApp(theme: theme, home: const Scaffold(body: Text('ok'))),
    );
    expect(find.text('ok'), findsOneWidget);
  });
}
