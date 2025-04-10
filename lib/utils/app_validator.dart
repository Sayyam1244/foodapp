class AppValidator {
  // Validates if the input is not null or empty. Returns an error message if invalid.
  static String? emptyCheck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field required';
    }
    return null;
  }

  // Validates if the input is a valid email address. Returns an error message if invalid.
  static String? emailCheck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // Validates if the input is a valid phone number. Returns an error message if invalid.
  static String? phoneCheck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Validates if the input is a valid password. Returns an error message if invalid.
  // Password must be at least 8 characters long and contain at least one letter and one number.
  static String? passwordCheck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }
    return null;
  }

  // Validates if the input is a valid number. Returns an error message if invalid.
  static String? numberCheck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    final numberRegex = RegExp(r'^\d+(\.\d+)?$');
    if (!numberRegex.hasMatch(value)) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
