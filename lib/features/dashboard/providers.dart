import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../vehicles/providers.dart';
import '../maintenance/providers.dart';
import '../maintenance/models/maintenance.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary?>((ref) async {
  final vehicles = await ref.read(vehicleRepositoryProvider).getAll();
  if (vehicles.isEmpty) return null;

  final repository = ref.read(maintenanceRepositoryProvider);

  final allMaintenances = await repository.getAll();

  final totalMaintenances = allMaintenances.length;

  final totalSpent = allMaintenances.fold<double>(
    0,
    (sum, m) => sum + m.maintenanceCost + m.totalPartsCost,
  );

  final sorted = List<Maintenance>.from(allMaintenances)
    ..sort((a, b) => b.date.compareTo(a.date));

  final lastMaintenance = sorted.isNotEmpty ? sorted.first : null;
  final recentMaintenances = sorted.take(5).toList();

  return DashboardSummary(
    totalVehicles: vehicles.length,
    totalMaintenances: totalMaintenances,
    lastMaintenance: lastMaintenance,
    recentMaintenances: recentMaintenances,
    totalSpent: totalSpent,
  );
});

class DashboardSummary {
  final int totalVehicles;
  final int totalMaintenances;
  final Maintenance? lastMaintenance;
  final List<Maintenance> recentMaintenances;
  final double totalSpent;

  const DashboardSummary({
    required this.totalVehicles,
    required this.totalMaintenances,
    this.lastMaintenance,
    this.recentMaintenances = const [],
    required this.totalSpent,
  });
}
