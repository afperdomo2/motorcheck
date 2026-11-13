import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/dashboard/providers.dart';
import 'package:motorcheck/features/dashboard/widgets/finance_summary_card.dart';
import 'package:motorcheck/features/finance/models/budget.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/fuel/repository.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';

void main() {
  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    final now = DateTime(2026, 11, 1);
    final vehicle = Vehicle(
      id: 1,
      name: 'Mazda 33',
      currentMileage: 89000,
      createdAt: now,
      updatedAt: now,
    );
    const summary = VehicleFinanceSummary(
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
      fuelStats: FuelStats(
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
      monthlyPoints: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardVehicleProvider.overrideWith((ref) async => vehicle),
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
            child: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(16),
                child: FinanceSummaryCard(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
