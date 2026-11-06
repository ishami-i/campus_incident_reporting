class FormValidator {
  static String? validateEmail(String? value, {bool isSignup = false}) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required. Please enter your email.';
    }
    final email = value.trim().toLowerCase();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Invalid email format. E.g., student@alustudent.com or staff@alueducation.com';
    }
    
    if (isSignup) {
      if (!email.endsWith('@alustudent.com')) {
        return 'Only students can sign up. Email must end with @alustudent.com';
      }
    } else {
      if (!email.endsWith('@alustudent.com') && !email.endsWith('@alueducation.com')) {
        return 'Access restricted: Please enter a student (@alustudent.com) or staff (@alueducation.com) email.';
      }
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required. Please enter your password.';
    }
    if (value.length < 6) {
      return 'Password too short: Must be at least 6 characters long.';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required. Please enter your name.';
    }
    if (value.trim().length < 2) {
      return 'Name too short: Full name must be at least 2 characters long.';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required. Please fill in this field.';
    }
    return null;
  }
}
