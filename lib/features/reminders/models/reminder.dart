enum ReminderKind { maintenance, document, component, restriction }

enum ReminderSeverity { overdue, warning, info }

class Reminder {
  const Reminder({
    required this.id,
    required this.kind,
    required this.vehicleId,
    required this.vehicleName,
    required this.title,
    required this.subtitle,
    required this.severity,
    required this.route,
    this.dueDate,
    this.remainingKm,
    this.remainingDays,
  });

  final String id;
  final ReminderKind kind;
  final int vehicleId;
  final String vehicleName;
  final String title;
  final String subtitle;
  final ReminderSeverity severity;
  final String route;
  final DateTime? dueDate;
  final int? remainingKm;
  final int? remainingDays;

  String get statusLabel {
    if (severity == ReminderSeverity.overdue) {
      if (remainingDays != null && remainingDays! < 0) {
        return 'Vencido hace ${-remainingDays!} días';
      }
      if (remainingKm != null && remainingKm! <= 0) {
        return 'Vencido hace ${-remainingKm!} km';
      }
      return 'Vencido';
    }

    if (remainingDays != null) {
      return remainingDays == 0 ? 'Vence hoy' : 'Vence en $remainingDays días';
    }
    if (remainingKm != null) {
      return 'En $remainingKm km';
    }
    return subtitle;
  }
}
