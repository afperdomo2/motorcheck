import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../vehicles/models/vehicle.dart';
import '../vehicles/providers.dart';
import '../maintenance/providers.dart';
import '../maintenance/models/maintenance.dart';

final dashboardVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  final defaultVehicle = await ref.watch(defaultVehicleProvider.future);
  return defaultVehicle ?? (vehicles.isNotEmpty ? vehicles.first : null);
});

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final vehicle = await ref.watch(dashboardVehicleProvider.future);
  final maintenances = await ref.watch(maintenancesProvider.future);

  final allMaintenances = vehicle?.id == null
      ? <Maintenance>[]
      : maintenances.where((m) => m.vehicleId == vehicle!.id).toList();

  final totalMaintenances = allMaintenances.length;

  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;
  final currentMonthSpent = allMaintenances
      .where((m) => m.date.month == currentMonth && m.date.year == currentYear)
      .fold<double>(0, (sum, m) => sum + m.maintenanceCost + m.totalPartsCost);

  final currentMonthLabel = formatMonthYear(now);

  final sorted = List<Maintenance>.from(allMaintenances)
    ..sort((a, b) => b.date.compareTo(a.date));
  final recentMaintenances = sorted.take(5).toList();

  return DashboardSummary(
    totalVehicles: vehicle == null ? 0 : 1,
    totalMaintenances: totalMaintenances,
    recentMaintenances: recentMaintenances,
    currentMonthSpent: currentMonthSpent,
    currentMonthLabel: currentMonthLabel,
  );
});

class DashboardSummary {
  final int totalVehicles;
  final int totalMaintenances;
  final List<Maintenance> recentMaintenances;
  final double currentMonthSpent;
  final String currentMonthLabel;

  const DashboardSummary({
    required this.totalVehicles,
    required this.totalMaintenances,
    this.recentMaintenances = const [],
    required this.currentMonthSpent,
    required this.currentMonthLabel,
  });
}

class DashboardUpcomingEntry {
  final Vehicle vehicle;
  final UpcomingMaintenance item;

  const DashboardUpcomingEntry({required this.vehicle, required this.item});
}

/// Próximos mantenimientos por kilometraje del vehículo por defecto,
/// ordenados por severidad y distancia restante.
final dashboardUpcomingProvider = FutureProvider<List<DashboardUpcomingEntry>>((
  ref,
) async {
  final vehicle = await ref.watch(dashboardVehicleProvider.future);
  if (vehicle?.id == null) return [];

  final upcoming = await ref.watch(
    upcomingMaintenanceProvider(vehicle!.id!).future,
  );
  final entries = upcoming
      .where((item) => item.hasInterval)
      .map((item) => DashboardUpcomingEntry(vehicle: vehicle, item: item))
      .toList();

  entries.sort((a, b) {
    final severityA = a.item.isOverdue
        ? 0
        : (a.item.isWarning ? 1 : (a.item.hasRecord ? 2 : 3));
    final severityB = b.item.isOverdue
        ? 0
        : (b.item.isWarning ? 1 : (b.item.hasRecord ? 2 : 3));
    if (severityA != severityB) return severityA.compareTo(severityB);
    final daysA = a.item.remainingDays ?? 1 << 30;
    final daysB = b.item.remainingDays ?? 1 << 30;
    if (daysA != daysB) return daysA.compareTo(daysB);
    return (a.item.remainingKm ?? 1 << 30).compareTo(
      b.item.remainingKm ?? 1 << 30,
    );
  });

  return entries.take(4).toList();
});
