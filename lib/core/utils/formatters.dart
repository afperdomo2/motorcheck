import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');
final _displayDateFormat = DateFormat('d MMMM yyyy', 'es');
final _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
final _dateTimeFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

String formatDate(DateTime date) => _dateFormat.format(date);

String formatDisplayDate(DateTime date) => _displayDateFormat.format(date);

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

Color expiryColor(DateTime? date) {
  if (date == null) return Colors.grey;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;
  if (diff < 0) return Colors.red;
  if (diff <= 30) return Colors.orange;
  return Colors.green;
}
