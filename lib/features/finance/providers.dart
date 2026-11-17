import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../expenses/providers.dart';
import '../fuel/providers.dart';
import '../fuel/repository.dart';
import '../maintenance/providers.dart';
import '../vehicles/models/vehicle.dart';
import '../vehicles/providers.dart';
import 'budget_repository.dart';
import 'budget_status.dart';
import 'models/budget.dart';

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

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

final budgetForVehicleProvider = FutureProvider.family<Budget?, int>((
  ref,
  vehicleId,
) async {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getForVehiclePeriod(vehicleId, repo.currentPeriod);
});

/// Presupuesto, gasto del mes y estado de un vehículo.
class BudgetStatusEntry {
  const BudgetStatusEntry({
    required this.vehicle,
    required this.budget,
    required this.spent,
  });

  final Vehicle vehicle;
  final Budget? budget;
  final double spent;

  bool get hasBudget => budget != null && budget!.amount > 0;

  double get amount => budget?.amount ?? 0;

  double get ratio => hasBudget ? spent / budget!.amount : 0;

  int get percent => (ratio * 100).round();

  BudgetStatus get status => hasBudget
      ? budgetStatusFor(spent: spent, amount: amount)
      : BudgetStatus.ok;

  String get remainingLabel {
    if (!hasBudget) return 'Sin presupuesto mensual';
    if (spent > amount) {
      return 'Excedido por ${formatCurrency(spent - amount)}';
    }
    if (status == BudgetStatus.exceeded) return 'Límite alcanzado';
    return 'Quedan ${formatCurrency(amount - spent)}';
  }
}

class MonthSpendBreakdown {
  const MonthSpendBreakdown({
    required this.maintenance,
    required this.fuel,
    required this.expenses,
  });

  final double maintenance;
  final double fuel;
  final double expenses;

  double get total => maintenance + fuel + expenses;
}

final vehicleMonthBreakdownProvider =
    FutureProvider.family<MonthSpendBreakdown, int>((ref, vehicleId) async {
      final maintenances = await ref.watch(maintenancesProvider.future);
      final fuelLogs = await ref.watch(fuelLogsProvider(vehicleId).future);
      final expenses = await ref.watch(
        vehicleExpensesProvider(vehicleId).future,
      );
      final now = DateTime.now();

      final maintenanceSpent = maintenances
          .where(
            (item) =>
                item.vehicleId == vehicleId &&
                item.date.year == now.year &&
                item.date.month == now.month,
          )
          .fold<double>(
            0,
            (sum, item) => sum + item.maintenanceCost + item.totalPartsCost,
          );
      final fuelSpent = fuelLogs
          .where(
            (log) => log.date.year == now.year && log.date.month == now.month,
          )
          .fold<double>(0, (sum, log) => sum + log.totalCost);
      final expenseSpent = expenses
          .where(
            (expense) =>
                expense.date.year == now.year &&
                expense.date.month == now.month,
          )
          .fold<double>(0, (sum, expense) => sum + expense.amount);

      return MonthSpendBreakdown(
        maintenance: maintenanceSpent,
        fuel: fuelSpent,
        expenses: expenseSpent,
      );
    });

final vehicleMonthSpendProvider = FutureProvider.family<double, int>((
  ref,
  vehicleId,
) async {
  final breakdown = await ref.watch(
    vehicleMonthBreakdownProvider(vehicleId).future,
  );
  return breakdown.total;
});

final globalMonthExpensesProvider = FutureProvider<double>((ref) async {
  final expenses = await ref.watch(globalExpensesProvider.future);
  final now = DateTime.now();
  return expenses
      .where(
        (expense) =>
            expense.date.year == now.year && expense.date.month == now.month,
      )
      .fold<double>(0, (sum, expense) => sum + expense.amount);
});

final fleetMonthBreakdownProvider = FutureProvider<MonthSpendBreakdown>((
  ref,
) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  var maintenance = 0.0;
  var fuel = 0.0;
  var expenses = 0.0;

  for (final vehicle in vehicles) {
    final id = vehicle.id;
    if (id == null) continue;
    final breakdown = await ref.watch(vehicleMonthBreakdownProvider(id).future);
    maintenance += breakdown.maintenance;
    fuel += breakdown.fuel;
    expenses += breakdown.expenses;
  }

  expenses += await ref.watch(globalMonthExpensesProvider.future);
  return MonthSpendBreakdown(
    maintenance: maintenance,
    fuel: fuel,
    expenses: expenses,
  );
});

final fleetMonthSpendProvider = FutureProvider<double>((ref) async {
  final breakdown = await ref.watch(fleetMonthBreakdownProvider.future);
  return breakdown.total;
});

final budgetStatusesProvider = FutureProvider<List<BudgetStatusEntry>>((
  ref,
) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  final repo = ref.watch(budgetRepositoryProvider);
  final period = repo.currentPeriod;
  final entries = <BudgetStatusEntry>[];

  for (final vehicle in vehicles) {
    final id = vehicle.id;
    if (id == null) continue;
    final budget = await repo.getForVehiclePeriod(id, period);
    final spent = await ref.watch(vehicleMonthSpendProvider(id).future);
    entries.add(
      BudgetStatusEntry(vehicle: vehicle, budget: budget, spent: spent),
    );
  }

  return entries;
});

class BudgetNotifier extends Notifier<AsyncValue<void>> {
  BudgetRepository get _repo => ref.read(budgetRepositoryProvider);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> save(int vehicleId, double amount) async {
    state = const AsyncValue.loading();
    final now = DateTime.now();
    try {
      await _repo.upsert(
        Budget(
          vehicleId: vehicleId,
          period: _repo.currentPeriod,
          amount: amount,
          createdAt: now,
          updatedAt: now,
        ),
      );
      ref.invalidate(budgetForVehicleProvider(vehicleId));
      ref.invalidate(budgetStatusesProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> remove(int vehicleId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.delete(vehicleId, _repo.currentPeriod);
      ref.invalidate(budgetForVehicleProvider(vehicleId));
      ref.invalidate(budgetStatusesProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final budgetNotifierProvider =
    NotifierProvider<BudgetNotifier, AsyncValue<void>>(BudgetNotifier.new);

final vehicleFinanceProvider =
    FutureProvider.family<VehicleFinanceSummary, int>((ref, vehicleId) async {
      final allMaintenances = await ref.watch(maintenancesProvider.future);
      final maintenances = allMaintenances
          .where((maintenance) => maintenance.vehicleId == vehicleId)
          .toList();
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
