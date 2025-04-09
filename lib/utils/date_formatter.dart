import 'package:intl/intl.dart';

/// Extension on DateTime to add a custom date formatting method.
extension DateFormater on DateTime {
  /// Formats the DateTime object to 'dd MMM, yyyy' format (e.g., 01 Jan, 2023).
  String get formattedDate {
    return DateFormat('dd MMM, yyyy').format(this);
  }
}
