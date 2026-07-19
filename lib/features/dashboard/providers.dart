import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../vehicles/providers.dart';
import '../vehicles/models/vehicle.dart';
import '../maintenance/providers.dart';
import '../maintenance/models/maintenance.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary?>((ref) async {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  if (vehicleId == null) return null;

  final vehicle = await ref.read(vehicleRepositoryProvider).getById(vehicleId);
  if (vehicle == null) return null;

  final recentMaintenances = await ref
      .read(maintenanceRepositoryProvider)
      .getRecentByVehicleId(vehicleId, limit: 5);

  final totalCount = await ref
      .read(maintenanceRepositoryProvider)
      .countByVehicleId(vehicleId);

  final lastMaintenance = recentMaintenances.isNotEmpty
      ? recentMaintenances.first
      : null;

  final totalSpent = recentMaintenances.fold<double>(
    0,
    (sum, m) => sum + m.totalLaborCost + m.totalPartsCost,
  );

  return DashboardSummary(
    vehicle: vehicle,
    totalMaintenances: totalCount,
    lastMaintenance: lastMaintenance,
    recentMaintenances: recentMaintenances,
    totalSpent: totalSpent,
  );
});

class DashboardSummary {
  final Vehicle vehicle;
  final int totalMaintenances;
  final Maintenance? lastMaintenance;
  final List<Maintenance> recentMaintenances;
  final double totalSpent;

  const DashboardSummary({
    required this.vehicle,
    required this.totalMaintenances,
    this.lastMaintenance,
    this.recentMaintenances = const [],
    required this.totalSpent,
  });
}
