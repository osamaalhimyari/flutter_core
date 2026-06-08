import 'package:flutter_core/flutter_core.dart';

/// The app's own translation-key registry. Core no longer ships key strings —
/// they live here, in your project. Use with `context.tr(AppKeys.confirm)`.
class AppKeys {
  AppKeys._();

  // Generic UI
  static const appName = 'app_name';
  static const confirm = 'confirm';
  static const cancel = 'cancel';
  static const switchTheme = 'switch_theme';
  static const switchLanguage = 'switch_language';

  // Message dialog
  static const dialogOk = 'dialog_ok';
  static const dialogErrorTitle = 'dialog_error_title';
  static const dialogSuccessTitle = 'dialog_success_title';
  static const dialogNoticeTitle = 'dialog_notice_title';

  // Image picker field
  static const imageTakePhoto = 'image_take_photo';
  static const imageFromGallery = 'image_from_gallery';
  static const imageTapToAdd = 'image_tap_to_add';
  static const changeImage = 'change_image';

  // Network error keys (match DioApiClient's ServerException messages)
  static const errorTimeout = 'error_timeout';
  static const errorNoInternet = 'error_no_internet';
  static const errorUnauthorized = 'error_unauthorized';
  static const errorServer = 'error_server';
  static const errorRequestFailed = 'error_request_failed';
  static const errorUnknown = 'error_unknown';

  // Validation (targets of the ValidationError → key mapping below)
  static const fullNameRequired = 'full_name_required';
  static const fullNameMinLength = 'full_name_min_length';
  static const emailRequired = 'email_required';
  static const emailInvalid = 'email_invalid';
  static const passwordRequired = 'password_required';
  static const passwordMinLength = 'password_min_length';
  static const passwordNumberRequired = 'password_number_required';
  static const confirmPasswordRequired = 'confirm_password_required';
  static const passwordsDoNotMatch = 'passwords_do_not_match';
  static const agreeToTermsRequired = 'agree_to_terms_required';
  static const otpRequired = 'otp_required';
  static const otpIncomplete = 'otp_incomplete';
  static const otpNumbersOnly = 'otp_numbers_only';
}

/// Maps a core [ValidationError] to this app's translation key, so
/// `context.tr(Validators.validateEmail(x)!.key)` shows a localized message.
extension ValidationErrorKey on ValidationError {
  String get key => switch (this) {
    ValidationError.fullNameRequired => AppKeys.fullNameRequired,
    ValidationError.fullNameMinLength => AppKeys.fullNameMinLength,
    ValidationError.emailRequired => AppKeys.emailRequired,
    ValidationError.emailInvalid => AppKeys.emailInvalid,
    ValidationError.passwordRequired => AppKeys.passwordRequired,
    ValidationError.passwordMinLength => AppKeys.passwordMinLength,
    ValidationError.passwordNumberRequired => AppKeys.passwordNumberRequired,
    ValidationError.confirmPasswordRequired => AppKeys.confirmPasswordRequired,
    ValidationError.passwordsDoNotMatch => AppKeys.passwordsDoNotMatch,
    ValidationError.agreeToTermsRequired => AppKeys.agreeToTermsRequired,
    ValidationError.otpRequired => AppKeys.otpRequired,
    ValidationError.otpIncomplete => AppKeys.otpIncomplete,
    ValidationError.otpNumbersOnly => AppKeys.otpNumbersOnly,
  };
}
