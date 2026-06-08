/// Semantic validation outcomes returned by [Validators].
///
/// Core ships **no** translation-key strings — the app maps each
/// [ValidationError] to its own key/message (see `example/`). This keeps the
/// validation logic in the package while the wording stays in your project.
enum ValidationError {
  fullNameRequired,
  fullNameMinLength,
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordMinLength,
  passwordNumberRequired,
  confirmPasswordRequired,
  passwordsDoNotMatch,
  agreeToTermsRequired,
  otpRequired,
  otpIncomplete,
  otpNumbersOnly,
}

/// Pure validation functions. Return `null` if valid, otherwise a semantic
/// [ValidationError] — the widget maps it to a translated message. Keeps
/// validators testable and locale-/key-independent.
class Validators {
  Validators._();

  static ValidationError? validateFullName(String value) {
    if (value.trim().isEmpty) return ValidationError.fullNameRequired;
    if (value.trim().length < 3) return ValidationError.fullNameMinLength;
    return null;
  }

  static ValidationError? validateEmail(String value) {
    if (value.trim().isEmpty) return ValidationError.emailRequired;
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) return ValidationError.emailInvalid;
    return null;
  }

  static ValidationError? validatePassword(String value) {
    if (value.isEmpty) return ValidationError.passwordRequired;
    if (value.length < 8) return ValidationError.passwordMinLength;
    if (!RegExp(r'\d').hasMatch(value)) {
      return ValidationError.passwordNumberRequired;
    }
    return null;
  }

  static ValidationError? validateConfirmPassword(
    String password,
    String confirm,
  ) {
    if (confirm.isEmpty) return ValidationError.confirmPasswordRequired;
    if (password != confirm) return ValidationError.passwordsDoNotMatch;
    return null;
  }

  static ValidationError? validateTerms(bool agreed) {
    if (!agreed) return ValidationError.agreeToTermsRequired;
    return null;
  }

  static ValidationError? validateOtp(String value) {
    if (value.isEmpty) return ValidationError.otpRequired;
    if (value.length < 6) return ValidationError.otpIncomplete;
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return ValidationError.otpNumbersOnly;
    }
    return null;
  }
}
