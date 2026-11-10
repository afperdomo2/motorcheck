import 'package:intl/intl.dart';

import 'models/vehicle_restriction.dart';

class RestrictionStatus {
  const RestrictionStatus({
    required this.configured,
    required this.restrictedToday,
    required this.restrictedNow,
    required this.todayLabel,
    required this.nextLabel,
    this.nextRestrictionDate,
  });

  final bool configured;
  final bool restrictedToday;
  final bool restrictedNow;
  final String todayLabel;
  final String nextLabel;
  final DateTime? nextRestrictionDate;
}

RestrictionStatus evaluateRestriction(
  VehicleRestriction? restriction,
  DateTime now,
) {
  if (restriction == null || !restriction.enabled) {
    return const RestrictionStatus(
      configured: false,
      restrictedToday: false,
      restrictedNow: false,
      todayLabel: 'Sin configurar',
      nextLabel: 'Configura tus días de pico y placa',
    );
  }

  if (restriction.exempt) {
    return const RestrictionStatus(
      configured: true,
      restrictedToday: false,
      restrictedNow: false,
      todayLabel: 'Exento de pico y placa',
      nextLabel: 'Sin restricciones',
    );
  }

  if (restriction.days.isEmpty) {
    return const RestrictionStatus(
      configured: true,
      restrictedToday: false,
      restrictedNow: false,
      todayLabel: 'Sin días configurados',
      nextLabel: 'Selecciona los días de restricción',
    );
  }

  final start = _parseMinutes(restriction.startTime);
  final end = _parseMinutes(restriction.endTime);
  final nowMinutes = now.hour * 60 + now.minute;
  final restrictedToday = restriction.days.contains(now.weekday);
  final restrictedNow =
      restrictedToday && nowMinutes >= start && nowMinutes < end;

  final next = _nextRestrictionDate(restriction, now, end, nowMinutes);
  final timeRange = '${restriction.startTime}–${restriction.endTime}';

  return RestrictionStatus(
    configured: true,
    restrictedToday: restrictedToday,
    restrictedNow: restrictedNow,
    todayLabel: restrictedToday
        ? 'Hoy no circulas · $timeRange'
        : 'Hoy circulas',
    nextLabel: next == null
        ? 'Sin próxima restricción'
        : '${_formatDate(next)} · $timeRange',
    nextRestrictionDate: next,
  );
}

DateTime? _nextRestrictionDate(
  VehicleRestriction restriction,
  DateTime now,
  int endMinutes,
  int nowMinutes,
) {
  if (restriction.days.contains(now.weekday) && nowMinutes < endMinutes) {
    return DateTime(now.year, now.month, now.day);
  }

  for (var offset = 1; offset <= 14; offset++) {
    final candidate = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: offset));
    if (restriction.days.contains(candidate.weekday)) {
      return candidate;
    }
  }
  return null;
}

int _parseMinutes(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return 0;
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  return hour * 60 + minute;
}

String _formatDate(DateTime date) {
  final text = DateFormat('EEEE d MMM', 'es_CO').format(date);
  return text[0].toUpperCase() + text.substring(1);
}
