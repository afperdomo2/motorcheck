/// Nivel de vencimiento de una fecha (SOAT, RTM, etc.).
enum ExpiryLevel { ok, warning, danger }

/// Estado calculado de una fecha de vencimiento.
class DateStatus {
  const DateStatus({required this.days, required this.level});

  /// Días restantes. Negativo cuando la fecha ya venció.
  final int days;

  final ExpiryLevel level;

  bool get isExpired => days < 0;

  /// Etiqueta compacta para chips: "Vence en 12 d".
  String get shortLabel {
    if (days < 0) return 'Vencido hace ${-days} d';
    if (days == 0) return 'Vence hoy';
    return 'Vence en $days d';
  }

  /// Etiqueta larga para textos de detalle: "Vence en 12 días".
  String get longLabel {
    if (days < 0) return 'Vencido hace ${-days} días';
    if (days == 0) return 'Vence hoy';
    return 'Vence en $days días';
  }

  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }
}

/// Calcula el estado de una fecha usando una ventana de aviso de 30 días.
DateStatus dateStatus(DateTime date, {int warningDays = 30}) {
  final days = DateStatus.daysUntil(date);
  final level = days < 0
      ? ExpiryLevel.danger
      : days <= warningDays
      ? ExpiryLevel.warning
      : ExpiryLevel.ok;
  return DateStatus(days: days, level: level);
}
