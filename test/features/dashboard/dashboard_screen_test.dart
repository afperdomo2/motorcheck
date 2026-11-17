import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/dashboard/providers.dart';
import 'package:motorcheck/features/dashboard/screens/dashboard_screen.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/fuel/repository.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/reminders/health_score.dart';
import 'package:motorcheck/features/reminders/models/reminder.dart';
import 'package:motorcheck/features/reminders/providers.dart';
import 'package:motorcheck/features/vehicles/current_vehicle_provider.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

void main() {
  testWidgets('el inicio compone hero, atención, gasto y actividad', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime(2026, 11, 1);
    final vehicle = Vehicle(
      id: 1,
      name: 'Bici Trek',
      type: 'bike',
      currentMileage: 3400,
      createdAt: now,
      updatedAt: now,
    );
    const reminder = Reminder(
      id: 'document-1',
      kind: ReminderKind.document,
      vehicleId: 1,
      vehicleName: 'Bici Trek',
      title: 'SOAT',
      subtitle: 'SOAT',
      severity: ReminderSeverity.warning,
      route: '/vehicles/1/documents',
      remainingDays: 12,
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
          vehiclesProvider.overrideWith((ref) async => [vehicle]),
          currentVehicleProvider.overrideWith((ref) async => vehicle),
          vehicleHealthProvider(1).overrideWith(
            (ref) async =>
                const HealthScore(value: 92, label: 'Al día', reasons: []),
          ),
          upcomingMaintenanceProvider(1).overrideWith((ref) async => []),
          remindersProvider.overrideWith((ref) async => [reminder]),
          budgetStatusesProvider.overrideWith((ref) async => []),
          dashboardRecentMaintenancesProvider.overrideWith((ref) async => []),
          vehicleFinanceProvider(1).overrideWith((ref) async => summary),
          budgetForVehicleProvider(1).overrideWith((ref) async => null),
          fleetMonthSpendProvider.overrideWith((ref) async => 0),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Atención · 1'), findsOneWidget);
    expect(find.text('Vencimientos'), findsOneWidget);
    expect(find.text('SOAT'), findsOneWidget);
    expect(find.textContaining('Gasto de'), findsOneWidget);
    expect(find.text('Mantenimiento'), findsOneWidget);
    expect(find.text('Últimos mantenimientos'), findsOneWidget);
    expect(find.text('Actualizar km'), findsOneWidget);
    expect(find.text('Próximos'), findsOneWidget);

    expect(find.text('Detalles'), findsNothing);
    expect(find.text('Hoja de vida'), findsNothing);
    expect(find.text('Costo por km'), findsNothing);
    expect(find.text('Consumo'), findsNothing);
    expect(find.byIcon(Icons.refresh), findsNothing);
  });
}
