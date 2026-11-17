import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motorcheck/features/dashboard/widgets/fleet_status_mosaic.dart';
import 'package:motorcheck/features/finance/models/budget.dart';
import 'package:motorcheck/features/finance/providers.dart';
import 'package:motorcheck/features/restrictions/providers.dart';
import 'package:motorcheck/features/restrictions/restriction_status.dart';
import 'package:motorcheck/features/vehicles/models/vehicle.dart';

Vehicle _vehicle(int id, String name, String plate, String type) {
  return Vehicle(
    id: id,
    name: name,
    type: type,
    plate: plate,
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );
}

BudgetStatusEntry _budget(
  Vehicle vehicle, {
  required double amount,
  required double spent,
}) {
  return BudgetStatusEntry(
    vehicle: vehicle,
    budget: Budget(
      vehicleId: vehicle.id,
      period: '2026-11',
      amount: amount,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
    spent: spent,
  );
}

RestrictionStatus _today() {
  return const RestrictionStatus(
    configured: true,
    restrictedToday: true,
    restrictedNow: false,
    todayLabel: 'Hoy no circulas · 06:00–21:00',
    nextLabel: 'Martes 17 nov · 06:00–21:00',
  );
}

RestrictionStatus _nextWeek() {
  return RestrictionStatus(
    configured: true,
    restrictedToday: false,
    restrictedNow: false,
    todayLabel: 'Hoy circulas',
    nextLabel: 'Lunes 23 nov · 07:00–19:00',
    nextRestrictionDate: DateTime(2026, 11, 23),
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required List<VehicleRestrictionEntry> restrictions,
  required List<BudgetStatusEntry> budgets,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        restrictionStatusesProvider.overrideWith((ref) async => restrictions),
        budgetStatusesProvider.overrideWith((ref) async => budgets),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(360, 640),
            textScaler: TextScaler.linear(textScale),
          ),
          child: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: FleetStatusMosaic(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final mazda = _vehicle(1, 'Mazda 33', 'HJK-123', 'car');
  final yamaha = _vehicle(3, 'Yamaha FZ', 'MZX-01', 'motorcycle');
  final bici = _vehicle(4, 'Bici Trek', 'BIC-456', 'bike');
  final exento = _vehicle(5, 'Exento', 'EXE-1', 'car');

  testWidgets('mezcla pico y placa y solo presupuestos en alerta', (
    tester,
  ) async {
    await _pump(
      tester,
      restrictions: [
        VehicleRestrictionEntry(vehicle: mazda, status: _today()),
        VehicleRestrictionEntry(vehicle: yamaha, status: _nextWeek()),
        VehicleRestrictionEntry(
          vehicle: exento,
          status: const RestrictionStatus(
            configured: true,
            restrictedToday: false,
            restrictedNow: false,
            todayLabel: 'Exento de pico y placa',
            nextLabel: 'Sin restricciones',
          ),
        ),
      ],
      budgets: [
        _budget(mazda, amount: 1200000, spent: 13591322),
        _budget(bici, amount: 300000, spent: 265000),
        _budget(yamaha, amount: 500000, spent: 250000),
        BudgetStatusEntry(vehicle: bici, budget: null, spent: 1000),
      ],
    );

    expect(find.text('HJK-123'), findsOneWidget);
    expect(find.text('MZX-01'), findsOneWidget);
    expect(find.text('No circula hoy'), findsOneWidget);
    expect(find.text('Hoy circulas'), findsOneWidget);
    expect(find.text('1133 %'), findsOneWidget);
    expect(find.text('88 %'), findsOneWidget);

    expect(find.text('EXE-1'), findsNothing);
    expect(find.text('50 %'), findsNothing);
    expect(find.textContaining('Sin presupuesto'), findsNothing);
  });

  testWidgets('se oculta sin restricciones activas ni presupuestos en alerta', (
    tester,
  ) async {
    await _pump(
      tester,
      restrictions: const [],
      budgets: [_budget(mazda, amount: 1200000, spent: 100000)],
    );

    expect(find.text('Mazda 33'), findsNothing);
    expect(find.text('HJK-123'), findsNothing);
  });

  testWidgets('no desborda a 360 px con texto al 200 %', (tester) async {
    await _pump(
      tester,
      restrictions: [
        VehicleRestrictionEntry(vehicle: mazda, status: _today()),
        VehicleRestrictionEntry(vehicle: yamaha, status: _nextWeek()),
      ],
      budgets: [
        _budget(mazda, amount: 1200000, spent: 13591322),
        _budget(bici, amount: 300000, spent: 265000),
      ],
      textScale: 2,
    );

    expect(tester.takeException(), isNull);
  });
}
