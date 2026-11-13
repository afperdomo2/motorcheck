import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/finance/models/budget.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/finance/screens/finance_summary_view.dart';
import 'package:motorcheck/features/fuel/repository.dart';

void main() {
  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    final now = DateTime(2026, 11, 1);
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2),
            ),
            child: Scaffold(body: FinanceSummaryView(vehicleId: 1)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
