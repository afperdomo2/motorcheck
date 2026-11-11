import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/app_preferences.dart';
import '../../core/utils/date_status.dart';
import '../../core/utils/formatters.dart';
import '../documents/models/vehicle_document.dart';
import '../documents/providers.dart';
import '../maintenance/providers.dart';
import '../restrictions/providers.dart';
import '../restrictions/restriction_status.dart';
import '../vehicles/providers.dart';
import 'health_score.dart';
import 'models/reminder.dart';

/// Bandeja única de vencimientos: mantenimiento por km/fecha, documentos y
/// pico y placa. Las notificaciones se programan a partir de esta lista.
final remindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  final settings = ref.watch(notificationSettingsProvider).valueOrNull;
  final leadDays = settings?.leadDays ?? 30;
  final reminders = <Reminder>[];

  for (final vehicle in vehicles) {
    final vehicleId = vehicle.id;
    if (vehicleId == null) continue;

    final upcoming = await ref.watch(
      upcomingMaintenanceProvider(vehicleId).future,
    );
    for (final item in upcoming) {
      if (!item.hasInterval || (!item.isOverdue && !item.isWarning)) {
        continue;
      }
      reminders.add(
        Reminder(
          id: 'maintenance-$vehicleId-${item.category.key}',
          kind: ReminderKind.maintenance,
          vehicleId: vehicleId,
          vehicleName: vehicle.name,
          title: item.category.name,
          subtitle: 'Mantenimiento',
          severity: item.isOverdue
              ? ReminderSeverity.overdue
              : ReminderSeverity.warning,
          route: '/vehicles/$vehicleId/upcoming',
          dueDate: item.nextServiceDate,
          remainingKm: item.remainingKm,
          remainingDays: item.remainingDays,
        ),
      );
    }

    final documents = await ref.watch(
      vehicleDocumentsProvider(vehicleId).future,
    );
    final seenDocumentTypes = <String>{};
    for (final document in documents) {
      // Latest-wins: el primero por tipo (orden DESC) es el vigente.
      if (!seenDocumentTypes.add(document.type)) continue;
      final reminder = _documentReminder(
        document,
        vehicleId: vehicleId,
        vehicleName: vehicle.name,
        route: '/vehicles/$vehicleId/documents',
        leadDays: leadDays,
      );
      if (reminder != null) reminders.add(reminder);
    }
  }

  final globalDocuments = await ref.watch(globalDocumentsProvider.future);
  final seenGlobalTypes = <String>{};
  for (final document in globalDocuments) {
    if (!seenGlobalTypes.add(document.type)) continue;
    final reminder = _documentReminder(
      document,
      vehicleId: 0,
      vehicleName: 'Conductor',
      route: '/settings/documents',
      leadDays: leadDays,
    );
    if (reminder != null) reminders.add(reminder);
  }

  final restrictions = await ref.watch(restrictionStatusesProvider.future);
  for (final entry in restrictions) {
    final vehicleId = entry.vehicle.id;
    if (vehicleId == null) continue;
    if (!_isRestrictionSoon(entry.status)) continue;
    reminders.add(
      Reminder(
        id: 'restriction-$vehicleId',
        kind: ReminderKind.restriction,
        vehicleId: vehicleId,
        vehicleName: entry.vehicle.name,
        title: 'Pico y placa',
        subtitle: entry.status.todayLabel,
        severity: ReminderSeverity.info,
        route: '/vehicles/$vehicleId/restriction',
        dueDate: entry.status.nextRestrictionDate,
        remainingDays: entry.status.nextRestrictionDate != null
            ? DateStatus.daysUntil(entry.status.nextRestrictionDate!)
            : null,
      ),
    );
  }

  reminders.sort(_compareReminders);
  return reminders;
});

Reminder? _documentReminder(
  VehicleDocument document, {
  required int vehicleId,
  required String vehicleName,
  required String route,
  required int leadDays,
}) {
  final days = DateStatus.daysUntil(document.expiresAt);
  if (days > leadDays) return null;
  final type = documentTypeFor(document.type);
  return Reminder(
    id: 'document-${document.id ?? '${document.type}-$vehicleId'}',
    kind: ReminderKind.document,
    vehicleId: vehicleId,
    vehicleName: vehicleName,
    title: document.name?.isNotEmpty == true ? document.name! : type.label,
    subtitle: type.label,
    severity: days < 0 ? ReminderSeverity.overdue : ReminderSeverity.warning,
    route: route,
    dueDate: document.expiresAt,
    remainingDays: days,
  );
}

