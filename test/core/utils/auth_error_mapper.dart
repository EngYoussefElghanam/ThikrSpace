import 'package:flutter_test/flutter_test.dart';
import 'package:thikrspace_beta/core/utils/auth_error_mapper.dart'; // Adjust import if needed

void main() {
  group('AuthErrorMapper', () {
    test('maps incorrect credentials to friendly message', () {
      final result1 =
          AuthErrorMapper.getFriendlyMessage('firebase_auth/wrong-password');
      final result2 = AuthErrorMapper.getFriendlyMessage('invalid-credential');

      expect(result1, 'Incorrect email or password. Please try again.');
      expect(result2, 'Incorrect email or password. Please try again.');
    });

    test('maps account-exists-with-different-credential accurately', () {
      final result = AuthErrorMapper.getFriendlyMessage(
          'account-exists-with-different-credential');
      expect(result,
          'An account with this email already exists. Please sign in using your password.');
    });

    test('maps Google cancellation safely', () {
      final result = AuthErrorMapper.getFriendlyMessage('popup-closed');
      expect(result, 'Sign in was cancelled.');
    });

    test('returns safe fallback message for unknown errors', () {
      final result =
          AuthErrorMapper.getFriendlyMessage('some-random-server-error-123');
      expect(result,
          'Authentication failed. Please check your credentials and try again.');
    });
  });
}
