/// Input validation helpers.
class Validators {
  /// Validate an email address.
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  /// Validate a password (min 6 chars).
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Validate a username (3-20 chars, alphanumeric + underscores).
  static String? username(String? value) {
    if (value == null || value.isEmpty) return 'Username is required';
    if (value.length < 3) return 'Username must be at least 3 characters';
    if (value.length > 20) return 'Username must be 20 characters or less';
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Only letters, numbers, and underscores allowed';
    }
    return null;
  }

  /// Validate that a field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  /// Validate a match score format (e.g., "21-17, 19-21, 21-15").
  static String? score(String? value) {
    if (value == null || value.isEmpty) return 'Score is required';
    // Basic validation — ensure it contains at least one dash
    if (!value.contains('-')) return 'Enter score in format: 21-17, 19-21';
    return null;
  }
}
