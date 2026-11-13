import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/expenses/models/expense.dart';
import 'package:motorcheck/features/expenses/models/expense_category.dart';
import 'package:motorcheck/features/expenses/providers.dart';
import 'package:motorcheck/features/finance/models/budget.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/finance/screens/finance_screen.dart';
import 'package:motorcheck/features/fuel/models/fuel_log.dart';
import 'package:motorcheck/features/fuel/providers.dart';
import 'package:motorcheck/features/fuel/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

void main() {
  testWidgets('las tres secciones no desbordan a 360 px', (tester) async {
    final now = DateTime(2026, 11, 1);
    final vehicle = Vehicle(
      id: 1,
      name: 'Mazda 33',
      currentMileage: 89000,
      createdAt: now,
      updatedAt: now,
    );
    final summary = VehicleFinanceSummary(
      vehicleId: 1,
      monthLabel: 'Noviembre 2026',
      currentMonthMaintenance: 180000,
      currentMonthFuel: 350000,
      currentMonthExpenses: 90000,
      currentMonthTotal: 620000,
      totalMaintenance: 1200000,
      totalFuel: 2400000,
      totalExpenses: 600000,
      totalCost: 4200000,
      costPerKm: 520,
      fuelStats: const FuelStats(
        count: 8,
        totalQuantity: 320,
        totalCost: 2400000,
        currentMonthSpent: 350000,
        averageConsumption: 12.4,
        litersPer100Km: 8.1,
        costPerKm: 420,
      ),
      maintenanceCount: 4,
      fuelCount: 8,
      expenseCount: 6,
      monthlyPoints: List.generate(
        6,
        (index) => MonthlyFinancePoint(
          month: DateTime(2026, 6 + index),
          maintenance: 100000 + index * 10000,
          fuel: 200000 + index * 20000,
          expenses: 50000 + index * 5000,
        ),
      ),
    );
    final fuelLog = FuelLog(
      id: 1,
      vehicleId: 1,
      date: now,
      odometer: 89000,
      quantity: 42,
      unitPrice: 4300,
      totalCost: 180600,
      fuelType: 'gasoline',
      station: 'Terpel',
      createdAt: now,
      updatedAt: now,
    );
    final expenseCategory = ExpenseCategory(
      id: 1,
      key: 'insurance',
      name: 'Seguro',
      iconName: 'security',
      createdAt: now,
    );
    final expense = Expense(
      id: 1,
      vehicleId: 1,
      categoryKey: 'insurance',
      date: now,
      amount: 380000,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehiclesProvider.overrideWith((ref) async => [vehicle]),
          selectedVehicleIdProvider.overrideWith((ref) => 1),
          vehicleFinanceProvider(1).overrideWith((ref) async => summary),
          budgetForVehicleProvider(1).overrideWith(
            (ref) async => Budget(
              vehicleId: 1,
              period: '2026-11',
              amount: 700000,
              createdAt: now,
              updatedAt: now,
            ),
          ),
          fuelLogsProvider(1).overrideWith((ref) async => [fuelLog]),
          fuelStatsProvider(1).overrideWith((ref) async => summary.fuelStats),
          expensesForVehicleProvider(1).overrideWith((ref) async => [expense]),
          expenseCategoriesProvider.overrideWith(
            (ref) async => [expenseCategory],
          ),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(body: FinanceScreen()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(
      find.byKey(const ValueKey('finance-section-summary')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('finance-section-fuel')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('finance-section-expenses')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('finance-section-fuel')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('finance-section-expenses')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
