import 'package:intl/intl.dart';

String formatPrice(double price) {
  final text =
      NumberFormat('#,##0', 'en_US').format(price).replaceAll(',', ' ');
  return '$text so\'m';
}