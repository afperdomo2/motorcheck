import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../vehicles/models/vehicle.dart';
import '../vehicles/providers.dart';
import '../maintenance/providers.dart';
import '../maintenance/models/maintenance.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final vehicles = await ref.read(vehicleRepositoryProvider).getAll();
  final repository = ref.read(maintenanceRepositoryProvider);

  final allMaintenances = vehicles.isNotEmpty
      ? await repository.getAll()
      : <Maintenance>[];

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
    totalVehicles: vehicles.length,
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

/// Próximos mantenimientos por kilometraje de todos los vehículos,
/// ordenados por severidad y distancia restante.
final dashboardUpcomingProvider = FutureProvider<List<DashboardUpcomingEntry>>((
  ref,
) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  final entries = <DashboardUpcomingEntry>[];

  for (final vehicle in vehicles) {
    final id = vehicle.id;
    if (id == null) continue;
    final upcoming = await ref.watch(upcomingMaintenanceProvider(id).future);
    for (final item in upcoming) {
      if (item.category.intervalKm == null) continue;
      entries.add(DashboardUpcomingEntry(vehicle: vehicle, item: item));
    }
  }

  entries.sort((a, b) {
    final severityA = a.item.isOverdue ? 0 : (a.item.isWarning ? 1 : 2);
    final severityB = b.item.isOverdue ? 0 : (b.item.isWarning ? 1 : 2);
    if (severityA != severityB) return severityA.compareTo(severityB);
    return (a.item.remainingKm ?? 1 << 30).compareTo(
      b.item.remainingKm ?? 1 << 30,
    );
  });

  return entries.take(4).toList();
});
