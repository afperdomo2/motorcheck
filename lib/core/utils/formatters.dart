import 'package:intl/intl.dart';

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

String formatDateTime(DateTime dateTime) => _dateTimeFormat.format(dateTime);

DateTime parseDateTime(String dateTime) => _dateTimeFormat.parse(dateTime);

DateTime parseDate(String date) => _dateFormat.parse(date);

String formatMileage(int? mileage) {
  if (mileage == null) return '-';
  return '${_numberFormat.format(mileage)} km';
}

String formatDaysRemaining(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;
  if (diff > 0) return 'Vence en $diff días';
  if (diff == 0) return 'Vence hoy';
  return 'Vencido hace ${-diff} días';
}
