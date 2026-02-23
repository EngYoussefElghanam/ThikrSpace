class AuthErrorMapper {
  static String getFriendlyMessage(String rawError) {
    final msg = rawError.toLowerCase();

    // --- 1. Sign In Errors ---
    if (msg.contains('invalid-credential') ||
        msg.contains('wrong-password') ||
        msg.contains('user-not-found')) {
      return 'Incorrect email or password. Please try again.';
    }

    // --- 2. Sign Up Errors ---
    else if (msg.contains('weak-password')) {
      return 'Your password is too weak. Please use a stronger one.';
    } else if (msg.contains('email-already-in-use')) {
      return 'An account already exists for this email.';
    }

    // --- 3. General Validation & Network ---
    else if (msg.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (msg.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (msg.contains('network-request-failed')) {
      return 'No internet connection. Please check your network.';
    }

    // --- 4. Edge Cases ---
    else if (msg.contains('account-exists-with-different-credential')) {
      return 'An account with this email already exists. Please sign in using your password.';
    } else if (msg.contains('cancel') || msg.contains('popup-closed')) {
      return 'Sign in was cancelled.';
    }

    // --- 5. Fallback ---
    return 'Authentication failed. Please check your credentials and try again.';
  }
}
