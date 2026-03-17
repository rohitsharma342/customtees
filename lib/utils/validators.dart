class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateZipCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Zip code is required';
    }
    if (value.length < 4 || value.length > 10) {
      return 'Please enter a valid zip code';
    }
    return null;
  }

  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }
    final cleanValue = value.replaceAll(RegExp(r'\s'), '');
    if (cleanValue.length != 16 || !RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'Please enter a valid 16-digit card number';
    }
    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV is required';
    }
    if (value.length < 3 || value.length > 4 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Please enter a valid CVV';
    }
    return null;
  }

  static String? validateExpiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry date is required';
    }
    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!expiryRegex.hasMatch(value)) {
      return 'Please enter a valid expiry date (MM/YY)';
    }
    return null;
  }

  static String? validateSearchInput(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > 100) {
      return 'Search query is too long';
    }
    if (RegExp(r'[<>{}\[\]]').hasMatch(value)) {
      return 'Invalid characters in search';
    }
    return null;
  }

  static String? validateDesignText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Text cannot be empty';
    }
    if (value.length > 50) {
      return 'Text must be 50 characters or less';
    }
    return null;
  }
}