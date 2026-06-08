import 'package:flutter_core/flutter_core.dart';

import 'app_keys.dart';

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
          AppKeys.appName: 'Flutter Core Example',
          AppKeys.confirm: 'Confirm',
          AppKeys.cancel: 'Cancel',
          AppKeys.dialogOk: 'OK',
          AppKeys.dialogErrorTitle: 'Error',
          AppKeys.dialogSuccessTitle: 'Success',
          AppKeys.dialogNoticeTitle: 'Notice',
          AppKeys.switchTheme: 'Switch theme',
          AppKeys.switchLanguage: 'Switch language',
          AppKeys.emailRequired: 'Email is required',
          AppKeys.emailInvalid: 'Invalid email address',
          AppKeys.passwordMinLength: 'Password must be at least 8 characters',
          AppKeys.errorUnknown: 'Something went wrong. Please try again.',
          AppKeys.imageTakePhoto: 'Take photo',
          AppKeys.imageFromGallery: 'Choose from gallery',
          AppKeys.imageTapToAdd: 'Tap to add',
          AppKeys.changeImage: 'Change image',
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
          AppKeys.appName: 'مثال فلاتر كور',
          AppKeys.confirm: 'تأكيد',
          AppKeys.cancel: 'إلغاء',
          AppKeys.dialogOk: 'حسناً',
          AppKeys.dialogErrorTitle: 'خطأ',
          AppKeys.dialogSuccessTitle: 'تم',
          AppKeys.dialogNoticeTitle: 'تنبيه',
          AppKeys.switchTheme: 'تغيير المظهر',
          AppKeys.switchLanguage: 'تغيير اللغة',
          AppKeys.emailRequired: 'البريد الإلكتروني مطلوب',
          AppKeys.emailInvalid: 'صيغة البريد الإلكتروني غير صحيحة',
          AppKeys.passwordMinLength:
              'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
          AppKeys.errorUnknown: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
          AppKeys.imageTakePhoto: 'التقاط صورة',
          AppKeys.imageFromGallery: 'اختيار من المعرض',
          AppKeys.imageTapToAdd: 'اضغط للإضافة',
          AppKeys.changeImage: 'تغيير الصورة',
          'home_title': 'عرض flutter_core',
          'home_greeting': 'نواة دارت خالصة، وفلاتر فوقها.',
        },
      );
}
