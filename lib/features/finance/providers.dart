import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../expenses/providers.dart';
import '../fuel/providers.dart';
import '../fuel/repository.dart';
import '../maintenance/providers.dart';
import '../vehicles/providers.dart';

class MonthlyFinancePoint {
  const MonthlyFinancePoint({
    required this.month,
    required this.maintenance,
    required this.fuel,
    required this.expenses,
  });

  final DateTime month;
  final double maintenance;
  final double fuel;
  final double expenses;

  double get total => maintenance + fuel + expenses;
}

class VehicleFinanceSummary {
  const VehicleFinanceSummary({
    required this.vehicleId,
    required this.monthLabel,
    required this.currentMonthMaintenance,
    required this.currentMonthFuel,
    required this.currentMonthExpenses,
    required this.currentMonthTotal,
    required this.totalMaintenance,
    required this.totalFuel,
    required this.totalExpenses,
    required this.totalCost,
    required this.costPerKm,
    required this.fuelStats,
    required this.maintenanceCount,
    required this.fuelCount,
    required this.expenseCount,
    required this.monthlyPoints,
  });

  final int vehicleId;
  final String monthLabel;
  final double currentMonthMaintenance;
  final double currentMonthFuel;
  final double currentMonthExpenses;
  final double currentMonthTotal;
  final double totalMaintenance;
  final double totalFuel;
  final double totalExpenses;
  final double totalCost;
  final double? costPerKm;
  final FuelStats fuelStats;
  final int maintenanceCount;
  final int fuelCount;
  final int expenseCount;
  final List<MonthlyFinancePoint> monthlyPoints;

  bool get hasData => maintenanceCount > 0 || fuelCount > 0 || expenseCount > 0;

  double get currentMonthOther => currentMonthExpenses;
}

final vehicleFinanceProvider =
    FutureProvider.family<VehicleFinanceSummary, int>((ref, vehicleId) async {
      final maintenanceRepo = ref.read(maintenanceRepositoryProvider);
      final maintenances = await maintenanceRepo.getByVehicleId(vehicleId);
      final fuelLogs = await ref.watch(fuelLogsProvider(vehicleId).future);
      final fuelStats = await ref.watch(fuelStatsProvider(vehicleId).future);
      final expenses = await ref.watch(
        vehicleExpensesProvider(vehicleId).future,
      );
      final mileage = await ref.watch(mileageStatsProvider(vehicleId).future);

      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      double maintenanceForMonth(int month, int year) {
        return maintenances
            .where((m) => m.date.month == month && m.date.year == year)
            .fold<double>(
              0,
              (sum, m) => sum + m.maintenanceCost + m.totalPartsCost,
            );
      }

      double fuelForMonth(int month, int year) {
        return fuelLogs
            .where((log) => log.date.month == month && log.date.year == year)
            .fold<double>(0, (sum, log) => sum + log.totalCost);
      }

      double expensesForMonth(int month, int year) {
        return expenses
            .where(
              (expense) =>
                  expense.date.month == month && expense.date.year == year,
            )
            .fold<double>(0, (sum, expense) => sum + expense.amount);
      }

      final totalMaintenance = maintenances.fold<double>(
        0,
        (sum, m) => sum + m.maintenanceCost + m.totalPartsCost,
      );
      final totalFuel = fuelLogs.fold<double>(
        0,
        (sum, log) => sum + log.totalCost,
      );
      final totalExpenses = expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );
      final totalCost = totalMaintenance + totalFuel + totalExpenses;

      double? costPerKm;
      final first = mileage.firstReading;
      final last = mileage.lastReading;
      if (first != null && last != null) {
        final distance = last.mileage - first.mileage;
        if (distance > 0) {
          costPerKm = totalCost / distance;
        }
      }

      final points = <MonthlyFinancePoint>[];
      for (var offset = 5; offset >= 0; offset--) {
        final month = DateTime(now.year, now.month - offset);
        points.add(
          MonthlyFinancePoint(
            month: month,
            maintenance: maintenanceForMonth(month.month, month.year),
            fuel: fuelForMonth(month.month, month.year),
            expenses: expensesForMonth(month.month, month.year),
          ),
        );
      }

      final currentMaintenance = maintenanceForMonth(currentMonth, currentYear);
      final currentFuel = fuelForMonth(currentMonth, currentYear);
      final currentExpenses = expensesForMonth(currentMonth, currentYear);

      return VehicleFinanceSummary(
        vehicleId: vehicleId,
        monthLabel: formatMonthYearLong(now),
        currentMonthMaintenance: currentMaintenance,
        currentMonthFuel: currentFuel,
        currentMonthExpenses: currentExpenses,
        currentMonthTotal: currentMaintenance + currentFuel + currentExpenses,
        totalMaintenance: totalMaintenance,
        totalFuel: totalFuel,
        totalExpenses: totalExpenses,
        totalCost: totalCost,
        costPerKm: costPerKm,
        fuelStats: fuelStats,
        maintenanceCount: maintenances.length,
        fuelCount: fuelLogs.length,
        expenseCount: expenses.length,
        monthlyPoints: points,
      );
    });
