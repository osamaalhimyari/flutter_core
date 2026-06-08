/// Translation keys the **backend** may return in the `message` field of an
/// unsuccessful response (`{ "success": false, "message": "<key>" }`).
///
/// Each constant matches a key in the translations (core base or app-supplied
/// via `CoreLocale.translations`). When the backend adds a new error key,
/// mirror it here and add it to your translations. Unknown keys fall through
/// and are rendered verbatim — that's the signal that a translation is missing.
class ServerErrorKeys {
  ServerErrorKeys._();

  // ---- Auth: login ------------------------------------------------------
  static const invalidCredentials = 'invalid_credentials';

  // ---- Auth: signup / registration -------------------------------------
  static const emailAlreadyExists = 'email_already_exists';
  static const registrationFailed = 'registration_failed';

  // ---- Auth: OTP -------------------------------------------------------
  static const invalidOtp = 'invalid_otp';
  static const accountNotFound = 'account_not_found';
  static const deviceNotRegistered = 'device_not_registered';

  // ---- Auth: device registration ---------------------------------------
  static const deviceRegistrationFailed = 'device_registration_failed';

  // ---- Auth: resend OTP ------------------------------------------------
  static const resendOtpFailed = 'resend_otp_failed';

  // ---- Auth: forgot password -------------------------------------------
  static const forgotPasswordFailed = 'forgot_password_failed';

  // ---- Auth: reset password --------------------------------------------
  static const passwordResetFailed = 'password_reset_failed';
  static const resetPasswordVerificationFailed =
      'reset_password_verification_failed';

  // ---- Terms -----------------------------------------------------------
  static const termsLoadFailed = 'terms_load_failed';

  // ---- Approval: document / license / vehicle upload -------------------
  static const imageBackRequired = 'image_back_required';
  static const uploadDocumentsFirst = 'upload_documents_first';
}
