import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/dashboard/screens/dashboard_screen.dart';
import 'package:motorcheck/features/finance/models/budget.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/maintenance/providers.dart';
import 'package:motorcheck/features/reminders/health_score.dart';
import 'package:motorcheck/features/reminders/models/reminder.dart';
import 'package:motorcheck/features/reminders/providers.dart';
import 'package:motorcheck/features/restrictions/providers.dart';
import 'package:motorcheck/features/restrictions/restriction_status.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';
import 'package:motorcheck/features/vehicles/providers.dart';

void main() {
  testWidgets('compone carrusel, pico y placa, presupuestos y gasto global', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime(2026, 11, 1);
    final vehicle = Vehicle(
      id: 1,
      name: 'Mazda 33',
      type: 'car',
      plate: 'HJK-123',
      currentMileage: 89000,
      createdAt: now,
      updatedAt: now,
    );
    const reminder = Reminder(
      id: 'document-1',
      kind: ReminderKind.document,
      vehicleId: 1,
      vehicleName: 'Mazda 33',
      title: 'SOAT',
      subtitle: 'SOAT',
      severity: ReminderSeverity.warning,
      route: '/vehicles/1/documents',
      remainingDays: 12,
    );
    final restriction = VehicleRestrictionEntry(
      vehicle: vehicle,
      status: const RestrictionStatus(
        configured: true,
        restrictedToday: true,
        restrictedNow: false,
        todayLabel: 'Hoy no circulas · 06:00–21:00',
        nextLabel: 'Martes 17 nov · 06:00–21:00',
      ),
    );
    final budget = BudgetStatusEntry(
      vehicle: vehicle,
      budget: Budget(
        vehicleId: 1,
        period: '2026-11',
        amount: 700000,
        createdAt: now,
        updatedAt: now,
      ),
      spent: 616000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehiclesProvider.overrideWith((ref) async => [vehicle]),
          vehicleHealthProvider(1).overrideWith(
            (ref) async =>
                const HealthScore(value: 92, label: 'Al día', reasons: []),
          ),
          vehicleMonthSpendProvider(1).overrideWith((ref) async => 620000),
          upcomingMaintenanceProvider(1).overrideWith((ref) async => []),
          remindersProvider.overrideWith((ref) async => [reminder]),
          restrictionStatusesProvider.overrideWith(
            (ref) async => [restriction],
          ),
          budgetStatusesProvider.overrideWith((ref) async => [budget]),
          fleetMonthBreakdownProvider.overrideWith(
            (ref) async => const MonthSpendBreakdown(
              maintenance: 2100000,
              fuel: 350000,
              expenses: 290000,
            ),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mazda 33'), findsWidgets);
    expect(find.text('Próximos'), findsOneWidget);
    expect(find.text('HJK-123'), findsOneWidget);
    expect(find.text('No circula hoy'), findsOneWidget);
    expect(find.text('88 %'), findsOneWidget);
    expect(find.textContaining('Gasto de'), findsOneWidget);
    expect(find.text('Todos los vehículos'), findsOneWidget);
    expect(find.textContaining('2.740.000'), findsOneWidget);
    expect(find.text('Vencimientos'), findsOneWidget);
    expect(find.text('SOAT'), findsOneWidget);

    expect(find.text('Actualizar km'), findsNothing);
    expect(find.text('Pico y placa'), findsNothing);
    expect(find.text('Últimos mantenimientos'), findsNothing);
  });
}
