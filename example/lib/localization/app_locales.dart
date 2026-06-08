import 'package:flutter_core/flutter_core.dart';

/// Your languages, defined the recommended way: extend [CoreLocale], one class
/// per language, each calling `super(...)`. Include the [CoreKeys] your UI and
/// validators render, plus your own app keys.

class EnUs extends CoreLocale {
  const EnUs()
    : super(
        languageCode: 'en',
        countryCode: 'US',
        displayName: 'English',
        fontFamily: 'Ubuntu',
        translations: const {
          // CoreKeys (rendered by core's validators / your widgets):
          CoreKeys.appName: 'Flutter Core Example',
          CoreKeys.confirm: 'Confirm',
          CoreKeys.cancel: 'Cancel',
          CoreKeys.dialogOk: 'OK',
          CoreKeys.dialogErrorTitle: 'Error',
          CoreKeys.dialogSuccessTitle: 'Success',
          CoreKeys.dialogNoticeTitle: 'Notice',
          CoreKeys.switchTheme: 'Switch theme',
          CoreKeys.switchLanguage: 'Switch language',
          CoreKeys.emailRequired: 'Email is required',
          CoreKeys.emailInvalid: 'Invalid email address',
          CoreKeys.passwordMinLength: 'Password must be at least 8 characters',
          CoreKeys.errorUnknown: 'Something went wrong. Please try again.',
          CoreKeys.imageTakePhoto: 'Take photo',
          CoreKeys.imageFromGallery: 'Choose from gallery',
          CoreKeys.imageTapToAdd: 'Tap to add',
          CoreKeys.changeImage: 'Change image',
          // Your own keys:
          'home_title': 'flutter_core demo',
          'home_greeting': 'Pure-Dart core, Flutter on top.',
        },
      );
}

class ArAr extends CoreLocale {
  const ArAr()
    : super(
        languageCode: 'ar',
        countryCode: 'AR',
        displayName: 'العربية',
        fontFamily: 'Cairo',
        translations: const {
          CoreKeys.appName: 'مثال فلاتر كور',
          CoreKeys.confirm: 'تأكيد',
          CoreKeys.cancel: 'إلغاء',
          CoreKeys.dialogOk: 'حسناً',
          CoreKeys.dialogErrorTitle: 'خطأ',
          CoreKeys.dialogSuccessTitle: 'تم',
          CoreKeys.dialogNoticeTitle: 'تنبيه',
          CoreKeys.switchTheme: 'تغيير المظهر',
          CoreKeys.switchLanguage: 'تغيير اللغة',
          CoreKeys.emailRequired: 'البريد الإلكتروني مطلوب',
          CoreKeys.emailInvalid: 'صيغة البريد الإلكتروني غير صحيحة',
          CoreKeys.passwordMinLength:
              'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
          CoreKeys.errorUnknown: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
          CoreKeys.imageTakePhoto: 'التقاط صورة',
          CoreKeys.imageFromGallery: 'اختيار من المعرض',
          CoreKeys.imageTapToAdd: 'اضغط للإضافة',
          CoreKeys.changeImage: 'تغيير الصورة',
          'home_title': 'عرض flutter_core',
          'home_greeting': 'نواة دارت خالصة، وفلاتر فوقها.',
        },
      );
}
