import 'package:intl/intl.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');
final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
final _dateTimeFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

String formatDate(DateTime date) => _dateFormat.format(date);

String formatCurrency(double amount) => _currencyFormat.format(amount);

String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);

DateTime parseDateTime(String dateTime) => _dateTimeFormat.parse(dateTime);

DateTime parseDate(String date) => _dateFormat.parse(date);

String formatMileage(int? mileage) {
  if (mileage == null) return '-';
  if (mileage >= 1000) {
    return '${NumberFormat('#,###').format(mileage)} km';
  }
  return '$mileage km';
}
