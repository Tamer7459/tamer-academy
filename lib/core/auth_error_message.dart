import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show PlatformException;

/// رسالة خطأ واضحة لمستخدم التطبيق مع رمز تقني مختصر يساعد على التشخيص
/// (خصوصاً على أندرويد حيث تختلف الأخطاء عن نسخة الويب).
String authErrorMessage(Object error, String Function(String) translate) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return translate('invalidEmail');
      case 'missing-email':
        return translate('invalidEmail');
      case 'user-not-found':
      case 'user-disabled':
        return translate('userNotFound');
      case 'wrong-password':
      case 'invalid-credential':
        return translate('wrongPassword');
      case 'email-already-in-use':
        return translate('emailInUse');
      case 'weak-password':
        return translate('weakPassword');
      case 'network-request-failed':
        return translate('networkError');
      case 'too-many-requests':
        return translate('tooManyRequests');
      case 'operation-not-allowed':
        return translate('operationNotAllowed');
      case 'app-not-authorized':
      case 'app-not-authorized-for-this-project':
        return translate('appNotAuthorized');
      case 'requires-recent-login':
      case 'user-token-expired':
        return translate('sessionExpired');
    }
    return _withCode(translate, error.code);
  }
  if (error is PlatformException) {
    return _withCode(translate, error.code);
  }
  return _withCode(translate, error.runtimeType.toString());
}

String _withCode(String Function(String) translate, String code) {
  final clean = code.trim();
  if (clean.isEmpty) return translate('unknownError');
  return '${translate('unknownError')} (${translate('errorCode')}$clean)';
}
