class Validators {
  const Validators._();

  static String? requiredText(String? value, {String field = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (requiredText(value, field: 'Email') != null) {
      return 'Email is required';
    }

    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!regex.hasMatch(value!.trim())) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? password(String? value) {
    if (requiredText(value, field: 'Password') != null) {
      return 'Password is required';
    }

    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (requiredText(value, field: 'Confirm password') != null) {
      return 'Confirm password is required';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }
}
