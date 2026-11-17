import 'package:intl/intl.dart';

import 'date_status.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');
final _displayDateFormat = DateFormat('d MMMM yyyy', 'es_CO');
final _shortDateFormat = DateFormat('dd/MM/yyyy', 'es_CO');
final _currencyFormat = NumberFormat.currency(
  locale: 'es_CO',
  symbol: '\$',
  decimalDigits: 0,
  customPattern: '\u00A4 #,##0',
);
final _numberFormat = NumberFormat.decimalPattern('es_CO');
final _dateTimeFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

String formatDate(DateTime date) => _dateFormat.format(date);

String formatDisplayDate(DateTime date) => _displayDateFormat.format(date);

String formatShortDate(DateTime date) => _shortDateFormat.format(date);

String formatMonthYear(DateTime date) =>
    DateFormat('MMMM', 'es_CO').format(date);

String formatMonthYearLong(DateTime date) {
  final s = DateFormat('MMMM yyyy', 'es_CO').format(date);
  return s[0].toUpperCase() + s.substring(1);
}

String formatWeekdayDay(DateTime date) {
  final s = DateFormat('EEEE d', 'es_CO').format(date);
  return s[0].toUpperCase() + s.substring(1);
}

String formatCurrency(double amount) => _currencyFormat.format(amount);

/// Monto abreviado para tarjetas pequeñas: `$ 620k`, `$ 1,2M`, `$ 13,6M`.
String formatCompactCurrency(double amount) {
  final abs = amount.abs();
  if (abs >= 1000000) {
    final millions = (amount / 1000000).toStringAsFixed(1).replaceAll('.', ',');
    final label = millions.endsWith(',0')
        ? millions.substring(0, millions.length - 2)
        : millions;
    return '\$ ${label}M';
  }
  if (abs >= 1000) {
    final thousands = (amount / 1000).round();
    return '\$ ${_numberFormat.format(thousands)}k';
  }
  return formatCurrency(amount);
}

String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);

DateTime parseDateTime(String dateTime) => _dateTimeFormat.parse(dateTime);

DateTime parseDate(String date) => _dateFormat.parse(date);

String formatMileage(int? mileage) {
  if (mileage == null) return '-';
  return '${_numberFormat.format(mileage)} km';
}

String formatDaysRemaining(DateTime? date) {
  if (date == null) return '';
  return dateStatus(date).longLabel;
}
