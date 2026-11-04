class FormValidator {
  static String? validateEmail(String? value, {bool isSignup = false}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an email address';
    }
    final email = value.trim().toLowerCase();
    
    if (isSignup) {
      if (!email.endsWith('@alustudent.com')) {
        return 'Only students can sign up. Email must end with @alustudent.com';
      }
    } else {
      if (!email.endsWith('@alustudent.com') && !email.endsWith('@alueducation.com')) {
        return 'Enter a valid student (@alustudent.com) or staff (@alueducation.com) email';
      }
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}
