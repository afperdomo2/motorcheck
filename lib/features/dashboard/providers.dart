import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../vehicles/providers.dart';
import '../maintenance/providers.dart';
import '../maintenance/models/maintenance.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary?>((ref) async {
  final vehicles = await ref.read(vehicleRepositoryProvider).getAll();
  if (vehicles.isEmpty) return null;

  final repository = ref.read(maintenanceRepositoryProvider);
  final allMaintenances = await repository.getAll();

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
