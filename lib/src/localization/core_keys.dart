/// Translation keys for the strings **core itself** renders — validators,
/// the app message dialog, the image-picker field, network error messages,
/// and a handful of common UI labels.
///
/// These are key *names* only — core ships no values. Provide the translations
/// for the keys you use in your `CoreLocale.translations` (an untranslated key
/// renders verbatim). Your app's own keys live in a separate class.
///
/// Use via `context.tr(CoreKeys.confirm)`.
class CoreKeys {
  CoreKeys._();

  // ---- Generic UI ------------------------------------------------------
  static const appName = 'app_name';
  static const logout = 'logout';
  static const home = 'home';
  static const settings = 'settings';
  static const currentTheme = 'current_theme';
  static const currentLanguage = 'current_language';
  static const dark = 'dark';
  static const light = 'light';
  static const switchTheme = 'switch_theme';
  static const switchLanguage = 'switch_language';
  static const confirm = 'confirm';
  static const cancel = 'cancel';
  static const yes = 'yes';
  static const or = 'or';
  static const retry = 'retry';
  static const required = 'required';

  // ---- Message dialog (see shared/app_dialog.dart) ---------------------
  static const dialogOk = 'dialog_ok';
  static const dialogErrorTitle = 'dialog_error_title';
  static const dialogSuccessTitle = 'dialog_success_title';
  static const dialogNoticeTitle = 'dialog_notice_title';

  // ---- Validation (see utils/validators.dart) --------------------------
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

  // ---- Network / server error keys (produced by DioApiClient) ----------
  static const errorTimeout = 'error_timeout';
  static const errorNoInternet = 'error_no_internet';
  static const errorUnauthorized = 'error_unauthorized';
  static const errorServer = 'error_server';
  static const errorRequestFailed = 'error_request_failed';
  static const errorInvalidResponse = 'error_invalid_response';
  static const errorUnknown = 'error_unknown';

  // ---- Image picker field (see shared/image_picker_field.dart) ----------
  static const imageTakePhoto = 'image_take_photo';
  static const imageFromGallery = 'image_from_gallery';
  static const imageTapToAdd = 'image_tap_to_add';
  static const changeImage = 'change_image';
}
