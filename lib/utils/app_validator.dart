class AppValidator {
  static String? emptyCheck(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }
}
