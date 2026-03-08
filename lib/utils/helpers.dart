import 'package:intl/intl.dart';

class AppHelpers {
  /// Format date to readable format
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format datetime with time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  /// Format price with rupee symbol
  static String formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }

  /// Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Check if date is in past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Truncate string to length with ellipsis
  static String truncate(String text, int length) {
    if (text.length > length) {
      return '${text.substring(0, length)}...';
    }
    return text;
  }

  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Generate random string
  static String randomString(int length) {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
    final random = StringBuffer();
    for (int i = 0; i < length; i++) {
      random.write(chars[DateTime.now().millisecond % chars.length]);
    }
    return random.toString();
  }
}
