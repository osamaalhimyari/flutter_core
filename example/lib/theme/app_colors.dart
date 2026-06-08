import 'package:flutter/material.dart';
import 'package:my_core/my_core.dart';

/// Light — midnight navy primary with a warm cream canvas.
class LightColors implements AppColors {
  const LightColors();
  @override
  Color get primary => const Color(0xFF1E3A5F);
  @override
  Color get onPrimary => const Color(0xFFFAFAF7);
  @override
  Color get secondary => const Color(0xFF4A8B8B);
  @override
  Color get scaffoldBackground => const Color(0xFFFAFAF7);
  @override
  Color get surface => const Color(0xFFFFFFFF);
  @override
  Color get surfaceVariant => const Color(0xFFF3F2EC);
  @override
  Color get textPrimary => const Color(0xFF1A1F2E);
  @override
  Color get textSecondary => const Color(0xFF5A6478);
  @override
  Color get textHint => const Color(0xFF9AA2B1);
  @override
  Color get inputFill => const Color(0xFFF3F2EC);
  @override
  Color get border => const Color(0xFFE4E2D9);
  @override
  Color get success => const Color(0xFF2F8F6F);
  @override
  Color get info => const Color(0xFF3B6FA8);
  @override
  Color get warning => const Color(0xFFC68B3C);
  @override
  Color get error => const Color(0xFFC44545);
}

/// Dark — true black for OLED with a warmer, softer blue primary.
class DarkColors implements AppColors {
  const DarkColors();
  @override
  Color get primary => const Color(0xFF7BA7D9);
  @override
  Color get onPrimary => const Color(0xFF0A0F1A);
  @override
  Color get secondary => const Color(0xFF6FB3B3);
  @override
  Color get scaffoldBackground => const Color(0xFF000000);
  @override
  Color get surface => const Color(0xFF0E1015);
  @override
  Color get surfaceVariant => const Color(0xFF161922);
  @override
  Color get textPrimary => const Color(0xFFEDEEF0);
  @override
  Color get textSecondary => const Color(0xFF9098A8);
  @override
  Color get textHint => const Color(0xFF5C6373);
  @override
  Color get inputFill => const Color(0xFF161922);
  @override
  Color get border => const Color(0xFF252934);
  @override
  Color get success => const Color(0xFF4FB391);
  @override
  Color get info => const Color(0xFF7BA7D9);
  @override
  Color get warning => const Color(0xFFD9A85C);
  @override
  Color get error => const Color(0xFFE07070);
}
