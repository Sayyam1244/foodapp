import 'package:intl/intl.dart';

extension DateFormater on DateTime {
  String get formattedDate {
    return DateFormat('dd MMM, yyyy').format(this);
  }
}
