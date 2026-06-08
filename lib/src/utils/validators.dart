import '../localization/core_keys.dart';

/// Pure validation functions. Return `null` if valid, otherwise a
/// translation KEY (not a translated string) — the widget translates it.
/// This keeps validators testable and locale-independent.
class Validators {
  Validators._();

  static String? validateFullName(String value) {
    if (value.trim().isEmpty) return CoreKeys.fullNameRequired;
    if (value.trim().length < 3) return CoreKeys.fullNameMinLength;
    return null;
  }

  static String? validateEmail(String value) {
    if (value.trim().isEmpty) return CoreKeys.emailRequired;
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) return CoreKeys.emailInvalid;
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return CoreKeys.passwordRequired;
    if (value.length < 8) return CoreKeys.passwordMinLength;
    if (!RegExp(r'\d').hasMatch(value)) {
      return CoreKeys.passwordNumberRequired;
    }
    return null;
  }

  static String? validateConfirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return CoreKeys.confirmPasswordRequired;
    if (password != confirm) return CoreKeys.passwordsDoNotMatch;
    return null;
  }

  static String? validateTerms(bool agreed) {
    if (!agreed) return CoreKeys.agreeToTermsRequired;
    return null;
  }

  static String? validateOtp(String value) {
    if (value.isEmpty) return CoreKeys.otpRequired;
    if (value.length < 6) return CoreKeys.otpIncomplete;
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return CoreKeys.otpNumbersOnly;
    }
    return null;
  }
}