bool _isRestrictionSoon(RestrictionStatus status) {
  if (status.restrictedToday) return true;
  final next = status.nextRestrictionDate;
  if (next == null) return false;
  return DateStatus.daysUntil(next) <= 1;
}

int _severityRank(ReminderSeverity severity) => switch (severity) {
  ReminderSeverity.overdue => 0,
  ReminderSeverity.warning => 1,
  ReminderSeverity.info => 2,
};

int _compareReminders(Reminder a, Reminder b) {
  final bySeverity = _severityRank(
    a.severity,
  ).compareTo(_severityRank(b.severity));
  if (bySeverity != 0) return bySeverity;
  final daysA = a.remainingDays ?? 1 << 30;
  final daysB = b.remainingDays ?? 1 << 30;
  if (daysA != daysB) return daysA.compareTo(daysB);
  final kmA = a.remainingKm ?? 1 << 30;
  final kmB = b.remainingKm ?? 1 << 30;
  return kmA.compareTo(kmB);
}

final vehicleRemindersProvider = FutureProvider.family<List<Reminder>, int>((
  ref,
  vehicleId,
) async {
  final reminders = await ref.watch(remindersProvider.future);
  return reminders.where((r) => r.vehicleId == vehicleId).toList();
});

final vehicleHealthProvider = FutureProvider.family<HealthScore, int>((
  ref,
  vehicleId,
) async {
  final reminders = await ref.watch(vehicleRemindersProvider(vehicleId).future);
  final stats = await ref.watch(mileageStatsProvider(vehicleId).future);

  final overdueMaintenances = reminders
      .where(
        (r) =>
            r.kind == ReminderKind.maintenance &&
            r.severity == ReminderSeverity.overdue,
      )
      .length;
  final warningMaintenances = reminders
      .where(
        (r) =>
            r.kind == ReminderKind.maintenance &&
            r.severity == ReminderSeverity.warning,
      )
      .length;
  final expiredDocuments = reminders
      .where(
        (r) =>
            r.kind == ReminderKind.document &&
            r.severity == ReminderSeverity.overdue,
      )
      .length;
  final expiringDocuments = reminders
      .where(
        (r) =>
            r.kind == ReminderKind.document &&
            r.severity == ReminderSeverity.warning,
      )
      .length;

  final hasData = reminders.isNotEmpty || stats.lastReadingDate != null;
  if (!hasData) {
    return const HealthScore(
      value: 100,
      label: 'Sin datos',
      reasons: ['Registra el kilometraje para calcular la salud'],
      hasData: false,
    );
  }

  final score = scoreFrom(
    overdueMaintenances: overdueMaintenances,
    warningMaintenances: warningMaintenances,
    expiredDocuments: expiredDocuments,
    expiringDocuments: expiringDocuments,
    daysSinceMileageUpdate: stats.daysSinceLastReading,
  );

  final reasons = <String>[];
  if (overdueMaintenances > 0) {
    reasons.add(
      overdueMaintenances == 1
          ? '1 mantenimiento vencido'
          : '$overdueMaintenances mantenimientos vencidos',
    );
  }
  if (warningMaintenances > 0) {
    reasons.add(
      warningMaintenances == 1
          ? '1 mantenimiento próximo'
          : '$warningMaintenances mantenimientos próximos',
    );
  }
  if (expiredDocuments > 0) {
    reasons.add(
      expiredDocuments == 1
          ? '1 documento vencido'
          : '$expiredDocuments documentos vencidos',
    );
  }
  if (expiringDocuments > 0) {
    reasons.add(
      expiringDocuments == 1
          ? '1 documento por vencer'
          : '$expiringDocuments documentos por vencer',
    );
  }
  if (stats.daysSinceLastReading != null && stats.daysSinceLastReading! > 60) {
    reasons.add(
      'Kilometraje sin actualizar hace ${stats.daysSinceLastReading} días',
    );
  }
  if (reasons.isEmpty) {
    reasons.add('Todo al día');
  }

  return HealthScore(value: score.value, label: score.label, reasons: reasons);
});

String formatReminderDate(DateTime? date) {
  if (date == null) return '';
  return formatDisplayDate(date);
}
